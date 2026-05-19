
const express = require('express');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const cors = require('cors');
const redis = require('redis');
const crypto = require('crypto');

class WebAppDefenseSystem {
    constructor() {
        this.app = express();
        this.attackPatterns = new Map();
        this.ipBlacklist = new Set();
        this.requestFingerprints = new Map();
        this.jmeterDetected = false;

        this.initializeMiddleware();
        this.initializeSecurityLayers();
        this.startMonitoring();
    }

    initializeRateLimiters() {
        const globalLimiter = rateLimit({
            windowMs: 15 * 60 * 1000,
            max: 100,
            message: 'محدودیت نرخ درخواست فعال است',
            standardHeaders: true,
            legacyHeaders: false,
            skip: (req) => this.isWhitelistedIP(req.ip),
            handler: (req, res) => {
                this.logAttack(req.ip, 'RATE_LIMIT_EXCEEDED', req.path);
                this.ipBlacklist.add(req.ip);
                res.status(429).json({
                    error: 'محدودیت نرخ درخواست',
                    blockDuration: '15 دقیقه'
                });
            }
        });

        const apiLimiter = rateLimit({
            windowMs: 60 * 1000,
            max: 30,
            skip: (req) => req.path.includes('/api/') === false
        });

        const authLimiter = rateLimit({
            windowMs: 5 * 60 * 1000,
            max: 10,
            skip: (req) => req.path.includes('/auth/') === false
        });

        return { globalLimiter, apiLimiter, authLimiter };
    }

    detectJMeterPatterns(req) {
        const jmeterIndicators = {
            userAgents: [
                'Apache-HttpClient',
                'Java',
                'jmeter',
                'ApacheBench'
            ],
            headers: {
                'User-Agent': /(Apache-HttpClient|Java|jmeter)/i,
                'Accept': '*/*',
                'Connection': 'keep-alive',
                'Accept-Encoding': 'gzip, deflate'
            },
            timingPatterns: {
                fixedInterval: true,
                burstRequests: true,
                noCookies: true
            }
        };

        const userAgent = req.headers['user-agent'] || '';
        const isJMeterAgent = jmeterIndicators.userAgents.some(agent =>
            userAgent.toLowerCase().includes(agent.toLowerCase())
        );

        const headerMatch = Object.entries(jmeterIndicators.headers).some(([key, pattern]) => {
            if (req.headers[key]) {
                return pattern.test(req.headers[key]);
            }
            return false;
        });

        if (isJMeterAgent || headerMatch) {
            this.jmeterDetected = true;
            this.logAttack(req.ip, 'JMETER_DETECTED', {
                userAgent,
                headers: req.headers
            });
            return true;
        }

        return false;
    }

    behavioralAnalysis(req) {
        const fingerprint = this.generateRequestFingerprint(req);
        const now = Date.now();

        if (this.requestFingerprints.has(fingerprint)) {
            const requestData = this.requestFingerprints.get(fingerprint);
            const timeDiff = now - requestData.lastRequest;

            if (timeDiff < 100) {
                requestData.rapidCount = (requestData.rapidCount || 0) + 1;

                if (requestData.rapidCount > 5) {
                    this.logAttack(req.ip, 'BEHAVIORAL_ANOMALY', {
                        fingerprint,
                        rapidCount: requestData.rapidCount,
                        timeDiff
                    });
                    return true;
                }
            }

            requestData.lastRequest = now;
            requestData.count = (requestData.count || 0) + 1;

            if (requestData.count > 50) {
                this.logAttack(req.ip, 'REPETITIVE_PATTERN', {
                    fingerprint,
                    count: requestData.count
                });
                return true;
            }
        } else {
            this.requestFingerprints.set(fingerprint, {
                ip: req.ip,
                path: req.path,
                userAgent: req.headers['user-agent'],
                firstRequest: now,
                lastRequest: now,
                count: 1
            });
        }

        this.cleanupOldFingerprints();

        return false;
    }

    async challengeResponse(req, res) {
        if (this.shouldChallenge(req)) {
            const challengeType = this.selectChallenge();

            switch (challengeType) {
                case 'JS_CHALLENGE':
                    return this.javascriptChallenge(req, res);
                case 'MATH_CHALLENGE':
                    return this.mathChallenge(req, res);
                case 'CAPTCHA_LITE':
                    return this.liteCaptcha(req, res);
                default:
                    return false;
            }
        }
        return false;
    }

    javascriptChallenge(req, res) {
        const challengeCode = `
            function solveChallenge() {
                const a = ${Math.floor(Math.random() * 100)};
                const b = ${Math.floor(Math.random() * 50)};
                return a + b;
            }
            // پاسخ باید در هدر X-Challenge-Response ارسال شود
        `;

        res.set('X-Challenge-Type', 'JS_EXECUTION');
        res.set('X-Challenge-Code', Buffer.from(challengeCode).toString('base64'));

        res.status(202).json({
            challenge: 'js_execution',
            instructions: 'کد جاوااسکریپت را اجرا کرده و نتیجه را در هدر X-Challenge-Response ارسال کنید',
            timeout: 30
        });

        return true;
    }

    resourceLimiting(req) {
        const endpoint = req.path;
        const ip = req.ip;

        const endpointLimits = {
            '/api/data': { maxSize: 1024 * 1024, maxTime: 5000 },
            '/api/upload': { maxSize: 10 * 1024 * 1024, maxTime: 100000 },
            '/api/search': { maxSize: 512 * 1024, maxTime: 2000 },
            default: { maxSize: 256 * 1024, maxTime: 1000 }
        };

        const limit = endpointLimits[endpoint] || endpointLimits.default;

        const contentLength = parseInt(req.headers['content-length']) || 0;
        if (contentLength > limit.maxSize) {
            this.logAttack(ip, 'REQUEST_SIZE_EXCEEDED', {
                endpoint,
                size: contentLength,
                limit: limit.maxSize
            });
            return false;
        }

        return true;
    }

    logAttack(ip, attackType, details) {
        const logEntry = {
            timestamp: new Date().toISOString(),
            ip,
            attackType,
            details,
            action: 'BLOCKED',
            severity: this.getAttackSeverity(attackType)
        };

        console.log(`[SECURITY_ALERT] ${JSON.stringify(logEntry)}`);

        const fs = require('fs');
        fs.appendFileSync('security_logs.jsonl', JSON.stringify(logEntry) + '\n');

        if (logEntry.severity === 'CRITICAL') {
            this.sendAlert(logEntry);
        }
    }

    getAttackSeverity(attackType) {
        const severityMap = {
            'JMETER_DETECTED': 'HIGH',
            'RATE_LIMIT_EXCEEDED': 'MEDIUM',
            'BEHAVIORAL_ANOMALY': 'HIGH',
            'REPETITIVE_PATTERN': 'MEDIUM',
            'REQUEST_SIZE_EXCEEDED': 'LOW',
            'IP_BLACKLISTED': 'MEDIUM'
        };

        return severityMap[attackType] || 'LOW';
    }

    initializeCaching() {
        const redisClient = redis.createClient({
            url: 'redis://localhost:6379'
        });

        redisClient.on('error', (err) => {
            console.error('Redis connection error:', err);
        });

        return redisClient;
    }

    wafMiddleware(req, res, next) {
        const sqlInjectionPatterns = [
            /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION)\b.*\b(FROM|INTO|SET|WHERE)\b)/i,
            /(\b(OR|AND)\b\s*\d+\s*=\s*\d+)/i,
            /('|"|;|--|\/\*|\*\/)/gi
        ];

        const requestString = JSON.stringify(req.body) + req.url + JSON.stringify(req.query);

        for (const pattern of sqlInjectionPatterns) {
            if (pattern.test(requestString)) {
                this.logAttack(req.ip, 'SQL_INJECTION_ATTEMPT', {
                    pattern: pattern.toString(),
                    snippet: requestString.substring(0, 100)
                });
                return res.status(403).json({ error: 'error' });
            }
        }

        const xssPatterns = [
            /<script\b[^>]*>(.*?)<\/script>/gi,
            /javascript:/gi,
            /on\w+\s*=/gi,
            /eval\s*\(/gi
        ];

        for (const pattern of xssPatterns) {
            if (pattern.test(requestString)) {
                this.logAttack(req.ip, 'XSS_ATTEMPT', {
                    pattern: pattern.toString()
                });
                return res.status(403).json({ error: 'error' });
            }
        }

        next();
    }

    initializeFailover() {
        process.on('uncaughtException', (error) => {
            console.error('Critical error:', error);
            this.emergencyMode();
        });

        process.on('SIGTERM', () => {
            this.gracefulShutdown();
        });
    }

    emergencyMode() {
        console.log('Entering emergency mode - basic services only');

        this.app.use((req, res, next) => {
            if (req.method !== 'GET') {
                return res.status(503).json({
                    error: 'error',
                    mode: 'EMERGENCY'
                });
            }
            next();
        });
    }

    generateSecurityReport() {
        const report = {
            timestamp: new Date().toISOString(),
            totalRequests: this.requestFingerprints.size,
            blockedIPs: this.ipBlacklist.size,
            jmeterDetections: this.jmeterDetected ? 1 : 0,
            recentAttacks: Array.from(this.attackPatterns.entries()).slice(-10),
            recommendations: this.generateRecommendations()
        };

        return report;
    }

    generateRecommendations() {
        const recommendations = [];

        if (this.ipBlacklist.size > 100) {
            recommendations.push('افزایش محدودیت نرخ درخواست برای IPهای مشکوک');
        }

        if (this.jmeterDetected) {
            recommendations.push('فعال‌سازی CAPTCHA برای endpointهای حساس');
            recommendations.push('پیاده‌سازی سیستم چالش-پاسخ پیشرفته');
        }

        if (this.requestFingerprints.size > 10000) {
            recommendations.push('مقیاس‌سازی سیستم تحلیل رفتاری');
            recommendations.push('استفاده از Redis برای ذخیره‌سازی fingerprints');
        }

        return recommendations;
    }

    generateRequestFingerprint(req) {
        const data = `${req.ip}-${req.method}-${req.path}-${req.headers['user-agent']}`;
        return crypto.createHash('sha256').update(data).digest('hex');
    }

    cleanupOldFingerprints() {
        const now = Date.now();
        const oneHour = 60 * 60 * 1000;

        for (const [fingerprint, data] of this.requestFingerprints.entries()) {
            if (now - data.lastRequest > oneHour) {
                this.requestFingerprints.delete(fingerprint);
            }
        }
    }

    shouldChallenge(req) {
        const suspiciousFactors = [];

        if (this.detectJMeterPatterns(req)) suspiciousFactors.push('JMETER');
        if (this.behavioralAnalysis(req)) suspiciousFactors.push('BEHAVIOR');
        if (this.ipBlacklist.has(req.ip)) suspiciousFactors.push('BLACKLISTED');

        return suspiciousFactors.length > 1;
    }

    selectChallenge() {
        const challenges = ['JS_CHALLENGE', 'MATH_CHALLENGE', 'CAPTCHA_LITE'];
        return challenges[Math.floor(Math.random() * challenges.length)];
    }

    isWhitelistedIP(ip) {
        const whitelist = [
            '127.0.0.1',
            '::1',
            // اضافه کردن IPهای مورد اعتماد
        ];
        return whitelist.includes(ip);
    }

    sendAlert(logEntry) {
        // پیاده‌سازی ارسال هشدار (ایمیل، Telegram، Slack, etc.)
        console.log(`[ALERT] Critical attack detected: ${logEntry.attackType} from ${logEntry.ip}`);
    }

    gracefulShutdown() {
        console.log('Initiating graceful shutdown...');

        // ذخیره لاگ‌ها
        const report = this.generateSecurityReport();
        const fs = require('fs');
        fs.writeFileSync('shutdown_report.json', JSON.stringify(report, null, 2));

        process.exit(0);
    }

    initializeMiddleware() {
        this.app.use(helmet());
        this.app.use(cors());
        this.app.use(express.json({ limit: '50mb' }));
        this.app.use(express.urlencoded({ extended: true, limit: '50mb' }));

        // فعال‌سازی WAF
        this.app.use(this.wafMiddleware.bind(this));

        // فعال‌سازی محدودیت نرخ
        const limiters = this.initializeRateLimiters();
        this.app.use(limiters.globalLimiter);
        this.app.use('/api/', limiters.apiLimiter);
        this.app.use('/auth/', limiters.authLimiter);
    }

    initializeSecurityLayers() {
        // Middleware اصلی امنیتی
        this.app.use(async (req, res, next) => {
            // بررسی IP بلاک‌شده
            if (this.ipBlacklist.has(req.ip)) {
                return res.status(403).json({ error: 'دسترسی مسدود شده است' });
            }

            // بررسی الگوهای JMeter
            if (this.detectJMeterPatterns(req)) {
                this.ipBlacklist.add(req.ip);
                return res.status(403).json({
                    error: 'ابزار تست بار تشخیص داده شد',
                    action: 'BLOCKED'
                });
            }

            // بررسی محدودیت منابع
            if (!this.resourceLimiting(req)) {
                return res.status(413).json({ error: 'درخواست بسیار بزرگ' });
            }

            // سیستم چالش-پاسخ
            const challengeIssued = await this.challengeResponse(req, res);
            if (challengeIssued) {
                return; // پاسخ چالش ارسال شده است
            }

            next();
        });
    }

    startMonitoring() {
        setInterval(() => {
            const report = this.generateSecurityReport();
            console.log('[MONITORING]', JSON.stringify(report, null, 2));

            // پاکسازی دوره‌ای
            this.cleanupOldFingerprints();

            // اگر لیست بلاک خیلی بزرگ شد، قدیمی‌ها را پاک کن
            if (this.ipBlacklist.size > 1000) {
                const oldIps = Array.from(this.ipBlacklist).slice(0, 500);
                oldIps.forEach(ip => this.ipBlacklist.delete(ip));
            }
        }, 5 * 60 * 1000); // هر 5 دقیقه
    }

    startServer(port = 3000) {
        this.app.listen(port, () => {
            console.log(`سرویس دفاعی فعال شد روی پورت ${port}`);
            console.log(`لاگ‌های امنیتی در security_logs.jsonl ذخیره می‌شوند`);
        });

        this.initializeFailover();
    }
}

// راه‌اندازی سیستم
if (require.main === module) {
    const defenseSystem = new WebAppDefenseSystem();

    // endpointهای نمونه
    defenseSystem.app.get('/', (req, res) => {
        res.json({
            status: 'فعال',
            defense: 'لایه‌های امنیتی فعال هستند',
            timestamp: new Date().toISOString()
        });
    });

    defenseSystem.app.get('/api/status', (req, res) => {
        res.json({
            system: 'Web App Defense System',
            version: '2.0.0',
            activeLayers: 10,
            blockedIPs: defenseSystem.ipBlacklist.size,
            jmeterDetected: defenseSystem.jmeterDetected
        });
    });

    defenseSystem.app.post('/api/data', (req, res) => {
        setTimeout(() => {
            res.json({
                received: req.body,
                processed: true,
                defenseChecked: true
            });
        }, 100);
    });

    defenseSystem.startServer(3000);
}

module.exports = WebAppDefenseSystem;
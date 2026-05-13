const mcache = require('memory-cache');

const cache = (duration) => {
  return (req, res, next) => {
    // Only cache GET requests
    if (req.method !== 'GET') return next();

    const key = '__express__' + (req.originalUrl || req.url);
    const cachedBody = mcache.get(key);

    if (cachedBody) {
      console.log(`📦 Cache Hit: ${key}`);
      return res.json(JSON.parse(cachedBody));
    } else {
      res.sendResponse = res.json;
      res.json = (body) => {
        mcache.put(key, JSON.stringify(body), duration * 1000);
        res.sendResponse(body);
      };
      next();
    }
  };
};

module.exports = cache;

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });

const app = express();

app.use(cors());
app.use(morgan('dev'));

const AUTH = 'http://localhost:5001';
const ACADEMIC = 'http://localhost:5002';
const USER = 'http://localhost:5003';

// The key is NOT to use pathRewrite if the target already includes the base path,
// OR use it to map the relative path correctly.
app.use('/api/auth', createProxyMiddleware({ target: AUTH, changeOrigin: true, pathRewrite: { '^/api/auth': '' } }));
app.use('/api/users', createProxyMiddleware({ target: USER, changeOrigin: true, pathRewrite: { '^/api/users': '' } }));

// For Academic Service, we map each /api subpath to its service equivalent
app.use('/api/dashboard', createProxyMiddleware({ target: ACADEMIC + '/dashboard', changeOrigin: true, pathRewrite: { '^/api/dashboard': '' } }));
app.use('/api/courses', createProxyMiddleware({ target: ACADEMIC + '/courses', changeOrigin: true, pathRewrite: { '^/api/courses': '' } }));
app.use('/api/tasks', createProxyMiddleware({ target: ACADEMIC + '/tasks', changeOrigin: true, pathRewrite: { '^/api/tasks': '' } }));

const PORT = 5000;
app.listen(PORT, () => console.log(`🚀 Gateway established on port ${PORT}`));

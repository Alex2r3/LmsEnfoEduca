const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const compression = require('compression');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const authRoutes = require('../../routes/auth.routes');

const app = express();

// Middleware
app.use(cors());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());

// Routes
app.use('/', authRoutes);

// Database
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ Auth Service connected to MongoDB');
    app.listen(5001, () => console.log('🔐 Auth Service running on port 5001'));
  })
  .catch(err => console.error(err));

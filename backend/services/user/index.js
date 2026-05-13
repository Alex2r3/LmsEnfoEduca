const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const compression = require('compression');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const userRoutes = require('../../routes/user.routes');

const app = express();

app.use(cors());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());

app.use('/', userRoutes);

mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ User Service connected to MongoDB');
    app.listen(5003, () => console.log('👥 User Service running on port 5003'));
  })
  .catch(err => console.error(err));

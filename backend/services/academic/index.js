const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const compression = require('compression');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const courseRoutes = require('../../routes/course.routes');
const taskRoutes = require('../../routes/task.routes');
const gradeRoutes = require('../../routes/grade.routes');
const attendanceRoutes = require('../../routes/attendance.routes');
const dashboardRoutes = require('../../routes/dashboard.routes');

const app = express();

app.use(cors());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());

app.use('/courses', courseRoutes);
app.use('/tasks', taskRoutes);
app.use('/grades', gradeRoutes);
app.use('/attendance', attendanceRoutes);
app.use('/dashboard', dashboardRoutes);

mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ Academic Service connected to MongoDB');
    app.listen(5002, () => console.log('📚 Academic Service running on port 5002'));
  })
  .catch(err => console.error(err));

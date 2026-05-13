const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Course = require('../models/Course');
const Task = require('../models/Task');
const Attendance = require('../models/Attendance');
const cache = require('../middleware/cache');
const { authenticate } = require('../middleware/auth');

// GET /api/dashboard (Cached for 30s)
router.get('/', authenticate, cache(30), async (req, res) => {
  try {
    const { role } = req.user;
    const data = {};

    if (role === 'admin') {
      data.totalUsers = await User.countDocuments({ isActive: true });
      data.totalStudents = await User.countDocuments({ role: 'alumno', isActive: true });
      data.totalTeachers = await User.countDocuments({ role: 'profesor', isActive: true });
      data.totalParents = await User.countDocuments({ role: 'padre', isActive: true });
      data.totalCourses = await Course.countDocuments({ isActive: true });
      data.totalTasks = await Task.countDocuments({ isActive: true });
      data.recentUsers = await User.find({ isActive: true }).sort({ createdAt: -1 }).limit(5).select('firstName lastName role createdAt');
    }

    if (role === 'profesor') {
      const courses = await Course.find({ teacher: req.user._id, isActive: true });
      data.totalCourses = courses.length;
      data.totalStudents = new Set(courses.flatMap(c => c.students.map(s => s.toString()))).size;
      const tasks = await Task.find({ teacher: req.user._id, isActive: true });
      data.totalTasks = tasks.length;
      data.pendingGrading = 0;
      tasks.forEach(t => { t.submissions.forEach(s => { if (s.status === 'submitted') data.pendingGrading++; }); });
      data.courses = courses.map(c => ({ _id: c._id, name: c.name, code: c.code, color: c.color, studentCount: c.students.length }));
    }

    if (role === 'alumno') {
      const courses = await Course.find({ students: req.user._id, isActive: true }).populate('teacher', 'firstName lastName');
      data.totalCourses = courses.length;
      const tasks = await Task.find({ course: { $in: courses.map(c => c._id) }, isActive: true });
      data.totalTasks = tasks.length;
      data.completedTasks = 0;
      data.pendingTasks = 0;
      tasks.forEach(t => {
        const sub = t.submissions.find(s => s.student.toString() === req.user._id.toString());
        if (sub) data.completedTasks++; else data.pendingTasks++;
      });
      data.points = req.user.points;
      data.level = req.user.level;
      data.badges = req.user.badges;
      data.courses = courses.map(c => ({ _id: c._id, name: c.name, code: c.code, color: c.color, teacher: c.teacher }));
      const upcoming = tasks.filter(t => {
        const sub = t.submissions.find(s => s.student.toString() === req.user._id.toString());
        return !sub && new Date(t.dueDate) > new Date();
      }).slice(0, 5);
      data.upcomingTasks = upcoming.map(t => ({ _id: t._id, title: t.title, dueDate: t.dueDate, course: t.course }));
    }

    if (role === 'padre') {
      const parent = await User.findById(req.user._id).populate('children', 'firstName lastName points level badges');
      
      const childrenWithStats = await Promise.all(parent.children.map(async (child) => {
        const courses = await Course.find({ students: child._id, isActive: true });
        const tasks = await Task.find({ course: { $in: courses.map(c => c._id) }, isActive: true });
        
        let completed = 0, pending = 0;
        tasks.forEach(t => {
          const sub = t.submissions.find(s => s.student.toString() === child._id.toString());
          if (sub) completed++; else pending++;
        });

        return {
          ...child.toObject(),
          totalCourses: courses.length,
          completedTasks: completed,
          pendingTasks: pending
        };
      }));

      data.children = childrenWithStats;
    }

    res.json({ dashboard: data });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;

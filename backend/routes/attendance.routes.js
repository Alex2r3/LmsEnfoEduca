const express = require('express');
const router = express.Router();
const Attendance = require('../models/Attendance');
const Course = require('../models/Course');
const User = require('../models/User');
const { authenticate, authorize } = require('../middleware/auth');

// GET /api/attendance - Get attendance records
router.get('/', authenticate, async (req, res) => {
  try {
    const { courseId, studentId, startDate, endDate } = req.query;
    let query = {};
    if (courseId) query.course = courseId;
    if (startDate && endDate) {
      query.date = { $gte: new Date(startDate), $lte: new Date(endDate) };
    }

    if (req.user.role === 'alumno') {
      const records = await Attendance.find(query)
        .populate('course', 'name code color')
        .sort({ date: -1 });
      const filtered = records.map(a => {
        const obj = a.toObject();
        obj.records = obj.records.filter(r => r.student.toString() === req.user._id.toString());
        return obj;
      });
      return res.json({ attendance: filtered });
    }

    if (req.user.role === 'padre') {
      const parent = await User.findById(req.user._id);
      const records = await Attendance.find(query).populate('course', 'name code color').sort({ date: -1 });
      const filtered = records.map(a => {
        const obj = a.toObject();
        obj.records = obj.records.filter(r => parent.children.map(c => c.toString()).includes(r.student.toString()));
        return obj;
      });
      return res.json({ attendance: filtered });
    }

    if (req.user.role === 'profesor') {
      query.teacher = req.user._id;
    }

    const attendance = await Attendance.find(query)
      .populate('course', 'name code color')
      .populate('records.student', 'firstName lastName')
      .sort({ date: -1 });
    res.json({ attendance });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/attendance - Record attendance
router.post('/', authenticate, authorize('profesor', 'admin'), async (req, res) => {
  try {
    const { courseId, date, records } = req.body;
    const course = await Course.findById(courseId);
    if (!course) return res.status(404).json({ message: 'Course not found' });

    let attendance = await Attendance.findOne({ course: courseId, date: new Date(date) });
    if (attendance) {
      attendance.records = records;
    } else {
      attendance = new Attendance({ course: courseId, teacher: req.user._id, date: new Date(date), records });
    }
    await attendance.save();
    await attendance.populate('records.student', 'firstName lastName');
    res.status(201).json({ message: 'Attendance recorded', attendance });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ message: 'Attendance already recorded for this date' });
    }
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/attendance/summary/:courseId
router.get('/summary/:courseId', authenticate, async (req, res) => {
  try {
    const records = await Attendance.find({ course: req.params.courseId });
    const course = await Course.findById(req.params.courseId).populate('students', 'firstName lastName');
    if (!course) return res.status(404).json({ message: 'Course not found' });

    const summary = course.students.map(student => {
      let present = 0, absent = 0, late = 0, excused = 0;
      records.forEach(att => {
        const rec = att.records.find(r => r.student.toString() === student._id.toString());
        if (rec) {
          if (rec.status === 'present') present++;
          else if (rec.status === 'absent') absent++;
          else if (rec.status === 'late') late++;
          else if (rec.status === 'excused') excused++;
        }
      });
      return { student: { _id: student._id, firstName: student.firstName, lastName: student.lastName }, present, absent, late, excused, total: records.length };
    });
    res.json({ summary, totalClasses: records.length });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;

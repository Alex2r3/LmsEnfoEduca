const express = require('express');
const router = express.Router();
const Task = require('../models/Task');
const Course = require('../models/Course');
const User = require('../models/User');
const { authenticate } = require('../middleware/auth');

// GET /api/grades - Get grades for current user
router.get('/', authenticate, async (req, res) => {
  try {
    const { courseId } = req.query;
    let studentId = req.user._id;

    if (req.user.role === 'padre') {
      const parent = await User.findById(req.user._id);
      const childId = req.query.childId || (parent.children.length > 0 ? parent.children[0] : null);
      if (!childId) return res.json({ grades: [] });
      studentId = childId;
    }

    let taskQuery = { isActive: true };
    if (courseId) taskQuery.course = courseId;

    if (req.user.role === 'alumno' || req.user.role === 'padre') {
      const courses = await Course.find({ students: studentId }).select('_id');
      taskQuery.course = courseId ? courseId : { $in: courses.map(c => c._id) };
    } else if (req.user.role === 'profesor') {
      taskQuery.teacher = req.user._id;
    }

    const tasks = await Task.find(taskQuery)
      .populate('course', 'name code color')
      .populate('submissions.student', 'firstName lastName');

    if (req.user.role === 'alumno' || req.user.role === 'padre') {
      const grades = tasks.map(task => {
        const sub = task.submissions.find(s => s.student._id.toString() === studentId.toString());
        return {
          taskId: task._id, title: task.title, type: task.type,
          course: task.course, maxGrade: task.maxGrade, dueDate: task.dueDate,
          grade: sub ? sub.grade : null, feedback: sub ? sub.feedback : '',
          status: sub ? sub.status : 'pending'
        };
      });
      return res.json({ grades });
    }

    // For teachers: return all submissions with grades
    const allGrades = [];
    tasks.forEach(task => {
      task.submissions.forEach(sub => {
        allGrades.push({
          taskId: task._id, title: task.title, course: task.course,
          student: sub.student, grade: sub.grade, maxGrade: task.maxGrade,
          status: sub.status, submittedAt: sub.submittedAt
        });
      });
    });
    res.json({ grades: allGrades });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/grades/average/:studentId
router.get('/average/:studentId', authenticate, async (req, res) => {
  try {
    const courses = await Course.find({ students: req.params.studentId });
    const averages = [];

    for (const course of courses) {
      const tasks = await Task.find({ course: course._id, isActive: true });
      let total = 0, count = 0;
      tasks.forEach(task => {
        const sub = task.submissions.find(s => s.student.toString() === req.params.studentId);
        if (sub && sub.grade !== null) { total += sub.grade; count++; }
      });
      averages.push({
        course: { _id: course._id, name: course.name, code: course.code, color: course.color },
        average: count > 0 ? Math.round((total / count) * 100) / 100 : 0,
        totalTasks: tasks.length, gradedTasks: count
      });
    }
    res.json({ averages });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;

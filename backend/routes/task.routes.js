const express = require('express');
const router = express.Router();
const Task = require('../models/Task');
const Course = require('../models/Course');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { authenticate, authorize } = require('../middleware/auth');

// GET /api/tasks
router.get('/', authenticate, async (req, res) => {
  try {
    const { courseId } = req.query;
    let query = { isActive: true };
    if (courseId) query.course = courseId;

    if (req.user.role === 'profesor') {
      query.teacher = req.user._id;
    } else if (req.user.role === 'alumno') {
      const courses = await Course.find({ students: req.user._id }).select('_id');
      query.course = { $in: courses.map(c => c._id) };
    } else if (req.user.role === 'padre') {
      const parent = await User.findById(req.user._id);
      const childCourses = await Course.find({ students: { $in: parent.children } }).select('_id');
      query.course = { $in: childCourses.map(c => c._id) };
    }

    const tasks = await Task.find(query)
      .populate('course', 'name code color')
      .populate('teacher', 'firstName lastName')
      .sort({ dueDate: 1 });

    if (req.user.role === 'alumno') {
      const result = tasks.map(task => {
        const t = task.toObject();
        const sub = task.submissions.find(s => s.student.toString() === req.user._id.toString());
        t.mySubmission = sub || null;
        t.submitted = !!sub;
        delete t.submissions;
        return t;
      });
      return res.json({ tasks: result });
    }
    res.json({ tasks });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/tasks/:id
router.get('/:id', authenticate, async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('course', 'name code color')
      .populate('teacher', 'firstName lastName')
      .populate('submissions.student', 'firstName lastName email');
    if (!task) return res.status(404).json({ message: 'Task not found' });

    if (req.user.role === 'alumno') {
      const t = task.toObject();
      t.mySubmission = task.submissions.find(s => s.student._id.toString() === req.user._id.toString()) || null;
      t.submissions = undefined;
      return res.json({ task: t });
    }
    res.json({ task });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/tasks
router.post('/', authenticate, authorize('profesor', 'admin'), async (req, res) => {
  try {
    const { title, description, courseId, dueDate, maxGrade, type } = req.body;
    const course = await Course.findById(courseId);
    if (!course) return res.status(404).json({ message: 'Course not found' });

    const task = new Task({ title, description, course: courseId, teacher: req.user._id, dueDate, maxGrade: maxGrade || 20, type: type || 'tarea' });
    await task.save();

    const io = req.app.get('io');
    for (const sid of course.students) {
      const n = new Notification({ recipient: sid, sender: req.user._id, type: 'task_assigned', title: 'Nueva tarea', message: `${title} - ${course.name}`, data: { taskId: task._id } });
      await n.save();
      if (io) io.to(sid.toString()).emit('notification', n);
    }
    await task.populate('course', 'name code color');
    res.status(201).json({ message: 'Task created', task });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/tasks/:id/submit
router.post('/:id/submit', authenticate, authorize('alumno'), async (req, res) => {
  try {
    const { content, fileUrl } = req.body;
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Task not found' });

    const existing = task.submissions.find(s => s.student.toString() === req.user._id.toString());
    if (existing) {
      existing.content = content || existing.content;
      existing.fileUrl = fileUrl || existing.fileUrl;
      existing.submittedAt = new Date();
      existing.status = 'submitted';
    } else {
      task.submissions.push({ student: req.user._id, content, fileUrl });
      await User.findByIdAndUpdate(req.user._id, { $inc: { points: 10 } });
    }
    await task.save();
    res.json({ message: 'Task submitted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// PUT /api/tasks/:id/grade
router.put('/:id/grade', authenticate, authorize('profesor', 'admin'), async (req, res) => {
  try {
    const { studentId, grade, feedback } = req.body;
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Task not found' });

    const sub = task.submissions.find(s => s.student.toString() === studentId);
    if (!sub) return res.status(404).json({ message: 'Submission not found' });

    sub.grade = grade;
    sub.feedback = feedback || '';
    sub.gradedAt = new Date();
    sub.status = 'graded';
    await task.save();

    const bonus = Math.round((grade / task.maxGrade) * 50);
    const user = await User.findByIdAndUpdate(studentId, { $inc: { points: bonus } }, { new: true });
    const newLevel = Math.floor(user.points / 200) + 1;
    if (newLevel > user.level) await User.findByIdAndUpdate(studentId, { level: newLevel });

    const io = req.app.get('io');
    const n = new Notification({ recipient: studentId, sender: req.user._id, type: 'task_graded', title: 'Tarea calificada', message: `${task.title}: ${grade}/${task.maxGrade}`, data: { taskId: task._id, grade } });
    await n.save();
    if (io) io.to(studentId).emit('notification', n);

    res.json({ message: 'Graded', submission: sub });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// PUT /api/tasks/:id
router.put('/:id', authenticate, authorize('profesor', 'admin'), async (req, res) => {
  try {
    const task = await Task.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate('course', 'name code color');
    if (!task) return res.status(404).json({ message: 'Task not found' });
    res.json({ message: 'Updated', task });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// DELETE /api/tasks/:id
router.delete('/:id', authenticate, authorize('profesor', 'admin'), async (req, res) => {
  try {
    await Task.findByIdAndUpdate(req.params.id, { isActive: false });
    res.json({ message: 'Deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;

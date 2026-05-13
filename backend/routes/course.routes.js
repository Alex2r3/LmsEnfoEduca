const express = require('express');
const router = express.Router();
const Course = require('../models/Course');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { authenticate, authorize } = require('../middleware/auth');
const cache = require('../middleware/cache');

// GET /api/courses - Get courses for current user (Cached for 30s)
router.get('/', authenticate, cache(30), async (req, res) => {
  try {
    let query = {};
    const { role } = req.user;

    if (role === 'profesor') {
      query.teacher = req.user._id;
    } else if (role === 'alumno') {
      query.students = req.user._id;
    } else if (role === 'padre') {
      const parent = await User.findById(req.user._id).populate('children');
      const childIds = parent.children.map(c => c._id);
      query.students = { $in: childIds };
    }
    // Admin sees all

    const courses = await Course.find(query)
      .populate('teacher', 'firstName lastName email')
      .populate('students', 'firstName lastName email')
      .sort({ createdAt: -1 });

    res.json({ courses });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/courses/:id
router.get('/:id', authenticate, async (req, res) => {
  try {
    const course = await Course.findById(req.params.id)
      .populate('teacher', 'firstName lastName email avatar')
      .populate('students', 'firstName lastName email avatar points level');
    
    if (!course) {
      return res.status(404).json({ message: 'Course not found' });
    }

    res.json({ course });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/courses - Create course (admin or teacher)
router.post('/', authenticate, authorize('admin', 'profesor'), async (req, res) => {
  try {
    const { name, description, code, color, icon, teacherId, schedule, category } = req.body;

    const existingCourse = await Course.findOne({ code: code.toUpperCase() });
    if (existingCourse) {
      return res.status(400).json({ message: 'Course code already exists' });
    }

    const teacher = req.user.role === 'profesor' ? req.user._id : teacherId;

    const course = new Course({
      name,
      description,
      code: code.toUpperCase(),
      color: color || '#4A90D9',
      icon: icon || 'book',
      teacher,
      schedule: schedule || {},
      category: category || 'Otro'
    });

    await course.save();
    await course.populate('teacher', 'firstName lastName email');

    res.status(201).json({ message: 'Course created', course });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// PUT /api/courses/:id
router.put('/:id', authenticate, authorize('admin', 'profesor'), async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) {
      return res.status(404).json({ message: 'Course not found' });
    }

    if (req.user.role === 'profesor' && course.teacher.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const updates = req.body;
    const updatedCourse = await Course.findByIdAndUpdate(req.params.id, updates, { new: true })
      .populate('teacher', 'firstName lastName email');

    res.json({ message: 'Course updated', course: updatedCourse });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/courses/:id/enroll - Enroll students
router.post('/:id/enroll', authenticate, authorize('admin', 'profesor'), async (req, res) => {
  try {
    const { studentIds } = req.body;
    const course = await Course.findById(req.params.id);
    
    if (!course) {
      return res.status(404).json({ message: 'Course not found' });
    }

    // Add students to course (avoid duplicates)
    for (const studentId of studentIds) {
      if (!course.students.includes(studentId)) {
        course.students.push(studentId);

        // Notify student
        const notification = new Notification({
          recipient: studentId,
          sender: req.user._id,
          type: 'course_update',
          title: 'Nuevo curso asignado',
          message: `Has sido inscrito en el curso: ${course.name}`,
          data: { courseId: course._id }
        });
        await notification.save();

        // Real-time notification
        const io = req.app.get('io');
        if (io) io.to(studentId).emit('notification', notification);
      }
    }

    await course.save();
    await course.populate('students', 'firstName lastName email');

    res.json({ message: 'Students enrolled', course });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/courses/:id/unenroll
router.post('/:id/unenroll', authenticate, authorize('admin', 'profesor'), async (req, res) => {
  try {
    const { studentId } = req.body;
    await Course.findByIdAndUpdate(req.params.id, {
      $pull: { students: studentId }
    });
    res.json({ message: 'Student removed from course' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// DELETE /api/courses/:id
router.delete('/:id', authenticate, authorize('admin'), async (req, res) => {
  try {
    await Course.findByIdAndUpdate(req.params.id, { isActive: false });
    res.json({ message: 'Course deactivated' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;

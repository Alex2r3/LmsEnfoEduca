const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authenticate, authorize } = require('../middleware/auth');

// GET /api/users - Get all users (admin only)
router.get('/', authenticate, authorize('admin'), async (req, res) => {
  try {
    const { role, search, page = 1, limit = 20 } = req.query;
    const query = {};
    
    if (role) query.role = role;
    if (search) {
      query.$or = [
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const total = await User.countDocuments(query);

    res.json({
      users,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / limit)
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/users/teachers - Get all teachers
router.get('/teachers', authenticate, async (req, res) => {
  try {
    const teachers = await User.find({ role: 'profesor', isActive: true })
      .select('firstName lastName email');
    res.json({ teachers });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/users/students - Get all students
router.get('/students', authenticate, authorize('admin', 'profesor'), async (req, res) => {
  try {
    const students = await User.find({ role: 'alumno', isActive: true })
      .select('firstName lastName email points level');
    res.json({ students });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/users/ranking - Get student ranking
router.get('/ranking', authenticate, async (req, res) => {
  try {
    const students = await User.find({ role: 'alumno', isActive: true })
      .select('firstName lastName points level badges avatar')
      .sort({ points: -1 })
      .limit(50);
    res.json({ ranking: students });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/users/:id
router.get('/:id', authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .populate('children', 'firstName lastName email points level')
      .select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({ user });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// PUT /api/users/:id
router.put('/:id', authenticate, async (req, res) => {
  try {
    // Only admin or the user themselves can update
    if (req.user.role !== 'admin' && req.user._id.toString() !== req.params.id) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const { firstName, lastName, phone, avatar } = req.body;
    const updates = {};
    if (firstName) updates.firstName = firstName;
    if (lastName) updates.lastName = lastName;
    if (phone) updates.phone = phone;
    if (avatar) updates.avatar = avatar;

    // Admin can also update role and active status
    if (req.user.role === 'admin') {
      if (req.body.role) updates.role = req.body.role;
      if (req.body.isActive !== undefined) updates.isActive = req.body.isActive;
    }

    const user = await User.findByIdAndUpdate(req.params.id, updates, { new: true })
      .select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'User updated', user });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// DELETE /api/users/:id (admin only)
router.delete('/:id', authenticate, authorize('admin'), async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, { isActive: false }, { new: true });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({ message: 'User deactivated' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/users/:id/link-child (parent links to child)
router.post('/:id/link-child', authenticate, authorize('padre', 'admin'), async (req, res) => {
  try {
    const { childEmail } = req.body;
    const child = await User.findOne({ email: childEmail, role: 'alumno' });
    
    if (!child) {
      return res.status(404).json({ message: 'Student not found with that email' });
    }

    const parentId = req.user.role === 'admin' ? req.params.id : req.user._id;

    await User.findByIdAndUpdate(parentId, { $addToSet: { children: child._id } });
    await User.findByIdAndUpdate(child._id, { parentId: parentId });

    res.json({ message: 'Child linked successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;

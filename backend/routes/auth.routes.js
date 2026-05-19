const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { authenticate } = require('../middleware/auth');

// POST /api/auth/register (Restricted to Admin for dashboard use)
router.post('/register', authenticate, async (req, res) => {
  try {
    // Only admins can create users from the dashboard
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Only admins can register new users' });
    }
    const { firstName, lastName, email, password, role, parentId } = req.body;

    // 1. Validación de campos obligatorios
    if (!firstName || !lastName || !email || !password) {
      return res.status(400).json({ message: 'Todos los campos (Nombre, Apellido, Email y Contraseña) son obligatorios' });
    }

    // 2. Evitar campos vacíos o con solo espacios
    if (!firstName.trim() || !lastName.trim() || !email.trim() || !password.trim()) {
      return res.status(400).json({ message: 'Los campos no pueden contener únicamente espacios en blanco' });
    }

    // 3. Evitar espacios duros (Alt+0160) en el correo y contraseña
    if (/[\s\u00a0]/.test(email) || /[\s\u00a0]/.test(password)) {
      return res.status(400).json({ message: 'El correo y la contraseña no pueden contener espacios en blanco' });
    }

    // 4. Validar que Nombre y Apellido contengan únicamente letras y espacios (sin símbolos ni números)
    const nameRegex = /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/;
    if (!nameRegex.test(firstName.trim()) || !nameRegex.test(lastName.trim())) {
      return res.status(400).json({ message: 'El nombre y el apellido solo pueden contener letras y espacios (sin números ni símbolos)' });
    }

    // 5. Validar fortaleza de la contraseña (mínimo 8 caracteres y al menos un número)
    if (password.length < 8 || !/\d/.test(password)) {
      return res.status(400).json({ message: 'La contraseña debe tener al menos 8 caracteres y contener al menos un número' });
    }

    const existingUser = await User.findOne({ email: email.trim().toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    const user = new User({ firstName, lastName, email, password, role: role || 'alumno' });

    // If student has a parent
    if (parentId && role === 'alumno') {
      user.parentId = parentId;
      await User.findByIdAndUpdate(parentId, { $push: { children: user._id } });
    }

    await user.save();

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        role: user.role,
        points: user.points,
        level: user.level
      }
    });
  } catch (error) {
    console.error('❌ Registration Error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'El correo y la contraseña son requeridos' });
    }

    // Rechazar si contienen espacios en blanco comunes o no divisibles (Alt+0160 / \u00a0)
    if (/[\s\u00a0]/.test(email) || /[\s\u00a0]/.test(password)) {
      return res.status(400).json({ message: 'El correo y la contraseña no pueden contener espacios en blanco' });
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(400).json({ message: 'Invalid email or password' });
    }

    if (!user.isActive) {
      return res.status(403).json({ message: 'Account is deactivated' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid email or password' });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
        points: user.points,
        level: user.level,
        badges: user.badges
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/auth/me
router.get('/me', authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .populate('children', 'firstName lastName email')
      .select('-password');
    res.json({ user });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;

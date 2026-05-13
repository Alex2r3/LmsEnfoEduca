const mongoose = require('mongoose');

const courseSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Course name is required'],
    trim: true
  },
  description: {
    type: String,
    default: ''
  },
  code: {
    type: String,
    required: true,
    unique: true,
    uppercase: true
  },
  color: {
    type: String,
    default: '#4A90D9'
  },
  icon: {
    type: String,
    default: 'book'
  },
  teacher: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  students: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  schedule: {
    day: { type: String, default: '' },
    startTime: { type: String, default: '' },
    endTime: { type: String, default: '' }
  },
  category: {
    type: String,
    enum: ['Matemáticas', 'Ciencias', 'Lenguaje', 'Historia', 'Arte', 'Tecnología', 'Educación Física', 'Inglés', 'Idiomas', 'Otro'],
    default: 'Otro'
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Indexes for scalability
courseSchema.index({ teacher: 1 });
courseSchema.index({ code: 1 }, { unique: true });
courseSchema.index({ category: 1 });
courseSchema.index({ isActive: 1 });

module.exports = mongoose.model('Course', courseSchema);

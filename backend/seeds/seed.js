require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const mongoose = require('mongoose');
const User = require('../models/User');
const Course = require('../models/Course');
const Task = require('../models/Task');
const Notification = require('../models/Notification');

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/enfoeduca');
    console.log('Connected to MongoDB');

    // Clear existing data
    await User.deleteMany({});
    await Course.deleteMany({});
    await Task.deleteMany({});
    await Notification.deleteMany({});

    const plainPw = 'password123';

    // Create admin
    const admin = await User.create({ firstName: 'Admin', lastName: 'EnfoEduca', email: 'admin@enfoeduca.com', password: plainPw, role: 'admin', points: 0, level: 1 });

    // Create teachers
    const teachersData = [
      { firstName: 'María', lastName: 'García', email: 'maria@enfoeduca.com' },
      { firstName: 'Carlos', lastName: 'López', email: 'carlos@enfoeduca.com' },
      { firstName: 'Elena', lastName: 'Rivas', email: 'elena@enfoeduca.com' },
      { firstName: 'Jorge', lastName: 'Pérez', email: 'jorge@enfoeduca.com' },
      { firstName: 'Sofía', lastName: 'Vargas', email: 'sofia.v@enfoeduca.com' }
    ];
    const teachers = await Promise.all(teachersData.map(t => User.create({ ...t, password: plainPw, role: 'profesor' })));

    // Create students
    const studentsData = [
      { firstName: 'Ana', lastName: 'Martínez', email: 'ana@enfoeduca.com', points: 350, level: 2 },
      { firstName: 'Luis', lastName: 'Rodríguez', email: 'luis@enfoeduca.com', points: 520, level: 3 },
      { firstName: 'Sofía', lastName: 'Hernández', email: 'sofia@enfoeduca.com', points: 180, level: 1 },
      { firstName: 'Diego', lastName: 'Torres', email: 'diego@enfoeduca.com', points: 410, level: 3 },
      { firstName: 'Lucía', lastName: 'Mendoza', email: 'lucia@enfoeduca.com', points: 900, level: 5 },
      { firstName: 'Mateo', lastName: 'Castro', email: 'mateo@enfoeduca.com', points: 120, level: 1 },
      { firstName: 'Valeria', lastName: 'Ortiz', email: 'valeria@enfoeduca.com', points: 650, level: 4 },
      { firstName: 'Javier', lastName: 'Ruiz', email: 'javier@enfoeduca.com', points: 300, level: 2 }
    ];
    const students = await Promise.all(studentsData.map(s => User.create({ ...s, password: plainPw, role: 'alumno' })));

    // Create parents and link to students
    const parentsData = [
      { firstName: 'Roberto', lastName: 'Martínez', email: 'roberto@enfoeduca.com', children: [students[0]._id, students[1]._id] },
      { firstName: 'Patricia', lastName: 'Torres', email: 'patricia@enfoeduca.com', children: [students[3]._id] },
      { firstName: 'Fernando', lastName: 'Mendoza', email: 'fernando@enfoeduca.com', children: [students[4]._id] }
    ];
    const parents = await Promise.all(parentsData.map(p => User.create({ ...p, password: plainPw, role: 'padre' })));
    
    // Update students with parentId
    for (const p of parents) {
      for (const childId of p.children) {
        await User.findByIdAndUpdate(childId, { parentId: p._id });
      }
    }

    // Create courses
    const coursesData = [
      { name: 'Matemáticas Básicas', code: 'MAT101', color: '#4A90D9', icon: 'calculate', teacher: teachers[0]._id, students: students.slice(0, 4), category: 'Matemáticas' },
      { name: 'Ciencias Naturales', code: 'CIE201', color: '#27AE60', icon: 'science', teacher: teachers[0]._id, students: students.slice(2, 6), category: 'Ciencias' },
      { name: 'Lenguaje y Literatura', code: 'LEN301', color: '#E67E22', icon: 'menu_book', teacher: teachers[1]._id, students: students.slice(0, 6), category: 'Lenguaje' },
      { name: 'Historia del Perú', code: 'HIS401', color: '#8E44AD', icon: 'history_edu', teacher: teachers[1]._id, students: students.slice(4, 8), category: 'Historia' },
      { name: 'Inglés Avanzado', code: 'ING501', color: '#16A085', icon: 'translate', teacher: teachers[2]._id, students: students.slice(0, 8), category: 'Idiomas' },
      { name: 'Programación Web', code: 'DEV601', color: '#2C3E50', icon: 'code', teacher: teachers[3]._id, students: students.slice(4, 8), category: 'Tecnología' }
    ];
    const courses = await Promise.all(coursesData.map(c => Course.create({ ...c, description: `Curso integral de ${c.name}`, schedule: { day: 'Lunes', startTime: '08:00', endTime: '10:00' } })));

    // Create tasks
    const now = new Date();
    await Task.create({ title: 'Ecuaciones lineales', description: 'Resolver los ejercicios 1-20', course: courses[0]._id, teacher: teachers[0]._id, dueDate: new Date(now.getTime() + 3 * 86400000), type: 'tarea' });
    await Task.create({ title: 'Ensayo Crítico', description: 'Sobre la literatura moderna', course: courses[2]._id, teacher: teachers[1]._id, dueDate: new Date(now.getTime() + 5 * 86400000), type: 'tarea' });

    console.log('✅ Seed completed successfully with expanded data!');
    console.log('\n📧 Login credentials (password: password123):');
    console.log('Admin: admin@enfoeduca.com');
    console.log('Teacher: maria@enfoeduca.com');
    console.log('Student: ana@enfoeduca.com');
    console.log('Parent: roberto@enfoeduca.com');
    process.exit(0);
  } catch (error) {
    console.error('Seed error:', error);
    process.exit(1);
  }
};

seed();

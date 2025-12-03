const express = require('express');
const router = express.Router();

// Import route modules
// const authRoutes = require('./auth.routes');
// const userRoutes = require('./user.routes');
// const studentRoutes = require('./student.routes');
// const teacherRoutes = require('./teacher.routes');
// const courseRoutes = require('./course.routes');

// API welcome route
router.get('/', (req, res) => {
  res.json({
    message: 'Welcome to FuturSchool System API',
    version: '1.0.0',
    endpoints: {
      health: '/api/health'
    }
  });
});

// Mount route modules
// router.use('/auth', authRoutes);
// router.use('/users', userRoutes);
// router.use('/students', studentRoutes);
// router.use('/teachers', teacherRoutes);
// router.use('/courses', courseRoutes);

module.exports = router;


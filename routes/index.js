const express = require('express');
const router = express.Router();

// Import route modules
const authRoutes = require('./auth.routes');
const employeeRoutes = require('./employee.routes');
const classRoutes = require('./class.routes');
const studentRoutes = require('./student.routes');
const roleRoutes = require('./role.routes');
const permissionRoutes = require('./permission.routes');

// API welcome route
router.get('/', (req, res) => {
  res.json({
    message: 'Welcome to FuturSchool System API',
    version: '1.0.0',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      employees: '/api/employees',
      classes: '/api/classes',
      students: '/api/students',
      roles: '/api/roles',
      permissions: '/api/permissions'
    }
  });
});

// Mount route modules
router.use('/auth', authRoutes);
router.use('/employees', employeeRoutes);
router.use('/classes', classRoutes);
router.use('/students', studentRoutes);
router.use('/roles', roleRoutes);
router.use('/permissions', permissionRoutes);

module.exports = router;


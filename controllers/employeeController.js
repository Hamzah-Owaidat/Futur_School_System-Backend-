const { query } = require('../config/database');
const bcrypt = require('bcryptjs');
const { asyncHandler, sendSuccessResponse, sendErrorResponse } = require('../utils/helpers');

/**
 * @desc    Get all employees
 * @route   GET /api/employees
 * @access  Private (Admin, Principal)
 */
exports.getAllEmployees = asyncHandler(async (req, res, next) => {
  const { page = 1, limit = 10, search = '', role_id = '', is_active = '' } = req.query;
  
  // Ensure proper integer conversion
  const pageNum = parseInt(page) || 1;
  const limitNum = parseInt(limit) || 10;
  const offset = (pageNum - 1) * limitNum;

  let sql = `
    SELECT e.*, r.name as role_name, r.description as role_description
    FROM employees e
    INNER JOIN roles r ON e.role_id = r.id
    WHERE 1=1
  `;
  const params = [];

  if (search) {
    sql += ` AND (e.first_name LIKE ? OR e.last_name LIKE ? OR e.email LIKE ? OR e.employee_code LIKE ?)`;
    const searchTerm = `%${search}%`;
    params.push(searchTerm, searchTerm, searchTerm, searchTerm);
  }

  if (role_id) {
    sql += ` AND e.role_id = ?`;
    params.push(parseInt(role_id));
  }

  if (is_active !== '') {
    sql += ` AND e.is_active = ?`;
    params.push(is_active === 'true' || is_active === true);
  }

  // Use template literal for LIMIT/OFFSET to avoid parameter issues
  sql += ` ORDER BY e.created_at DESC LIMIT ${limitNum} OFFSET ${offset}`;

  const employees = await query(sql, params);

  // Get total count
  let countSql = `
    SELECT COUNT(*) as total
    FROM employees e
    WHERE 1=1
  `;
  const countParams = [];

  if (search) {
    countSql += ` AND (e.first_name LIKE ? OR e.last_name LIKE ? OR e.email LIKE ? OR e.employee_code LIKE ?)`;
    const searchTerm = `%${search}%`;
    countParams.push(searchTerm, searchTerm, searchTerm, searchTerm);
  }

  if (role_id) {
    countSql += ` AND e.role_id = ?`;
    countParams.push(parseInt(role_id));
  }

  if (is_active !== '') {
    countSql += ` AND e.is_active = ?`;
    countParams.push(is_active === 'true' || is_active === true);
  }

  const countResult = await query(countSql, countParams);
  const total = countResult[0].total;

  // Remove passwords from response
  employees.forEach(emp => delete emp.password);

  sendSuccessResponse(res, 200, {
    employees,
    pagination: {
      page: pageNum,
      limit: limitNum,
      total,
      pages: Math.ceil(total / limitNum)
    }
  }, 'Employees retrieved successfully');
});

/**
 * @desc    Get single employee by ID
 * @route   GET /api/employees/:id
 * @access  Private
 */
exports.getEmployeeById = asyncHandler(async (req, res, next) => {
  const { id } = req.params;

  const employees = await query(
    `SELECT e.*, r.name as role_name, r.description as role_description
     FROM employees e
     INNER JOIN roles r ON e.role_id = r.id
     WHERE e.id = ?`,
    [id]
  );

  if (employees.length === 0) {
    return sendErrorResponse(res, 404, 'Employee not found');
  }

  const employee = employees[0];
  delete employee.password;

  sendSuccessResponse(res, 200, { employee }, 'Employee retrieved successfully');
});

/**
 * @desc    Create new employee
 * @route   POST /api/employees
 * @access  Private (Admin)
 */
exports.createEmployee = asyncHandler(async (req, res, next) => {
  const {
    employee_code,
    first_name,
    last_name,
    email,
    password,
    phone,
    date_of_birth,
    gender,
    address,
    hire_date,
    salary,
    role_id
  } = req.body;

  // Validate required fields
  if (!employee_code || !first_name || !last_name || !email || !hire_date || !role_id) {
    return sendErrorResponse(res, 400, 'Please provide all required fields');
  }

  // Check if employee_code or email already exists
  const existing = await query(
    'SELECT id FROM employees WHERE employee_code = ? OR email = ?',
    [employee_code, email]
  );

  if (existing.length > 0) {
    return sendErrorResponse(res, 400, 'Employee code or email already exists');
  }

  // Hash password if provided
  let hashedPassword = null;
  if (password) {
    hashedPassword = await bcrypt.hash(password, 10);
  }

  // Insert employee
  const result = await query(
    `INSERT INTO employees 
     (employee_code, first_name, last_name, email, password, phone, date_of_birth, 
      gender, address, hire_date, salary, role_id, created_by, updated_by)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      employee_code,
      first_name,
      last_name,
      email,
      hashedPassword,
      phone || null,
      date_of_birth || null,
      gender || 'other',
      address || null,
      hire_date,
      salary || null,
      role_id,
      req.employee.id,
      req.employee.id
    ]
  );

  // Get created employee
  const employees = await query(
    `SELECT e.*, r.name as role_name, r.description as role_description
     FROM employees e
     INNER JOIN roles r ON e.role_id = r.id
     WHERE e.id = ?`,
    [result.insertId]
  );

  const employee = employees[0];
  delete employee.password;

  sendSuccessResponse(res, 201, { employee }, 'Employee created successfully');
});

/**
 * @desc    Update employee
 * @route   PUT /api/employees/:id
 * @access  Private (Admin)
 */
exports.updateEmployee = asyncHandler(async (req, res, next) => {
  const { id } = req.params;
  const {
    employee_code,
    first_name,
    last_name,
    email,
    password,
    phone,
    date_of_birth,
    gender,
    address,
    hire_date,
    salary,
    role_id,
    is_active
  } = req.body;

  // Check if employee exists
  const existing = await query('SELECT id FROM employees WHERE id = ?', [id]);
  if (existing.length === 0) {
    return sendErrorResponse(res, 404, 'Employee not found');
  }

  // Check if employee_code or email already exists (excluding current employee)
  if (employee_code || email) {
    const duplicate = await query(
      'SELECT id FROM employees WHERE (employee_code = ? OR email = ?) AND id != ?',
      [employee_code || '', email || '', id]
    );
    if (duplicate.length > 0) {
      return sendErrorResponse(res, 400, 'Employee code or email already exists');
    }
  }

  // Build update query dynamically
  const updates = [];
  const params = [];

  if (employee_code) { updates.push('employee_code = ?'); params.push(employee_code); }
  if (first_name) { updates.push('first_name = ?'); params.push(first_name); }
  if (last_name) { updates.push('last_name = ?'); params.push(last_name); }
  if (email) { updates.push('email = ?'); params.push(email); }
  if (phone !== undefined) { updates.push('phone = ?'); params.push(phone); }
  if (date_of_birth) { updates.push('date_of_birth = ?'); params.push(date_of_birth); }
  if (gender) { updates.push('gender = ?'); params.push(gender); }
  if (address !== undefined) { updates.push('address = ?'); params.push(address); }
  if (hire_date) { updates.push('hire_date = ?'); params.push(hire_date); }
  if (salary !== undefined) { updates.push('salary = ?'); params.push(salary); }
  if (role_id) { updates.push('role_id = ?'); params.push(role_id); }
  if (is_active !== undefined) { updates.push('is_active = ?'); params.push(is_active); }

  // Handle password update
  if (password) {
    const hashedPassword = await bcrypt.hash(password, 10);
    updates.push('password = ?');
    params.push(hashedPassword);
  }

  updates.push('updated_by = ?');
  params.push(req.employee.id);
  params.push(id);

  await query(
    `UPDATE employees SET ${updates.join(', ')} WHERE id = ?`,
    params
  );

  // Get updated employee
  const employees = await query(
    `SELECT e.*, r.name as role_name, r.description as role_description
     FROM employees e
     INNER JOIN roles r ON e.role_id = r.id
     WHERE e.id = ?`,
    [id]
  );

  const employee = employees[0];
  delete employee.password;

  sendSuccessResponse(res, 200, { employee }, 'Employee updated successfully');
});

/**
 * @desc    Delete employee
 * @route   DELETE /api/employees/:id
 * @access  Private (Admin)
 */
exports.deleteEmployee = asyncHandler(async (req, res, next) => {
  const { id } = req.params;

  // Check if employee exists
  const existing = await query('SELECT id FROM employees WHERE id = ?', [id]);
  if (existing.length === 0) {
    return sendErrorResponse(res, 404, 'Employee not found');
  }

  // Soft delete (set is_active to false) instead of hard delete
  await query(
    'UPDATE employees SET is_active = FALSE, updated_by = ? WHERE id = ?',
    [req.employee.id, id]
  );

  sendSuccessResponse(res, 200, null, 'Employee deleted successfully');
});


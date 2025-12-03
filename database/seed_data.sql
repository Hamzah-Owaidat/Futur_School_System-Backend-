-- ============================================
-- FuturSchool System - Seed Data
-- Sample data for testing and initial setup
-- ============================================
-- IMPORTANT: Run this ENTIRE script from the beginning in one go!
-- Do NOT run individual sections separately.
-- 
-- NOTE: We use NULL for created_by/updated_by initially to avoid circular dependency
-- Then update them after employees are created
-- 
-- This script uses subqueries to find IDs by name/code, making it more robust
-- ============================================

USE futurschool;

-- ============================================
-- 1. INSERT ROLES (with NULL for created_by/updated_by initially)
-- ============================================
INSERT INTO roles (name, description, is_active, created_by, updated_by) VALUES
('admin', 'System Administrator with full access', TRUE, NULL, NULL),
('teacher', 'Teacher role with access to students and notes', TRUE, NULL, NULL),
('principal', 'School Principal with administrative access', TRUE, NULL, NULL),
('secretary', 'Secretary role with limited administrative access', TRUE, NULL, NULL),
('student', 'Student role (for future use)', TRUE, NULL, NULL);

-- ============================================
-- 2. INSERT PERMISSIONS (with NULL for created_by/updated_by initially)
-- ============================================
INSERT INTO permissions (name, resource, action, description, created_by, updated_by) VALUES
-- Student permissions
('create_student', 'student', 'create', 'Create new student', NULL, NULL),
('read_student', 'student', 'read', 'View student information', NULL, NULL),
('update_student', 'student', 'update', 'Update student information', NULL, NULL),
('delete_student', 'student', 'delete', 'Delete student', NULL, NULL),
-- Employee permissions
('create_employee', 'employee', 'create', 'Create new employee', NULL, NULL),
('read_employee', 'employee', 'read', 'View employee information', NULL, NULL),
('update_employee', 'employee', 'update', 'Update employee information', NULL, NULL),
('delete_employee', 'employee', 'delete', 'Delete employee', NULL, NULL),
-- Note permissions
('create_note', 'note', 'create', 'Create new note', NULL, NULL),
('read_note', 'note', 'read', 'View notes', NULL, NULL),
('update_note', 'note', 'update', 'Update note', NULL, NULL),
('delete_note', 'note', 'delete', 'Delete note', NULL, NULL),
-- Class permissions
('create_class', 'class', 'create', 'Create new class', NULL, NULL),
('read_class', 'class', 'read', 'View class information', NULL, NULL),
('update_class', 'class', 'update', 'Update class information', NULL, NULL),
('delete_class', 'class', 'delete', 'Delete class', NULL, NULL),
-- Role & Permission permissions
('manage_roles', 'role', 'manage', 'Manage roles and permissions', NULL, NULL),
('read_roles', 'role', 'read', 'View roles and permissions', NULL, NULL);

-- ============================================
-- 3. INSERT SAMPLE EMPLOYEES (now we can reference roles)
-- Using subqueries to get role IDs by name for safety
-- ============================================
INSERT INTO employees (employee_code, first_name, last_name, email, phone, date_of_birth, gender, address, hire_date, salary, role_id, is_active, created_by, updated_by) VALUES
('EMP001', 'John', 'Smith', 'john.smith@futurschool.com', '123-456-7890', '1980-05-15', 'male', '123 Main St, City', '2020-01-15', 50000.00, (SELECT id FROM roles WHERE name = 'admin' LIMIT 1), TRUE, NULL, NULL),
('EMP002', 'Sarah', 'Johnson', 'sarah.johnson@futurschool.com', '123-456-7891', '1985-08-20', 'female', '456 Oak Ave, City', '2020-02-01', 45000.00, (SELECT id FROM roles WHERE name = 'teacher' LIMIT 1), TRUE, NULL, NULL),
('EMP003', 'Michael', 'Brown', 'michael.brown@futurschool.com', '123-456-7892', '1982-03-10', 'male', '789 Pine Rd, City', '2019-09-01', 48000.00, (SELECT id FROM roles WHERE name = 'teacher' LIMIT 1), TRUE, NULL, NULL),
('EMP004', 'Emily', 'Davis', 'emily.davis@futurschool.com', '123-456-7893', '1988-11-25', 'female', '321 Elm St, City', '2021-01-10', 42000.00, (SELECT id FROM roles WHERE name = 'teacher' LIMIT 1), TRUE, NULL, NULL),
('EMP005', 'Robert', 'Wilson', 'robert.wilson@futurschool.com', '123-456-7894', '1975-07-05', 'male', '654 Maple Dr, City', '2018-08-15', 60000.00, (SELECT id FROM roles WHERE name = 'principal' LIMIT 1), TRUE, NULL, NULL);

-- ============================================
-- 4. UPDATE ROLES AND PERMISSIONS with created_by/updated_by
-- (Now that employees exist, we can set the audit fields)
-- ============================================
-- Get the admin employee ID
SET @admin_employee_id = (SELECT id FROM employees WHERE employee_code = 'EMP001' LIMIT 1);

-- Update roles (set created_by and updated_by to first admin employee)
UPDATE roles SET created_by = @admin_employee_id, updated_by = @admin_employee_id;

-- Update permissions (set created_by and updated_by to first admin employee)
UPDATE permissions SET created_by = @admin_employee_id, updated_by = @admin_employee_id;

-- Update employees (set created_by and updated_by to first admin employee)
UPDATE employees SET created_by = @admin_employee_id, updated_by = @admin_employee_id WHERE employee_code = 'EMP001';
UPDATE employees SET created_by = @admin_employee_id, updated_by = @admin_employee_id WHERE employee_code IN ('EMP002', 'EMP003', 'EMP004', 'EMP005');

-- ============================================
-- 5. ASSIGN PERMISSIONS TO ROLES
-- ============================================
-- Admin gets all permissions
INSERT INTO role_permissions (role_id, permission_id, created_by, updated_by)
SELECT (SELECT id FROM roles WHERE name = 'admin' LIMIT 1), id, @admin_employee_id, @admin_employee_id FROM permissions;

-- Teacher permissions
INSERT INTO role_permissions (role_id, permission_id, created_by, updated_by)
SELECT (SELECT id FROM roles WHERE name = 'teacher' LIMIT 1), id, @admin_employee_id, @admin_employee_id FROM permissions 
WHERE resource IN ('student', 'note', 'class') AND action IN ('read', 'create', 'update');

-- Principal permissions (similar to admin but can be customized)
INSERT INTO role_permissions (role_id, permission_id, created_by, updated_by)
SELECT (SELECT id FROM roles WHERE name = 'principal' LIMIT 1), id, @admin_employee_id, @admin_employee_id FROM permissions 
WHERE resource IN ('student', 'employee', 'note', 'class') AND action != 'delete';

-- Secretary permissions
INSERT INTO role_permissions (role_id, permission_id, created_by, updated_by)
SELECT (SELECT id FROM roles WHERE name = 'secretary' LIMIT 1), id, @admin_employee_id, @admin_employee_id FROM permissions 
WHERE resource IN ('student', 'class') AND action IN ('read', 'create', 'update');

-- ============================================
-- 6. INSERT SAMPLE CLASSES
-- ============================================
INSERT INTO classes (class_name, class_code, grade_level, section, capacity, room_number, academic_year, teacher_id, is_active, created_by, updated_by) VALUES
('Grade 1-A', 'G1A', 1, 'A', 30, '101', '2024-2025', (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id),
('Grade 1-B', 'G1B', 1, 'B', 30, '102', '2024-2025', (SELECT id FROM employees WHERE employee_code = 'EMP003' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id),
('Grade 2-A', 'G2A', 2, 'A', 30, '201', '2024-2025', (SELECT id FROM employees WHERE employee_code = 'EMP004' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id),
('Grade 2-B', 'G2B', 2, 'B', 30, '202', '2024-2025', (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id),
('Grade 3-A', 'G3A', 3, 'A', 30, '301', '2024-2025', (SELECT id FROM employees WHERE employee_code = 'EMP003' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id);

-- ============================================
-- 7. INSERT SAMPLE STUDENTS
-- ============================================
INSERT INTO students (student_code, first_name, last_name, email, phone, date_of_birth, gender, address, parent_name, parent_phone, parent_email, enrollment_date, class_id, is_active, created_by, updated_by) VALUES
('STU001', 'Alice', 'Williams', 'alice.williams@student.futurschool.com', '111-222-3333', '2017-03-15', 'female', '100 Student St, City', 'John Williams', '111-222-3334', 'john.williams@email.com', '2024-09-01', (SELECT id FROM classes WHERE class_code = 'G1A' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id),
('STU002', 'Bob', 'Miller', 'bob.miller@student.futurschool.com', '111-222-3335', '2017-05-20', 'male', '200 Student St, City', 'Jane Miller', '111-222-3336', 'jane.miller@email.com', '2024-09-01', (SELECT id FROM classes WHERE class_code = 'G1A' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id),
('STU003', 'Charlie', 'Garcia', 'charlie.garcia@student.futurschool.com', '111-222-3337', '2016-08-10', 'male', '300 Student St, City', 'Maria Garcia', '111-222-3338', 'maria.garcia@email.com', '2023-09-01', (SELECT id FROM classes WHERE class_code = 'G2A' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id),
('STU004', 'Diana', 'Martinez', 'diana.martinez@student.futurschool.com', '111-222-3339', '2016-11-25', 'female', '400 Student St, City', 'Carlos Martinez', '111-222-3340', 'carlos.martinez@email.com', '2023-09-01', (SELECT id FROM classes WHERE class_code = 'G2A' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id),
('STU005', 'Ethan', 'Anderson', 'ethan.anderson@student.futurschool.com', '111-222-3341', '2015-02-14', 'male', '500 Student St, City', 'Lisa Anderson', '111-222-3342', 'lisa.anderson@email.com', '2022-09-01', (SELECT id FROM classes WHERE class_code = 'G3A' LIMIT 1), TRUE, @admin_employee_id, @admin_employee_id);

-- ============================================
-- 8. INSERT SAMPLE NOTES
-- ============================================
INSERT INTO notes (student_id, employee_id, title, content, note_type, priority, is_visible_to_parent, created_by, updated_by) VALUES
((SELECT id FROM students WHERE student_code = 'STU001' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1), 'Excellent Progress', 'Alice has shown excellent progress in mathematics this month. Keep up the great work!', 'academic', 'low', TRUE, (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1)),
((SELECT id FROM students WHERE student_code = 'STU001' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1), 'Behavior Note', 'Alice was very helpful to classmates today during group activities.', 'behavioral', 'low', TRUE, (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1)),
((SELECT id FROM students WHERE student_code = 'STU002' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1), 'Needs Improvement', 'Bob needs to focus more on homework completion. Please follow up with parents.', 'academic', 'medium', TRUE, (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP002' LIMIT 1)),
((SELECT id FROM students WHERE student_code = 'STU003' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP004' LIMIT 1), 'Attendance Concern', 'Charlie has been absent 3 times this month. Please contact parents.', 'attendance', 'high', TRUE, (SELECT id FROM employees WHERE employee_code = 'EMP004' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP004' LIMIT 1)),
((SELECT id FROM students WHERE student_code = 'STU004' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP004' LIMIT 1), 'Outstanding Performance', 'Diana performed exceptionally well in the science project presentation.', 'academic', 'low', TRUE, (SELECT id FROM employees WHERE employee_code = 'EMP004' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP004' LIMIT 1)),
((SELECT id FROM students WHERE student_code = 'STU005' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP003' LIMIT 1), 'General Note', 'Ethan participated actively in class discussions today.', 'general', 'low', FALSE, (SELECT id FROM employees WHERE employee_code = 'EMP003' LIMIT 1), (SELECT id FROM employees WHERE employee_code = 'EMP003' LIMIT 1));


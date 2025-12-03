-- ============================================
-- FuturSchool System - Seed Data
-- Sample data for testing and initial setup
-- ============================================

USE futurschool;

-- ============================================
-- 1. INSERT ROLES
-- ============================================
INSERT INTO roles (name, description, is_active, created_by, updated_by) VALUES
('admin', 'System Administrator with full access', TRUE, 1, 1),
('teacher', 'Teacher role with access to students and notes', TRUE, 1, 1),
('principal', 'School Principal with administrative access', TRUE, 1, 1),
('secretary', 'Secretary role with limited administrative access', TRUE, 1, 1),
('student', 'Student role (for future use)', TRUE, 1, 1);

-- ============================================
-- 2. INSERT PERMISSIONS
-- ============================================
INSERT INTO permissions (name, resource, action, description, created_by, updated_by) VALUES
-- Student permissions
('create_student', 'student', 'create', 'Create new student', 1, 1),
('read_student', 'student', 'read', 'View student information', 1, 1),
('update_student', 'student', 'update', 'Update student information', 1, 1),
('delete_student', 'student', 'delete', 'Delete student', 1, 1),
-- Employee permissions
('create_employee', 'employee', 'create', 'Create new employee', 1, 1),
('read_employee', 'employee', 'read', 'View employee information', 1, 1),
('update_employee', 'employee', 'update', 'Update employee information', 1, 1),
('delete_employee', 'employee', 'delete', 'Delete employee', 1, 1),
-- Note permissions
('create_note', 'note', 'create', 'Create new note', 1, 1),
('read_note', 'note', 'read', 'View notes', 1, 1),
('update_note', 'note', 'update', 'Update note', 1, 1),
('delete_note', 'note', 'delete', 'Delete note', 1, 1),
-- Class permissions
('create_class', 'class', 'create', 'Create new class', 1, 1),
('read_class', 'class', 'read', 'View class information', 1, 1),
('update_class', 'class', 'update', 'Update class information', 1, 1),
('delete_class', 'class', 'delete', 'Delete class', 1, 1),
-- Role & Permission permissions
('manage_roles', 'role', 'manage', 'Manage roles and permissions', 1, 1),
('read_roles', 'role', 'read', 'View roles and permissions', 1, 1);

-- ============================================
-- 3. ASSIGN PERMISSIONS TO ROLES
-- ============================================
-- Admin gets all permissions
INSERT INTO role_permissions (role_id, permission_id, created_by, updated_by)
SELECT 1, id, 1, 1 FROM permissions;

-- Teacher permissions
INSERT INTO role_permissions (role_id, permission_id, created_by, updated_by)
SELECT 2, id, 1, 1 FROM permissions 
WHERE resource IN ('student', 'note', 'class') AND action IN ('read', 'create', 'update');

-- Principal permissions (similar to admin but can be customized)
INSERT INTO role_permissions (role_id, permission_id, created_by, updated_by)
SELECT 3, id, 1, 1 FROM permissions 
WHERE resource IN ('student', 'employee', 'note', 'class') AND action != 'delete';

-- Secretary permissions
INSERT INTO role_permissions (role_id, permission_id, created_by, updated_by)
SELECT 4, id, 1, 1 FROM permissions 
WHERE resource IN ('student', 'class') AND action IN ('read', 'create', 'update');

-- ============================================
-- 4. INSERT SAMPLE EMPLOYEES
-- ============================================
INSERT INTO employees (employee_code, first_name, last_name, email, phone, date_of_birth, gender, address, hire_date, salary, role_id, is_active, created_by, updated_by) VALUES
('EMP001', 'John', 'Smith', 'john.smith@futurschool.com', '123-456-7890', '1980-05-15', 'male', '123 Main St, City', '2020-01-15', 50000.00, 1, TRUE, 1, 1),
('EMP002', 'Sarah', 'Johnson', 'sarah.johnson@futurschool.com', '123-456-7891', '1985-08-20', 'female', '456 Oak Ave, City', '2020-02-01', 45000.00, 2, TRUE, 1, 1),
('EMP003', 'Michael', 'Brown', 'michael.brown@futurschool.com', '123-456-7892', '1982-03-10', 'male', '789 Pine Rd, City', '2019-09-01', 48000.00, 2, TRUE, 1, 1),
('EMP004', 'Emily', 'Davis', 'emily.davis@futurschool.com', '123-456-7893', '1988-11-25', 'female', '321 Elm St, City', '2021-01-10', 42000.00, 2, TRUE, 1, 1),
('EMP005', 'Robert', 'Wilson', 'robert.wilson@futurschool.com', '123-456-7894', '1975-07-05', 'male', '654 Maple Dr, City', '2018-08-15', 60000.00, 3, TRUE, 1, 1);

-- ============================================
-- 5. INSERT SAMPLE CLASSES
-- ============================================
INSERT INTO classes (class_name, class_code, grade_level, section, capacity, room_number, academic_year, teacher_id, is_active, created_by, updated_by) VALUES
('Grade 1-A', 'G1A', 1, 'A', 30, '101', '2024-2025', 2, TRUE, 1, 1),
('Grade 1-B', 'G1B', 1, 'B', 30, '102', '2024-2025', 3, TRUE, 1, 1),
('Grade 2-A', 'G2A', 2, 'A', 30, '201', '2024-2025', 4, TRUE, 1, 1),
('Grade 2-B', 'G2B', 2, 'B', 30, '202', '2024-2025', 2, TRUE, 1, 1),
('Grade 3-A', 'G3A', 3, 'A', 30, '301', '2024-2025', 3, TRUE, 1, 1);

-- ============================================
-- 6. INSERT SAMPLE STUDENTS
-- ============================================
INSERT INTO students (student_code, first_name, last_name, email, phone, date_of_birth, gender, address, parent_name, parent_phone, parent_email, enrollment_date, class_id, is_active, created_by, updated_by) VALUES
('STU001', 'Alice', 'Williams', 'alice.williams@student.futurschool.com', '111-222-3333', '2017-03-15', 'female', '100 Student St, City', 'John Williams', '111-222-3334', 'john.williams@email.com', '2024-09-01', 1, TRUE, 1, 1),
('STU002', 'Bob', 'Miller', 'bob.miller@student.futurschool.com', '111-222-3335', '2017-05-20', 'male', '200 Student St, City', 'Jane Miller', '111-222-3336', 'jane.miller@email.com', '2024-09-01', 1, TRUE, 1, 1),
('STU003', 'Charlie', 'Garcia', 'charlie.garcia@student.futurschool.com', '111-222-3337', '2016-08-10', 'male', '300 Student St, City', 'Maria Garcia', '111-222-3338', 'maria.garcia@email.com', '2023-09-01', 3, TRUE, 1, 1),
('STU004', 'Diana', 'Martinez', 'diana.martinez@student.futurschool.com', '111-222-3339', '2016-11-25', 'female', '400 Student St, City', 'Carlos Martinez', '111-222-3340', 'carlos.martinez@email.com', '2023-09-01', 3, TRUE, 1, 1),
('STU005', 'Ethan', 'Anderson', 'ethan.anderson@student.futurschool.com', '111-222-3341', '2015-02-14', 'male', '500 Student St, City', 'Lisa Anderson', '111-222-3342', 'lisa.anderson@email.com', '2022-09-01', 5, TRUE, 1, 1);

-- ============================================
-- 7. INSERT SAMPLE NOTES
-- ============================================
INSERT INTO notes (student_id, employee_id, title, content, note_type, priority, is_visible_to_parent, created_by, updated_by) VALUES
(1, 2, 'Excellent Progress', 'Alice has shown excellent progress in mathematics this month. Keep up the great work!', 'academic', 'low', TRUE, 2, 2),
(1, 2, 'Behavior Note', 'Alice was very helpful to classmates today during group activities.', 'behavioral', 'low', TRUE, 2, 2),
(2, 2, 'Needs Improvement', 'Bob needs to focus more on homework completion. Please follow up with parents.', 'academic', 'medium', TRUE, 2, 2),
(3, 4, 'Attendance Concern', 'Charlie has been absent 3 times this month. Please contact parents.', 'attendance', 'high', TRUE, 4, 4),
(4, 4, 'Outstanding Performance', 'Diana performed exceptionally well in the science project presentation.', 'academic', 'low', TRUE, 4, 4),
(5, 3, 'General Note', 'Ethan participated actively in class discussions today.', 'general', 'low', FALSE, 3, 3);


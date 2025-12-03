-- ============================================
-- FuturSchool System Database Schema
-- MySQL Database Creation Script
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS futurschool CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE futurschool;

-- ============================================
-- 1. ROLES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Role name (e.g., admin, teacher, student)',
    description TEXT COMMENT 'Role description',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Whether the role is active',
    created_by INT COMMENT 'User ID who created this record',
    updated_by INT COMMENT 'User ID who last updated this record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 2. PERMISSIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Permission name (e.g., create_student, edit_note)',
    resource VARCHAR(50) NOT NULL COMMENT 'Resource name (e.g., student, note, class)',
    action VARCHAR(50) NOT NULL COMMENT 'Action (e.g., create, read, update, delete)',
    description TEXT COMMENT 'Permission description',
    created_by INT COMMENT 'User ID who created this record',
    updated_by INT COMMENT 'User ID who last updated this record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_resource (resource),
    INDEX idx_action (action),
    INDEX idx_resource_action (resource, action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 3. ROLE_PERMISSIONS TABLE (Many-to-Many)
-- ============================================
CREATE TABLE IF NOT EXISTS role_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    created_by INT COMMENT 'User ID who created this record',
    updated_by INT COMMENT 'User ID who last updated this record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_role_permission (role_id, permission_id),
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 4. EMPLOYEES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Unique employee code/ID',
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other') DEFAULT 'other',
    address TEXT,
    hire_date DATE NOT NULL COMMENT 'Date when employee was hired',
    salary DECIMAL(10, 2) COMMENT 'Employee salary',
    role_id INT NOT NULL COMMENT 'Employee role (teacher, admin, etc.)',
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT COMMENT 'User ID who created this record',
    updated_by INT COMMENT 'User ID who last updated this record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT,
    INDEX idx_employee_code (employee_code),
    INDEX idx_email (email),
    INDEX idx_role_id (role_id),
    INDEX idx_is_active (is_active),
    INDEX idx_full_name (first_name, last_name),
    INDEX idx_hire_date (hire_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 5. CLASSES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS classes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Class name (e.g., Grade 1-A, Grade 2-B)',
    class_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Class code (e.g., G1A, G2B)',
    grade_level INT NOT NULL COMMENT 'Grade level (1, 2, 3, etc.)',
    section VARCHAR(10) COMMENT 'Section (A, B, C, etc.)',
    capacity INT DEFAULT 30 COMMENT 'Maximum number of students',
    room_number VARCHAR(20) COMMENT 'Classroom number',
    academic_year VARCHAR(20) NOT NULL COMMENT 'Academic year (e.g., 2024-2025)',
    teacher_id INT COMMENT 'Class teacher/advisor (employee ID)',
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT COMMENT 'User ID who created this record',
    updated_by INT COMMENT 'User ID who last updated this record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_class_name (class_name),
    INDEX idx_class_code (class_code),
    INDEX idx_grade_level (grade_level),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_academic_year (academic_year),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 6. STUDENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Unique student code/ID',
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    gender ENUM('male', 'female', 'other') DEFAULT 'other',
    address TEXT,
    parent_name VARCHAR(200) COMMENT 'Parent/Guardian name',
    parent_phone VARCHAR(20) COMMENT 'Parent/Guardian phone',
    parent_email VARCHAR(100) COMMENT 'Parent/Guardian email',
    enrollment_date DATE NOT NULL COMMENT 'Date when student enrolled',
    class_id INT COMMENT 'Current class assignment',
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT COMMENT 'User ID who created this record',
    updated_by INT COMMENT 'User ID who last updated this record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL,
    INDEX idx_student_code (student_code),
    INDEX idx_email (email),
    INDEX idx_class_id (class_id),
    INDEX idx_is_active (is_active),
    INDEX idx_full_name (first_name, last_name),
    INDEX idx_enrollment_date (enrollment_date),
    INDEX idx_parent_phone (parent_phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 7. NOTES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL COMMENT 'Student this note belongs to',
    employee_id INT NOT NULL COMMENT 'Employee/Teacher who created the note',
    title VARCHAR(200) NOT NULL COMMENT 'Note title',
    content TEXT NOT NULL COMMENT 'Note content',
    note_type ENUM('academic', 'behavioral', 'attendance', 'general') DEFAULT 'general' COMMENT 'Type of note',
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium' COMMENT 'Note priority',
    is_visible_to_parent BOOLEAN DEFAULT FALSE COMMENT 'Whether parent can see this note',
    created_by INT COMMENT 'User ID who created this record',
    updated_by INT COMMENT 'User ID who last updated this record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE RESTRICT,
    INDEX idx_student_id (student_id),
    INDEX idx_employee_id (employee_id),
    INDEX idx_note_type (note_type),
    INDEX idx_priority (priority),
    INDEX idx_created_at (created_at),
    INDEX idx_student_created (student_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ADD FOREIGN KEY CONSTRAINTS FOR created_by/updated_by
-- (Optional: If you want to track which user created/updated records)
-- ============================================
-- Note: These are commented out as they would create circular dependencies
-- You can uncomment and create a users table if needed, or use employee_id
ALTER TABLE roles ADD FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE roles ADD FOREIGN KEY (updated_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE permissions ADD FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE permissions ADD FOREIGN KEY (updated_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE role_permissions ADD FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE role_permissions ADD FOREIGN KEY (updated_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE employees ADD FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE employees ADD FOREIGN KEY (updated_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE classes ADD FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE classes ADD FOREIGN KEY (updated_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE students ADD FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE students ADD FOREIGN KEY (updated_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE notes ADD FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL;
ALTER TABLE notes ADD FOREIGN KEY (updated_by) REFERENCES employees(id) ON DELETE SET NULL;


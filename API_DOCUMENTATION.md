# FuturSchool System API Documentation

Complete API documentation for the dashboard endpoints.

## Base URL
```
http://localhost:3000/api
```

## Authentication

Most endpoints require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your-token>
```

---

## 📋 Dashboard Endpoints

### 1. Employees

#### Get All Employees
```
GET /api/employees
```
**Access:** Admin, Principal  
**Query Parameters:**
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10)
- `search` - Search by name, email, or employee code
- `role_id` - Filter by role ID
- `is_active` - Filter by active status (true/false)

**Response:**
```json
{
  "success": true,
  "message": "Employees retrieved successfully",
  "data": {
    "employees": [...],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 50,
      "pages": 5
    }
  }
}
```

#### Get Employee by ID
```
GET /api/employees/:id
```
**Access:** Authenticated users

#### Create Employee
```
POST /api/employees
```
**Access:** Admin  
**Body:**
```json
{
  "employee_code": "EMP006",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@futurschool.com",
  "password": "password123",
  "phone": "123-456-7890",
  "date_of_birth": "1990-01-01",
  "gender": "male",
  "address": "123 Main St",
  "hire_date": "2024-01-01",
  "salary": 50000.00,
  "role_id": 2
}
```

#### Update Employee
```
PUT /api/employees/:id
```
**Access:** Admin  
**Body:** (All fields optional except those you want to update)

#### Delete Employee
```
DELETE /api/employees/:id
```
**Access:** Admin  
**Note:** Soft delete (sets is_active to false)

---

### 2. Classes

#### Get All Classes
```
GET /api/classes
```
**Access:** Authenticated users  
**Query Parameters:**
- `page`, `limit`, `search` - Pagination and search
- `grade_level` - Filter by grade level
- `academic_year` - Filter by academic year
- `is_active` - Filter by active status

**Response includes:** Teacher info, student count

#### Get Class by ID
```
GET /api/classes/:id
```
**Access:** Authenticated users

#### Create Class
```
POST /api/classes
```
**Access:** Admin  
**Body:**
```json
{
  "class_name": "Grade 4-A",
  "class_code": "G4A",
  "grade_level": 4,
  "section": "A",
  "capacity": 30,
  "room_number": "401",
  "academic_year": "2024-2025",
  "teacher_id": 2
}
```

#### Update Class
```
PUT /api/classes/:id
```
**Access:** Admin

#### Delete Class
```
DELETE /api/classes/:id
```
**Access:** Admin

---

### 3. Students

#### Get All Students
```
GET /api/students
```
**Access:** Authenticated users  
**Query Parameters:**
- `page`, `limit`, `search` - Pagination and search
- `class_id` - Filter by class
- `is_active` - Filter by active status

**Response includes:** Class info

#### Get Student by ID
```
GET /api/students/:id
```
**Access:** Authenticated users

#### Create Student
```
POST /api/students
```
**Access:** Admin  
**Body:**
```json
{
  "student_code": "STU006",
  "first_name": "Jane",
  "last_name": "Smith",
  "email": "jane.smith@student.futurschool.com",
  "phone": "111-222-3333",
  "date_of_birth": "2015-05-15",
  "gender": "female",
  "address": "456 Student St",
  "parent_name": "John Smith",
  "parent_phone": "111-222-3334",
  "parent_email": "john.smith@email.com",
  "enrollment_date": "2024-09-01",
  "class_id": 1
}
```

#### Update Student
```
PUT /api/students/:id
```
**Access:** Admin

#### Delete Student
```
DELETE /api/students/:id
```
**Access:** Admin

---

### 4. Roles

#### Get All Roles
```
GET /api/roles
```
**Access:** Admin  
**Response includes:** Employee count, permission count

#### Get Role by ID
```
GET /api/roles/:id
```
**Access:** Admin  
**Response includes:** All permissions assigned to the role

#### Create Role
```
POST /api/roles
```
**Access:** Admin  
**Body:**
```json
{
  "name": "coordinator",
  "description": "Academic Coordinator",
  "is_active": true,
  "permission_ids": [1, 2, 3, 5]
}
```

#### Update Role
```
PUT /api/roles/:id
```
**Access:** Admin  
**Body:** Can update name, description, is_active, and permission_ids

#### Delete Role
```
DELETE /api/roles/:id
```
**Access:** Admin  
**Note:** Cannot delete if assigned to active employees

---

### 5. Permissions

#### Get All Permissions
```
GET /api/permissions
```
**Access:** Admin  
**Query Parameters:**
- `resource` - Filter by resource (student, employee, etc.)
- `action` - Filter by action (create, read, update, delete)

#### Get Grouped Permissions
```
GET /api/permissions/grouped
```
**Access:** Admin  
**Response:** Permissions grouped by resource

#### Get Permission by ID
```
GET /api/permissions/:id
```
**Access:** Admin  
**Response includes:** All roles that have this permission

#### Create Permission
```
POST /api/permissions
```
**Access:** Admin  
**Body:**
```json
{
  "name": "view_reports",
  "resource": "report",
  "action": "read",
  "description": "View system reports"
}
```

#### Update Permission
```
PUT /api/permissions/:id
```
**Access:** Admin

#### Delete Permission
```
DELETE /api/permissions/:id
```
**Access:** Admin  
**Note:** Cannot delete if assigned to roles

---

## 🔐 Authentication Endpoints

### Login
```
POST /api/auth/login
```
**Body:**
```json
{
  "email": "john.smith@futurschool.com",
  "password": "password123"
}
```

### Get Current User
```
GET /api/auth/me
```
**Access:** Authenticated users

### Logout
```
POST /api/auth/logout
```
**Access:** Authenticated users

---

## 📊 Common Features

### Pagination
All list endpoints support pagination:
- `page` - Page number (starts at 1)
- `limit` - Items per page

### Search
Most list endpoints support search:
- `search` - Searches relevant fields (names, codes, emails)

### Filtering
Endpoints support various filters:
- `is_active` - Filter by active status
- Resource-specific filters (role_id, class_id, etc.)

### Soft Delete
Delete operations perform soft deletes (set `is_active = false`) instead of hard deletes.

---

## 🚫 Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Error message"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Not authorized to access this route"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "User role 'teacher' is not authorized to access this route"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Resource not found"
}
```

### 500 Server Error
```json
{
  "success": false,
  "error": "Internal server error"
}
```

---

## 📝 Notes

1. **All timestamps** are in ISO 8601 format
2. **All dates** should be in YYYY-MM-DD format
3. **Password hashing** is handled automatically on create/update
4. **JWT tokens** expire after 7 days (configurable)
5. **Soft deletes** preserve data integrity
6. **Role-based access** is enforced on all endpoints

---

## 🧪 Testing with cURL

### Login Example
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.smith@futurschool.com","password":"password123"}'
```

### Get Employees (with token)
```bash
curl -X GET http://localhost:3000/api/employees \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Create Employee
```bash
curl -X POST http://localhost:3000/api/employees \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "employee_code": "EMP007",
    "first_name": "Test",
    "last_name": "User",
    "email": "test@futurschool.com",
    "password": "password123",
    "hire_date": "2024-01-01",
    "role_id": 2
  }'
```


# Logic Errors Report

## 🔴 Critical Issues

### 1. **Employee Controller - `updateEmployee()` - Empty Updates Array**
**Location:** `controllers/employeeController.js:309`
**Issue:** If no fields are provided to update, the `updates` array will only contain `updated_by`, causing an invalid SQL query.
**Fix:** Check if there are actual updates before executing.

### 2. **Employee Controller - `generateEmployeeCode()` - Potential Infinite Recursion**
**Location:** `controllers/employeeController.js:148`
**Issue:** If somehow all employee codes are taken (unlikely but possible), this could recurse infinitely.
**Fix:** Add a maximum retry limit or better uniqueness check.

### 3. **Student Controller - Email Uniqueness Check**
**Location:** `controllers/studentController.js:139`
**Issue:** Checking `email || ''` could match empty strings, causing false positives.
**Fix:** Only check email if it's provided and not empty.

### 4. **Student Controller - `updateStudent()` - Empty Updates Array**
**Location:** `controllers/studentController.js:250`
**Issue:** Same as employee controller - empty updates array.

### 5. **Class Controller - `updateClass()` - Empty Updates Array**
**Location:** `controllers/classController.js:245`
**Issue:** Same as above.

### 6. **Class Controller - Missing Teacher Validation**
**Location:** `controllers/classController.js:169`
**Issue:** When assigning a teacher_id, there's no validation that the employee exists or is a teacher.
**Fix:** Validate teacher exists and has appropriate role.

### 7. **Role Controller - Permission Validation Missing**
**Location:** `controllers/roleController.js:94`
**Issue:** When assigning permissions, there's no validation that permission IDs exist.
**Fix:** Validate all permission IDs exist before inserting.

### 8. **Role Controller - `updateRole()` - Empty Updates**
**Location:** `controllers/roleController.js:155`
**Issue:** Has a check for `updates.length > 1` but this is good. However, if only permission_ids are updated, the role itself won't be updated but updated_by will be set.

### 9. **Permission Controller - Redundant Delete**
**Location:** `controllers/permissionController.js:206`
**Issue:** Deletes `role_permissions` twice - once explicitly and once should be handled by CASCADE (though being explicit is fine, just redundant).

### 10. **Employee/Student/Class Controllers - Duplicate Check Logic**
**Location:** Multiple locations
**Issue:** When checking duplicates in update methods, using `employee_code || ''` or `email || ''` could cause issues if one is empty string.
**Fix:** Only check fields that are actually provided.

## 🟡 Medium Priority Issues

### 11. **Student Controller - Missing Auto-Generate Student Code**
**Location:** `controllers/studentController.js:114`
**Issue:** Unlike employees, students don't have auto-generated codes. Should be consistent.

### 12. **Class Controller - Missing Capacity Validation**
**Location:** `controllers/classController.js:166`
**Issue:** No validation that capacity is a positive number.

### 13. **Employee Controller - Password Validation**
**Location:** `controllers/employeeController.js:199`
**Issue:** No minimum password length or strength validation.

### 14. **All Controllers - Missing Input Sanitization**
**Issue:** No validation for SQL injection (though using parameterized queries helps), but no validation for XSS in text fields.

### 15. **Role Controller - Race Condition in Permission Assignment**
**Location:** `controllers/roleController.js:93-100`
**Issue:** If multiple requests try to assign permissions simultaneously, could cause issues. Should use transactions.

## 🟢 Minor Issues / Improvements

### 16. **All Controllers - Missing Transaction Support**
**Issue:** Multi-step operations (like creating role with permissions) should use database transactions.

### 17. **Employee Controller - `generateEmployeeCode()` - Case Sensitivity**
**Location:** `controllers/employeeController.js:123`
**Issue:** Only checks for 'EMP%' - what if someone manually creates 'emp001'? Should be case-insensitive or enforce uppercase.

### 18. **All Controllers - Missing Audit Trail**
**Issue:** While `created_by` and `updated_by` are set, there's no logging of what changed.

### 19. **Class Controller - Missing Student Count Validation**
**Issue:** When updating class capacity, should check if current student count exceeds new capacity.

### 20. **All Controllers - Missing Soft Delete Validation**
**Issue:** When soft deleting, should check for related records (e.g., can't delete class with active students).


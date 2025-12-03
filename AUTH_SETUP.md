# Authentication Setup Guide

This guide will help you set up the employee login system for FuturSchool.

## Step 1: Install Dependencies

```bash
npm install
```

This will install:
- `bcryptjs` - For password hashing
- `jsonwebtoken` - For JWT token generation

## Step 2: Add Password Column to Database

Run the migration to add the password field to the employees table:

**In phpMyAdmin:**
1. Select the `futurschool` database
2. Go to SQL tab
3. Copy and paste the contents of `database/migrations/add_password_to_employees.sql`
4. Click "Go"

**Or via command line:**
```bash
mysql -u root -p futurschool < database/migrations/add_password_to_employees.sql
```

## Step 3: Set Initial Passwords

After running the migration, set initial passwords for employees:

```bash
node scripts/setup-passwords.js
```

This will set a default password `password123` for all employees. **Change these passwords after first login!**

## Step 4: Configure Environment Variables

Add JWT configuration to your `.env` file:

```env
# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRE=7d
```

**Important:** Use a strong, random secret key in production!

## Step 5: Test the Login

Start your server:
```bash
npm run dev
```

### Login Endpoint

**POST** `/api/auth/login`

**Request Body:**
```json
{
  "email": "john.smith@futurschool.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "employee": {
      "id": 1,
      "employee_code": "EMP001",
      "first_name": "John",
      "last_name": "Smith",
      "email": "john.smith@futurschool.com",
      "role_id": 1,
      "role_name": "admin"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

### Get Current User

**GET** `/api/auth/me`

**Headers:**
```
Authorization: Bearer <your-token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Employee retrieved successfully",
  "data": {
    "employee": {
      "id": 1,
      "employee_code": "EMP001",
      "first_name": "John",
      "last_name": "Smith",
      "email": "john.smith@futurschool.com",
      "role_id": 1,
      "role_name": "admin"
    }
  }
}
```

### Logout

**POST** `/api/auth/logout`

**Headers:**
```
Authorization: Bearer <your-token>
```

**Note:** Since we're using JWT, logout is handled client-side by removing the token.

## Protecting Routes

To protect a route, use the `protect` middleware:

```javascript
const { protect } = require('../middleware/auth');

router.get('/protected-route', protect, yourController);
```

To restrict by role, use the `authorize` middleware:

```javascript
const { protect, authorize } = require('../middleware/auth');

router.get('/admin-only', protect, authorize('admin', 'principal'), yourController);
```

## Security Notes

1. **Change Default Passwords**: All employees start with password `password123`. Change these immediately!
2. **JWT Secret**: Use a strong, random secret key in production
3. **HTTPS**: Always use HTTPS in production to protect tokens
4. **Token Expiration**: Tokens expire after 7 days (configurable via `JWT_EXPIRE`)
5. **Password Hashing**: Passwords are hashed using bcrypt with 10 salt rounds

## Troubleshooting

### "Invalid email or password"
- Check that the employee exists and is active
- Verify the password is correct
- Ensure the password column was added to the database

### "Not authorized to access this route"
- Check that the Authorization header is present: `Authorization: Bearer <token>`
- Verify the token is valid and not expired
- Ensure the employee account is active

### "Employee not found or inactive"
- The employee account may have been deactivated
- Check the `is_active` field in the employees table


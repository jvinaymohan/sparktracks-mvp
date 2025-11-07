# 🔐 ADMIN PANEL ACCESS GUIDE

**Version:** 2.5.0  
**Last Updated:** November 5, 2025  

---

## 🚪 ADMIN PANEL ACCESS

### Admin Login URL:
```
https://sparktracks-mvp.web.app/admin/login
```

### Current Admin Credentials:

**Email:** `admin@sparktracks.com`  
**Password:** `ChangeThisPassword2024!`

---

## ⚠️ CRITICAL SECURITY WARNING!

### 🚨 THIS PASSWORD IS TEMPORARY AND INSECURE!

**Issues:**
1. **Hardcoded in source code** (`lib/providers/admin_provider.dart`)
2. **Visible on GitHub** (public repository)
3. **No real authentication** (placeholder logic)

**Risk Level:** HIGH  
**Status:** ⏸️ NEEDS TO BE FIXED BEFORE PRODUCTION

---

## 🛠️ ADMIN DASHBOARD FEATURES

### What You Can Do:

#### 1. **User Management**
- View all users (Parents, Children, Coaches)
- Search users by email/name
- View user details
- Delete users (with confirmation)
- Filter by user type

#### 2. **Feedback Management**
- View all user feedback submissions
- Mark feedback as reviewed
- Add admin notes
- Track feedback status (pending/reviewed/resolved)

#### 3. **System Settings**
- Toggle maintenance mode
- Enable/disable new registrations
- Set max children per parent
- Set max classes per coach
- Feature flags:
  - Messaging enabled
  - Achievements enabled
  - Analytics enabled
  - Video classes enabled

#### 4. **Analytics & Overview**
- Total users count
- Active users today
- Feedback submissions count
- Quick stats dashboard

---

## 📋 HOW TO ACCESS

### Step 1: Navigate to Admin Login
```
https://sparktracks-mvp.web.app/admin/login
```

### Step 2: Enter Credentials
- **Email:** admin@sparktracks.com
- **Password:** ChangeThisPassword2024!

### Step 3: Access Dashboard
After login, you'll be redirected to:
```
https://sparktracks-mvp.web.app/admin/dashboard
```

---

## 🎯 ADMIN DASHBOARD TABS

### Tab 1: Overview
- **Total Users:** Count of all registered users
- **Active Today:** Users who logged in today
- **Pending Feedback:** Unreviewed feedback count
- Quick action buttons

### Tab 2: Users
- **Search:** Find users by email or name
- **Filter:** By user type (All, Parent, Child, Coach)
- **Actions:** 
  - View details
  - Delete user (requires confirmation)
- **User List:** All registered users with:
  - Name
  - Email
  - User type
  - Registration date

### Tab 3: Feedback
- **Feedback List:** All submitted feedback
- **Status Filter:** Pending / Reviewed / Resolved
- **Actions:**
  - Mark as reviewed
  - Add admin notes
  - View user details
- **Feedback Details:**
  - User name & email
  - Category (Bug, Feature Request, General)
  - Description
  - Submission date
  - Status

### Tab 4: Settings
- **Maintenance Mode:** Disable the app for updates
- **Registrations:** Allow/block new user signups
- **Limits:**
  - Max children per parent (default: 10)
  - Max classes per coach (default: 50)
- **Feature Flags:**
  - Enable/disable messaging
  - Enable/disable achievements
  - Enable/disable analytics
  - Enable/disable video classes

---

## 🔧 COMMON ADMIN TASKS

### Task 1: Review User Feedback
```
1. Go to Admin Dashboard
2. Click "Feedback" tab
3. Select feedback to review
4. Click "Mark as Reviewed"
5. Add admin notes (optional)
```

### Task 2: Delete Test Users
```
1. Go to Admin Dashboard
2. Click "Users" tab
3. Search for user by email
4. Click 3-dot menu → "Delete"
5. Confirm deletion
```

### Task 3: Toggle Feature Flags
```
1. Go to Admin Dashboard
2. Click "Settings" tab
3. Toggle desired feature switch
4. Changes apply immediately
```

### Task 4: Enable Maintenance Mode
```
1. Go to Admin Dashboard
2. Click "Settings" tab
3. Toggle "Maintenance Mode"
4. App will show maintenance message to all users
```

---

## ⚠️ KNOWN LIMITATIONS

### Current Implementation:
1. **No Real Authentication**
   - Uses hardcoded email/password
   - No Firebase Admin SDK integration
   - No password reset functionality

2. **No Audit Logging**
   - Admin actions not logged
   - No history of changes

3. **Limited User Management**
   - Cannot create users from admin panel
   - Cannot reset user passwords
   - Cannot modify user roles

4. **No Multi-Admin Support**
   - Only one admin account
   - No admin roles/permissions
   - No admin user management

5. **Feedback Not Integrated with Firebase**
   - Uses in-memory storage
   - Data lost on refresh
   - Need to integrate with Firestore

---

## 🚨 URGENT: FIX ADMIN AUTHENTICATION

### Option 1: Environment Variable (Quick Fix - 15 min)

**Update `lib/providers/admin_provider.dart`:**
```dart
Future<bool> loginAdmin(String email, String password) async {
  const adminEmail = String.fromEnvironment('ADMIN_EMAIL', defaultValue: 'admin@sparktracks.com');
  const adminPassword = String.fromEnvironment('ADMIN_PASSWORD');
  
  if (email == adminEmail && password == adminPassword) {
    // Login successful
    return true;
  }
  return false;
}
```

**Build with environment variables:**
```bash
flutter build web --dart-define=ADMIN_EMAIL=your@email.com --dart-define=ADMIN_PASSWORD=YourSecurePassword123!
```

---

### Option 2: Firebase Custom Claims (Recommended - 60 min)

**1. Set custom claims for admin user:**
```bash
# Using Firebase Admin SDK
firebase functions:shell

> admin.auth().setCustomUserClaims('user-id-here', {admin: true})
```

**2. Update admin_provider.dart:**
```dart
Future<bool> loginAdmin(String email, String password) async {
  try {
    // Regular Firebase login
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    
    // Check custom claims
    final idTokenResult = await userCredential.user?.getIdTokenResult();
    final isAdmin = idTokenResult?.claims?['admin'] == true;
    
    if (isAdmin) {
      _currentAdmin = AdminUser(/* ... */);
      return true;
    }
  } catch (e) {
    print('Admin login error: $e');
  }
  return false;
}
```

---

### Option 3: Separate Admin Table (60 min)

**1. Create `admins` collection in Firestore:**
```javascript
// Firestore structure
admins/
  {adminId}/
    email: "admin@sparktracks.com"
    name: "Admin Name"
    role: "superAdmin"
    passwordHash: "bcrypt-hashed-password"
    createdAt: timestamp
```

**2. Update security rules:**
```javascript
match /admins/{adminId} {
  allow read: if request.auth.uid == adminId;
  // No write access via client
}
```

**3. Use Firebase Auth + Firestore check:**
```dart
Future<bool> loginAdmin(String email, String password) async {
  // Use Firebase Auth for login
  final userCredential = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
  
  // Check if user exists in admins collection
  final adminDoc = await FirebaseFirestore.instance
      .collection('admins')
      .doc(userCredential.user!.uid)
      .get();
  
  if (adminDoc.exists) {
    _currentAdmin = AdminUser.fromJson(adminDoc.data()!);
    return true;
  }
  return false;
}
```

---

## 🎯 RECOMMENDED ACTION PLAN

### Today (Critical):
1. **Change the password** if you haven't already
2. **Test admin login** with current credentials
3. **Document who has access**

### This Week (High Priority):
4. **Implement Option 1** (environment variable) - Quick security fix
5. **Add to .gitignore:** `lib/providers/admin_provider.dart`
6. **Rotate the password** after fixing

### Next Week (Medium Priority):
7. **Implement Option 2 or 3** (proper authentication)
8. **Add audit logging** for admin actions
9. **Add multi-admin support**

---

## 📝 CURRENT ADMIN CODE LOCATION

**File:** `lib/providers/admin_provider.dart`  
**Lines:** 41-59  
**Function:** `loginAdmin(String email, String password)`

**Hardcoded credentials (line 45):**
```dart
if (email == 'admin@sparktracks.com' && password == 'ChangeThisPassword2024!') {
  // ... login logic
}
```

---

## 🧪 TESTING ADMIN PANEL

### Test Checklist:
- [ ] Navigate to `/admin/login`
- [ ] Login with credentials
- [ ] View overview dashboard
- [ ] Search for users
- [ ] View feedback (if any exists)
- [ ] Toggle a feature flag
- [ ] Logout and verify redirect

---

## 🆘 TROUBLESHOOTING

### Issue: "Cannot access admin panel"
**Solution:** Make sure you're using the correct URL:
```
https://sparktracks-mvp.web.app/admin/login
```
(Not `/admin-login` or `/adminlogin`)

### Issue: "Invalid credentials"
**Solution:** Double-check the email and password:
- Email: `admin@sparktracks.com`
- Password: `ChangeThisPassword2024!`
- Case-sensitive!

### Issue: "Redirects to home after login"
**Solution:** Check browser console for errors. The admin routing should redirect to `/admin/dashboard` after successful login.

### Issue: "Admin dashboard is empty"
**Solution:** This is normal if no users have registered yet. Create a test parent account first.

---

## ✅ SUMMARY

**Admin URL:** https://sparktracks-mvp.web.app/admin/login  
**Email:** admin@sparktracks.com  
**Password:** ChangeThisPassword2024!  

**⚠️ SECURITY WARNING:** This password MUST be changed before production!

**Features:**
- User management
- Feedback review
- System settings
- Feature flags

**Next Steps:**
1. Test admin login
2. Review feedback (if any)
3. Fix authentication (see Option 1, 2, or 3 above)

---

**For questions or issues, refer to the security audit: `SECURITY_AUDIT_v2.5.0.md`**


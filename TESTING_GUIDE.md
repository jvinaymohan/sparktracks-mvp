# 🧪 SparkTracks Testing Guide

## 🔐 Authentication Testing

### ✅ **Fixed Issues:**
1. ✅ Firestore serialization for nested objects (NotificationPreferences, PaymentProfile)
2. ✅ Password reset email functionality
3. ✅ User registration with proper Firestore storage
4. ✅ Login after password reset

---

## 📋 **Complete Testing Flow**

### **1. Clean Slate Test** 🆕

Before testing, you may want to delete old test accounts from Firebase Console:
1. Go to: https://console.firebase.google.com/
2. Select: `sparktracks-mvp`
3. **Authentication** → **Users** tab
4. Delete any test accounts you want to remove
5. **Firestore Database** → Delete old user documents if needed

---

### **2. Registration Test** 📝

**Steps:**
1. Open the app in Chrome
2. Click **"Get Started"** on landing page
3. Fill in registration form:
   - Name: `Test Parent`
   - Email: `testparent@example.com` (use your real email to test password reset)
   - Password: `Test1234!`
   - Role: `Parent`
4. Click **"Register"**

**Expected Result:**
- ✅ Registration succeeds
- ✅ Success message appears
- ✅ User data saved to Firestore
- ✅ Email verification sent
- ✅ No console errors

**Check Firestore:**
- Go to Firebase Console → Firestore Database
- You should see a new document in the `users` collection
- Document should have all fields including nested `notificationPreferences` and `paymentProfile`

---

### **3. Email Verification Test** 📧

**Steps:**
1. Check your email inbox
2. Look for verification email from: `noreply@sparktracks-mvp.firebaseapp.com`
3. **Check SPAM folder if not in inbox**
4. Click the verification link

**Expected Result:**
- ✅ Email received (check spam!)
- ✅ Link opens Firebase verification page
- ✅ Verification successful message

---

### **4. Login Test** 🔑

**Steps:**
1. Go to login screen
2. Enter credentials:
   - Email: `testparent@example.com`
   - Password: `Test1234!`
3. Click **"Login"**

**Expected Result:**
- ✅ Login succeeds
- ✅ Redirected to Parent Dashboard
- ✅ No console errors
- ✅ User data loaded from Firestore

**Check Console:**
- Should see: `Login successful: [user data]`
- Should NOT see any Firestore errors

---

### **5. Password Reset Test** 🔄

**Steps:**
1. **Logout** (if logged in)
2. Go to **Login** screen
3. Click **"Forgot Password?"**
4. Enter your email: `testparent@example.com`
5. Click **"Send Reset Link"**
6. Check console for debug messages
7. Check your email (and SPAM folder!)

**Expected Result:**
- ✅ Success message shown
- ✅ Console shows: `Password reset email sent successfully`
- ✅ Email received within 1-5 minutes
- ✅ Email from: `noreply@sparktracks-mvp.firebaseapp.com`
- ✅ Subject: "Reset your password"

**Email Contents:**
- Link to reset password
- Link expires in 1 hour
- Clicking link opens Firebase password reset page

**Steps After Receiving Email:**
1. Click the reset link in email
2. Enter new password: `NewTest1234!`
3. Confirm password
4. Click **"Save"**
5. Return to app
6. Try logging in with **new password**

**Expected Result:**
- ✅ Password reset successful
- ✅ Login with new password works
- ✅ Access to dashboard
- ✅ All user data intact

---

## 🔍 **Troubleshooting**

### **Issue: Registration fails with "An account already exists"**

**Solution:**
1. Go to Firebase Console → Authentication → Users
2. Find and delete the existing account
3. Try registering again

OR

1. Use a different email address
2. Or use the "Forgot Password" flow to reset the password

---

### **Issue: Registration fails with "Unsupported field value"**

**Solution:**
- ✅ **FIXED!** The issue was in `user_model.g.dart`
- Nested objects now properly call `.toJson()`
- If you still see this, run: `dart run build_runner build --delete-conflicting-outputs`

---

### **Issue: Password reset email not received**

**Check These:**
1. ✅ **SPAM/JUNK folder** (most common!)
2. ✅ Promotions tab (Gmail)
3. ✅ All Mail folder
4. ✅ Search for: "firebase" or "password reset"
5. ✅ Wait 5 minutes (sometimes delayed)
6. ✅ Check you entered correct email

**Email Details:**
- From: `noreply@sparktracks-mvp.firebaseapp.com`
- Subject: "Reset your password"
- Contains: Password reset link
- Expires: 1 hour

**If Still Not Received:**
1. Check Firebase Console → Authentication → Templates
2. Verify "Password reset" template is enabled
3. Try sending again
4. Check Firebase Console → Authentication → Users
   - Verify the email exists
   - Check if email is verified

---

### **Issue: Login fails after password reset**

**Solution:**
- ✅ **FIXED!** Firestore serialization now works
- Make sure you're using the NEW password
- Clear browser cache and try again
- Check console for specific error messages

**Verify in Firebase:**
1. Go to Authentication → Users
2. Find your user
3. Click "Reset Password" to manually reset if needed

---

## 🎯 **Testing Checklist**

Use this checklist to verify everything works:

### **Authentication Flow:**
- [ ] Landing page loads without errors
- [ ] Can navigate to registration
- [ ] Registration form validates properly
- [ ] Registration succeeds with valid data
- [ ] User document created in Firestore
- [ ] Verification email sent
- [ ] Can log in with registered credentials
- [ ] User data loads from Firestore
- [ ] Dashboard displays correctly
- [ ] Can log out

### **Password Reset Flow:**
- [ ] "Forgot Password?" link works
- [ ] Reset form validates email
- [ ] Reset email sent successfully
- [ ] Email received (check spam!)
- [ ] Reset link works in email
- [ ] Can set new password
- [ ] Can log in with new password
- [ ] User data persists after reset

### **Data Persistence:**
- [ ] User data saved to Firestore on registration
- [ ] User data loads from Firestore on login
- [ ] Nested objects (notificationPreferences, paymentProfile) serialized correctly
- [ ] No Firestore errors in console
- [ ] Email verification status persists
- [ ] User profile data intact after password reset

---

## 🐛 **Debug Console Messages**

### **Expected Console Messages:**

**Registration:**
```
Registration successful
User document created in Firestore
```

**Login:**
```
Login successful: {user data}
```

**Password Reset:**
```
Sending password reset email to: [email]
Password reset email sent successfully
```

### **Error Messages to Watch For:**

**❌ Bad (means issue):**
```
Registration failed: [cloud_firestore/invalid-argument] Unsupported field value
Registration error: Exception: An account already exists
Login failed: [firebase_auth/user-not-found]
Login failed: [firebase_auth/wrong-password]
```

**✅ Good (means working):**
```
No Firestore errors
Login successful
Password reset email sent successfully
```

---

## 📊 **Verify in Firebase Console**

### **Check Authentication:**
1. Go to: https://console.firebase.google.com/
2. Select: `sparktracks-mvp`
3. **Authentication** → **Users**
4. Verify new user appears
5. Check email verification status

### **Check Firestore:**
1. **Firestore Database** → **Data** tab
2. Collection: `users`
3. Find your user document
4. Verify fields:
   - ✅ id, email, name, type
   - ✅ notificationPreferences (object with fields)
   - ✅ paymentProfile (object with fields)
   - ✅ createdAt, updatedAt (timestamps)
   - ✅ emailVerified (boolean)

---

## ✅ **Success Criteria**

**Everything is working if:**
1. ✅ Registration completes without errors
2. ✅ User document appears in Firestore with all fields
3. ✅ Verification email received
4. ✅ Login works after registration
5. ✅ Password reset email received (check spam!)
6. ✅ Login works after password reset
7. ✅ Dashboard loads with user data
8. ✅ No console errors
9. ✅ All Firestore data properly structured

---

## 🚀 **Next Steps After Testing**

Once authentication is verified:
1. ✅ Test child management (add/edit children)
2. ✅ Test task creation and assignment
3. ✅ Test points system
4. ✅ Test financial ledger
5. ✅ Test coach dashboard
6. ✅ Test class management

---

## 📞 **Need Help?**

If you encounter issues:
1. Check this guide's troubleshooting section
2. Check browser console for errors
3. Check Firebase Console for user/data status
4. Verify email in SPAM folder
5. Try with a different email address
6. Clear browser cache and retry

**Common Fixes:**
- Clear browser cache: `Ctrl+Shift+Delete` (or `Cmd+Shift+Delete` on Mac)
- Hard refresh: `Ctrl+Shift+R` (or `Cmd+Shift+R` on Mac)
- Incognito/Private window
- Different browser

---

**Last Updated:** After fixing Firestore serialization
**Status:** ✅ All authentication flows working


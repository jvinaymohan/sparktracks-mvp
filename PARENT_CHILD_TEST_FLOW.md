# Parent-Child Account Creation & Login Test Flow

## 🎯 Complete Test Flow

### Step 1: Create Parent Account

1. **Open app in Chrome** (already running)
2. **Click "Sign Up"** button on landing page
3. **Fill in registration form:**
   - First Name: `Test`
   - Last Name: `Parent`
   - Email: `testparent@example.com`
   - Password: `test123456` (min 6 characters)
   - User Type: Select **"Parent"**
4. **Click "Create Account"**
5. **Result:** You'll be redirected to Parent Dashboard

### Step 2: Create Child Account (As Parent)

1. **In Parent Dashboard**, click on **"Children"** tab
2. **Click "Add Child" button** (+ icon)
3. **Fill in child information:**
   - Child Name: `Emma Johnson`
   - Date of Birth: Select a date (e.g., March 15, 2015)
   - Pick a color: Choose any color (e.g., Green)
4. **Click "Save Child"**
5. **IMPORTANT:** A dialog will appear with:
   - Auto-generated email: `emma.######@sparktracks.child`
   - Auto-generated password: `Emma0315` (FirstName + MMDD format)
   - **COPY THESE CREDENTIALS** - you'll need them to login as the child

### Step 3: Re-authenticate Parent (Important!)

⚠️ **Known Issue:** After creating a child account, Firebase signs you out.

**Solution:**
1. You'll be automatically logged out or redirected
2. **Click "Sign In"** to return to login page
3. **Login again as parent:**
   - Email: `testparent@example.com`
   - Password: `test123456`
4. You should be back in Parent Dashboard

### Step 4: Login as Child

1. **Logout** from parent account (click logout icon)
2. **Go to Login page**
3. **Login with child credentials:**
   - Email: `emma.######@sparktracks.child` (use the email from Step 2)
   - Password: `Emma0315` (the password from Step 2)
4. **Result:** You'll be redirected to Child Dashboard

---

## 📱 Expected Behavior

### Parent Dashboard Features:
- **Overview Tab:** Summary of children and tasks
- **Children Tab:** List of children, add/edit/delete
- **Tasks Tab:** Create and manage tasks for children
- **Classes Tab:** View and manage classes

### Child Dashboard Features:
- **View assigned tasks**
- **Mark tasks as complete**
- **View calendar**
- **See points balance**
- **View task history**

---

## 🔧 Testing Checklist

### Parent Account Tests
- [ ] Register new parent account
- [ ] Login as parent
- [ ] View parent dashboard
- [ ] Access all dashboard tabs
- [ ] Logout successfully

### Child Creation Tests
- [ ] Click "Add Child" from parent dashboard
- [ ] Fill in child name
- [ ] Select date of birth
- [ ] Choose color
- [ ] Save child successfully
- [ ] See credentials dialog
- [ ] Copy child credentials

### Child Account Tests
- [ ] Logout from parent account
- [ ] Login with child credentials
- [ ] View child dashboard
- [ ] See assigned tasks (if any)
- [ ] Logout successfully

### Task Management Tests (Optional)
- [ ] Login as parent
- [ ] Create a task for child
- [ ] Assign task to specific child
- [ ] Set due date
- [ ] Set reward points
- [ ] Save task
- [ ] Login as child
- [ ] See the assigned task
- [ ] Mark task as complete

---

## 🐛 Known Issues & Solutions

### Issue 1: Parent Gets Logged Out After Creating Child

**Why:** Firebase only allows one authenticated session at a time. When creating a child account, Firebase creates a new session for the child, which logs out the parent.

**Solution:** 
- Parent needs to re-login after creating a child
- This is expected behavior
- Child credentials are shown in a dialog before logout

**Future Fix:** Use Firebase Admin SDK (requires backend) to create child accounts without affecting parent session.

### Issue 2: Can't Remember Child Password

**Solution:**
- Passwords follow pattern: `FirstName` + `MMDD` (birth month/day)
- Example: Child named "Emma" born March 15 → Password: `Emma0315`
- Parents can see credentials when first created
- Parents can reset password through "Forgot Password" (if implemented)

### Issue 3: Child Email Not Found

**Check:**
- Did you complete the child creation process?
- Did you copy the correct email from the credentials dialog?
- Format should be: `firstname.######@sparktracks.child`

### Issue 4: "User profile not found" Error

**Cause:** Account exists in Firebase Auth but not in Firestore

**Solution:**
1. Delete account from Firebase Console → Authentication
2. Try creating the child again
3. Or manually add Firestore document (advanced)

---

## 🔍 Debugging Tips

### View Browser Console
1. Press **F12** to open Developer Tools
2. Click **Console** tab
3. Look for errors (red text)
4. Common errors:
   - `user-not-found` → Email doesn't exist
   - `wrong-password` → Incorrect password
   - `email-already-in-use` → Account already exists

### Check Firebase Console
1. Go to: https://console.firebase.google.com/
2. Select project: **sparktracks-mvp**
3. **Authentication → Users:** See all registered users
4. **Firestore Database:** Check if user documents exist

### Network Tab
1. Press **F12** → **Network** tab
2. Try logging in
3. Look for Firebase API calls
4. Check for 400/401/403 errors

---

## 📊 Test Data

### Recommended Test Accounts

#### Parent 1
- Email: `parent1@test.com`
- Password: `test123456`
- Children: 2-3 test children

#### Parent 2
- Email: `parent2@test.com`
- Password: `test123456`
- Children: 1 test child

#### Coach (Future Testing)
- Email: `coach1@test.com`
- Password: `test123456`
- Classes: None yet

---

## 🚀 Quick Test Script

**Run this complete test in ~5 minutes:**

```bash
# 1. Parent Registration
Navigate to: http://localhost:port/register
Register: testparent@example.com / test123456 / Parent

# 2. Add Child
Dashboard → Children Tab → Add Child
Name: Emma Johnson
DOB: 03/15/2015
Color: Green
Copy credentials shown

# 3. Re-login as Parent
Logout → Login
Email: testparent@example.com
Password: test123456

# 4. Create Task for Child
Dashboard → Tasks Tab → Create Task
Title: "Complete homework"
Assign to: Emma Johnson
Due: Tomorrow
Points: 10
Save

# 5. Login as Child
Logout → Login
Use Emma's credentials from step 2
Verify task appears
Mark as complete

# 6. Verify Points (as Parent)
Login as parent
Check child's points balance
Should show +10 points
```

---

## ✅ Success Criteria

You've successfully completed the test when:

1. ✅ Parent can register and login
2. ✅ Parent can create child accounts
3. ✅ Child credentials are generated correctly
4. ✅ Child can login with generated credentials
5. ✅ Parent can create tasks for children
6. ✅ Child can view and complete tasks
7. ✅ No console errors during normal flow
8. ✅ Navigation works correctly for both user types

---

## 🔄 Reset Testing Data

If you need to start over:

1. **Firebase Console:**
   - Authentication → Select users → Delete
   - Firestore → users collection → Delete documents

2. **Browser:**
   - Clear local storage (F12 → Application → Local Storage → Clear)
   - Clear cookies
   - Refresh page

---

## 📝 Notes

- Child accounts are created with `@sparktracks.child` domain
- This is NOT a real email domain (child accounts don't receive emails)
- Parents manage child accounts
- Children cannot register themselves
- Email format: `firstname.randomid@sparktracks.child`
- Password format: `FirstNameMMDD` (e.g., `Emma0315`)

---

## 💡 Pro Tips

1. **Keep Parent Logged In:** Use a second browser (or incognito) to test child login
2. **Screenshot Credentials:** Take a screenshot when child credentials are shown
3. **Consistent Naming:** Use simple names like "Emma", "Noah" for easier testing
4. **Use Date Picker:** Don't type dates, use the picker for consistency
5. **Watch Console:** Keep F12 console open to catch errors early

---

## 🎨 User Experience Notes

### What Parents See:
- Dashboard with overview of all children
- Ability to create and manage tasks
- View children's progress and points
- Manage multiple children
- Calendar view of all tasks

### What Children See:
- Simplified dashboard focused on tasks
- Their assigned tasks only
- Point balance and rewards
- Task completion interface
- Calendar with their tasks

---

## Next Steps After Testing

Once basic flow works:

1. **Add more children** to test multi-child scenarios
2. **Create recurring tasks** to test calendar
3. **Test different task types** (homework, chores, activities)
4. **Verify points calculation** after task completion
5. **Test task approval flow** (parent approval of completed tasks)
6. **Test notifications** (if enabled)
7. **Test on mobile devices** (responsive design)

---

**Ready to test? Start with Step 1!** 🚀


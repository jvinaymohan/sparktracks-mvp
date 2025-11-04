# 🚀 START TESTING NOW!

## Quick Start (5 Minutes)

Your app is running in Chrome. Follow these exact steps:

### Step 1: Register Parent Account (1 min)

1. **In your Chrome browser**, click **"Sign Up"** or navigate to register page
2. Fill in:
   - First Name: `Test`
   - Last Name: `Parent`
   - Email: `test.parent@example.com`
   - Password: `test123456`
   - User Type: Select **"Parent"**
3. Click **"Create Account"**
4. ✓ You should see Parent Dashboard

### Step 2: Add a Child (2 min)

1. Click on **"Children"** tab in the dashboard
2. Click the **"Add Child" button** (big + icon at bottom or in toolbar)
3. Fill in:
   - Child Name: `Emma Johnson`
   - Date of Birth: Click calendar and select `March 15, 2015`
   - Color: Pick any color (e.g., Green)
4. Click **"Save Child"**
5. **IMPORTANT:** A dialog will pop up showing:
   ```
   Email: emma.######@sparktracks.child
   Password: Emma0315
   ```
6. Click **"Copy to Clipboard"** button (very important!)
7. Click **"Continue to Login"**

### Step 3: Re-login as Parent (1 min)

You'll be redirected to login page:
1. Login with:
   - Email: `test.parent@example.com`
   - Password: `test123456`
2. ✓ You're back in Parent Dashboard

### Step 4: Login as Child (1 min)

1. Click **Logout** icon (top right)
2. At login page, paste the child credentials you copied:
   - Email: `emma.######@sparktracks.child`
   - Password: `Emma0315`
3. Click **"Sign In"**
4. ✓ You should see Child Dashboard!

---

## What You Should See

### Parent Dashboard:
- Overview tab with stats
- Children tab showing Emma Johnson
- Tasks tab (empty for now)
- Classes tab

### Child Dashboard:
- Welcome message
- Task list (empty for now)
- Points balance: 0
- Calendar view

---

## ⚠️ If Something Goes Wrong

### Error: "No user found with this email"
**Fix:** You need to register first! Go to Sign Up page.

### Error: "Email already in use"
**Fix:** Use a different email like `test.parent2@example.com`

### Can't find child credentials
**Fix:** 
1. Logout and login as parent again
2. Go to Children tab
3. The child should be listed there
4. Password format: `FirstName` + `MMDD` (e.g., `Emma0315` for March 15)

### Parent gets logged out
**Fix:** This is normal! After creating child, you need to re-login as parent (see Step 3)

---

## 🔍 Debug Mode

Open browser console (F12) to see:
- "Creating child account: emma.######@sparktracks.child"
- "Child Firebase user created: [UID]"
- "Child Firestore document created"
- "Signed out child account"

Any errors will show in red.

---

## ✅ Success Checklist

- [ ] Parent registered successfully
- [ ] Parent logged in
- [ ] Saw Parent Dashboard
- [ ] Clicked "Add Child"
- [ ] Filled child info
- [ ] Saw credentials dialog
- [ ] Copied credentials
- [ ] Re-logged in as parent
- [ ] Logged out
- [ ] Logged in as child
- [ ] Saw Child Dashboard

---

## 🎯 What to Test Next

Once basic flow works:

1. **Create a Task** (as parent):
   - Go to Tasks tab
   - Click Create Task
   - Assign to Emma
   - Set due date and points

2. **Complete Task** (as child):
   - Login as child
   - See the task
   - Mark as complete
   - Check points balance

3. **Multiple Children**:
   - Login as parent
   - Add another child
   - Create tasks for different children
   - Test as each child

---

## 📞 Need Help?

**Check these files:**
- `PARENT_CHILD_TEST_FLOW.md` - Detailed flow
- `DEMO_ACCOUNTS.md` - Troubleshooting
- `BETA_DEPLOYMENT_GUIDE.md` - Full deployment guide

**Browser Console (F12):**
- Red errors = something wrong
- Network tab = see Firebase calls
- Application → Local Storage = see stored data

---

## 🚀 Ready to Start?

**Go to your Chrome browser and begin with Step 1!**

The app should already be running. If not:
```bash
cd /Users/vinayhome/Documents/sparktracks_mvp
flutter run -d chrome
```

**Good luck! 🎉**


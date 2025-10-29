# 🧹 Firebase Cleanup Guide

## Quick Steps to Clean Test Data

### **Why Clean Up?**
When testing authentication, you may create multiple test accounts that fail partway through registration. This can cause:
- "An account already exists" errors
- Incomplete user documents in Firestore
- Confusion about which accounts work

---

## 🗑️ **Manual Cleanup (Recommended)**

### **Step 1: Clean Authentication Users**

1. Go to: https://console.firebase.google.com/
2. Select project: **sparktracks-mvp**
3. Click **Authentication** in left sidebar
4. Click **Users** tab
5. Find test accounts to delete
6. Click the **⋮** (three dots) menu
7. Click **Delete account**
8. Confirm deletion

**Delete these if you see them:**
- Any test accounts with your email
- Any accounts that failed during registration
- Old accounts you no longer need

### **Step 2: Clean Firestore Data**

1. Stay in Firebase Console
2. Click **Firestore Database** in left sidebar
3. Click **Data** tab
4. Look for these collections:
   - `users`
   - `children` (if exists)
   - `tasks` (if exists)
   - `classes` (if exists)

**For each collection:**
1. Click the collection name
2. Find documents to delete
3. Click the document
4. Click **Delete document** (trash icon)
5. Confirm deletion

**💡 Tip:** Match user IDs between Authentication and Firestore
- Authentication user UID = Firestore document ID in `users` collection
- If an auth user exists but no Firestore doc → incomplete registration
- If a Firestore doc exists but no auth user → orphaned data

---

## 🔄 **Start Fresh Testing**

After cleanup:

1. ✅ All old test accounts deleted from Authentication
2. ✅ All old user documents deleted from Firestore
3. ✅ Clean slate for testing

Now you can:
- Register with a fresh email
- Or reuse an email you just deleted
- Test complete registration → verification → login flow
- Test password reset flow

---

## 🎯 **Testing with Real Email (Recommended)**

For best testing experience:

**Use Your Real Email:**
- You'll receive verification emails
- You'll receive password reset emails
- You can test the complete flow

**Format:**
- Your main email: `youremail@gmail.com`
- Or use Gmail's `+` trick: `youremail+test1@gmail.com`
  - All emails go to `youremail@gmail.com`
  - But Firebase treats them as different accounts
  - Great for testing multiple accounts!

**Examples:**
- `youremail+parent@gmail.com`
- `youremail+child@gmail.com`
- `youremail+coach@gmail.com`
- `youremail+test1@gmail.com`
- `youremail+test2@gmail.com`

All emails will arrive in your main Gmail inbox!

---

## 🚫 **What NOT to Delete**

Don't delete these from Firestore (they're system data):
- `_firestore_settings` (if exists)
- Any production user data
- Indexes or rules

---

## ⚡ **Quick Cleanup Checklist**

Before each major test:
- [ ] Delete old test users from **Authentication → Users**
- [ ] Delete corresponding docs from **Firestore → users collection**
- [ ] Clear browser cache and cookies
- [ ] Close and reopen browser
- [ ] Start fresh test

---

## 🔍 **Finding Orphaned Data**

### **Orphaned Auth Users (no Firestore doc):**
**Symptom:** User in Authentication but no document in Firestore
**Cause:** Registration failed after creating auth user
**Fix:** Delete the auth user and re-register

### **Orphaned Firestore Docs (no auth user):**
**Symptom:** Document in Firestore but no user in Authentication
**Cause:** Auth user was deleted but Firestore doc wasn't
**Fix:** Delete the Firestore document manually

---

## 📊 **Verify Clean State**

After cleanup, verify:

### **Authentication:**
- [ ] No test accounts remaining (or only the ones you want)
- [ ] No "unverified" test emails

### **Firestore:**
- [ ] `users` collection empty (or only production users)
- [ ] `children` collection empty
- [ ] `tasks` collection empty
- [ ] `classes` collection empty

### **Browser:**
- [ ] Clear cache and cookies
- [ ] No old login sessions
- [ ] Fresh browser or incognito mode

---

## 🎯 **Ready to Test!**

After cleanup, follow the **TESTING_GUIDE.md** for complete testing procedures.

---

## 💡 **Pro Tips**

1. **Use Gmail + Trick:**
   - `youremail+test1@gmail.com`
   - `youremail+test2@gmail.com`
   - All go to your main inbox
   - But Firebase treats them as different accounts

2. **Test Email Flow:**
   - Always use a real email you can access
   - Check spam folder immediately
   - Mark Firebase emails as "Not Spam"

3. **Keep Notes:**
   - Document which test accounts you create
   - Note the passwords you use
   - Track what you're testing

4. **Clean Up Regularly:**
   - After each testing session
   - Before major feature tests
   - When switching test scenarios

---

## 🚀 **After Cleanup**

You're ready to:
1. Test registration with a clean account
2. Receive and verify emails
3. Test login flow
4. Test password reset
5. Verify Firestore data persistence

**Follow TESTING_GUIDE.md for complete testing procedures!**

---

**Last Updated:** After implementing Firebase authentication
**Status:** ✅ Ready for clean testing


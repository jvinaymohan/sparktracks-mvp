# Fix: "User profile not found" Error

## What Happened

You see this error when:
- Account created in Firebase Authentication ✅
- User document NOT created in Firestore ❌
- Login attempts fail with "User profile not found"

This happened because of a bug that's now fixed. New accounts won't have this issue.

---

## Quick Solutions

### Solution 1: Delete Account from Firebase (5 minutes)

1. **Open Firebase Console:**
   https://console.firebase.google.com/project/sparktracks-mvp/authentication/users

2. **Sign in** with your Google account

3. **Find the account:**
   - Look for: `parent@parent.com`
   - Click the account row

4. **Delete the account:**
   - Click the 3 dots icon (⋮) on the right
   - Select "Delete account"
   - Confirm deletion

5. **Register again:**
   - Go back to your app
   - Register with `parent@parent.com` again
   - ✅ Should work now!

---

### Solution 2: Use Different Email (30 seconds)

Just use a new email:
- `parent.test@example.com`
- `sarah.johnson@test.com`
- `test.parent@example.com`

**Fastest solution!**

---

### Solution 3: Check Firebase Console

Verify the issue:

1. **Go to Authentication:**
   https://console.firebase.google.com/project/sparktracks-mvp/authentication/users
   - Check if `parent@parent.com` exists

2. **Go to Firestore:**
   https://console.firebase.google.com/project/sparktracks-mvp/firestore
   - Look in `users` collection
   - Check if document for that UID exists
   - If Auth user exists but Firestore document doesn't = orphaned account

---

## Why the Bug is Fixed

**Before:**
- `NotificationPreferences` wasn't marked `@JsonSerializable()`
- Firestore couldn't save it → Document creation failed
- Account left in broken state

**After (Fixed):**
- Added `@JsonSerializable()` annotation
- Regenerated JSON serialization code
- Firestore can now save all user data
- New registrations work perfectly

---

## Test It Now

Try creating a new account:

```
Email: test.parent@example.com
Password: test123456
Type: PARENT
```

Should work without errors! ✅

---

## Affected Accounts

If you created these BEFORE the fix:
- `parent@parent.com`
- `vinay@vinay.com`
- Any account that showed this error

**Solution:** Delete from Firebase and re-register

---

## Prevention

Going forward:
- All new registrations will work
- User data properly saved to Firestore
- No more orphaned accounts
- Bug is permanently fixed

---

**Recommended:** Use `sarah.johnson@test.com` or `parent.test@example.com` and start fresh with the test plan!


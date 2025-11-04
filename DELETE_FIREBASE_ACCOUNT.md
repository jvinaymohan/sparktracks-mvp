# How to Delete Firebase Account

If you want to delete an existing account and start fresh:

## Method 1: Firebase Console (Recommended)

1. **Open Firebase Console:**
   - Go to: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Select Your Project:**
   - Click on: **sparktracks-mvp**

3. **Go to Authentication:**
   - Click **"Authentication"** in left sidebar
   - Click **"Users"** tab

4. **Find & Delete User:**
   - Look for: `vinay@vinay.com`
   - Click the **three dots** (⋮) on the right
   - Click **"Delete account"**
   - Confirm deletion

5. **Also Delete Firestore Document:**
   - Click **"Firestore Database"** in left sidebar
   - Find the **"users"** collection
   - Find the document with email `vinay@vinay.com`
   - Click document → Click **"Delete"** button
   - Confirm deletion

6. **Try Registering Again:**
   - Go back to your app
   - Register with `vinay@vinay.com` and new password
   - Should work now!

## Method 2: Just Use Different Email

Easier option - just use a different email like:
- `vinay.test@example.com`
- `vinay2@vinay.com`
- `parent1@test.com`

---

## Why This Happens

The error "user already exists" means:
- You previously created an account with this email
- The account is stored in Firebase Authentication
- Firebase doesn't allow duplicate emails

---

## Pro Tip

For testing, use simple email patterns:
- `test.parent1@example.com`
- `test.parent2@example.com`
- `demo.parent@example.com`

This way you can easily create multiple test accounts!


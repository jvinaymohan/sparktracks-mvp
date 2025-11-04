# Demo Accounts Setup Guide

## Current Issue

You're trying to login with `child.176221@sparktracks.child` but the account doesn't exist in Firebase.

## Quick Fix: Register First

1. **In your browser:**
   - Click "Sign Up" button
   - Fill in the registration form
   - Use a real email or test format like: `test@example.com`
   - Password: minimum 6 characters
   - Choose user type: Parent, Child, or Coach

2. **Then login** with the credentials you just created

## Check Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: **sparktracks-mvp**
3. Navigate to: **Authentication** → **Users**
4. You should see your registered users here

## Creating Demo/Test Accounts

### Option A: Through Firebase Console

1. Go to Firebase Console → Authentication → Users
2. Click "Add User"
3. Enter:
   - Email: `parent@test.com`
   - Password: `test123456`
4. After creation, go to Firestore Database
5. Create a document in `users` collection with:
   ```json
   {
     "id": "[Firebase Auth UID]",
     "email": "parent@test.com",
     "name": "Test Parent",
     "type": "parent",
     "emailVerified": true,
     "createdAt": "[current timestamp]",
     "updatedAt": "[current timestamp]",
     "notificationPreferences": {
       "email": true,
       "push": true,
       "sms": false
     },
     "paymentProfile": {
       "pointsBalance": 100
     }
   }
   ```

### Option B: Through Your App

Just use the registration flow - it's easier and creates both Auth user and Firestore document automatically!

## Recommended Test Accounts

Create these for testing:

1. **Parent Account**
   - Email: `parent@test.com`
   - Password: `test123456`
   - Type: Parent

2. **Child Account**
   - Email: `child@test.com`
   - Password: `test123456`
   - Type: Child

3. **Coach Account**
   - Email: `coach@test.com`
   - Password: `test123456`
   - Type: Coach

## Troubleshooting

### "No user found with this email"
- The account doesn't exist
- Solution: Register first or check email spelling

### "Incorrect password"
- Password is wrong
- Solution: Use "Forgot Password" or register new account

### "User profile not found"
- Account exists in Firebase Auth but not in Firestore
- Solution: Delete from Auth and re-register through app

### Firebase permission errors
- Check Firebase Security Rules in Firestore
- Ensure Authentication is enabled for Email/Password

## Firebase Setup Checklist

- [ ] Firebase Authentication enabled
- [ ] Email/Password sign-in method enabled
- [ ] Firestore database created
- [ ] Firestore Security Rules configured
- [ ] Test account created and verified

## Next Steps

1. **Register a test account through the app**
2. **Login with those credentials**
3. **Explore the different dashboards based on user type**

If you continue to have issues:
1. Open browser console (F12)
2. Look for error messages
3. Check the Network tab for Firebase API calls
4. Verify Firebase configuration in `lib/firebase_options.dart`


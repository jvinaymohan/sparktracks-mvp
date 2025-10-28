# Firebase Setup Instructions

## Current Status

✅ **Completed:**
- Added Firebase dependencies (`firebase_auth`, `cloud_firestore`)
- Created `firebase_options.dart` template

❌ **Needs Your Action:**
To enable real Firebase authentication and persistent data storage, you need to:

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Name it: `sparktracks-mvp`
4. Follow the setup wizard

### 2. Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** authentication
3. This enables:
   - User registration
   - Email verification
   - Password reset

### 3. Enable Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (e.g., `us-central`)

### 4. Add Web App

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll to "Your apps" section
3. Click the **Web** icon (`</>`)
4. Register app with nickname: `sparktracks-web`
5. Copy the Firebase configuration

### 5. Update `firebase_options.dart`

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR-ACTUAL-API-KEY',              // From Firebase Console
  appId: 'YOUR-ACTUAL-APP-ID',                // From Firebase Console
  messagingSenderId: 'YOUR-SENDER-ID',        // From Firebase Console
  projectId: 'sparktracks-mvp',               // Your project ID
  authDomain: 'sparktracks-mvp.firebaseapp.com',
  storageBucket: 'sparktracks-mvp.appspot.com',
  measurementId: 'YOUR-MEASUREMENT-ID',       // Optional
);
```

### 6. Configure Firestore Security Rules

In Firebase Console → Firestore Database → Rules, use these rules for development:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Parents can manage their children
    match /children/{childId} {
      allow read, write: if request.auth != null;
    }
    
    // Tasks
    match /tasks/{taskId} {
      allow read, write: if request.auth != null;
    }
    
    // Classes
    match /classes/{classId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Alternative: Skip Firebase for Now

If you want to test the app WITHOUT Firebase persistence:

The app currently works with **in-memory storage** (data resets on refresh). This is fine for testing the UI and features.

To continue without Firebase:
1. Keep using the current mock data
2. Data will persist during the session but reset on page reload
3. No email verification or password reset

---

## What's Next?

Once you complete the Firebase setup above, I'll:
1. ✅ Update AuthService to use Firebase Auth
2. ✅ Enable email verification
3. ✅ Add password reset functionality
4. ✅ Update all providers to use Firestore
5. ✅ Remove all mock data
6. ✅ Make data persist across sessions

**Let me know when you've completed the Firebase setup, or if you want to continue with mock data for now!**


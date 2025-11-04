# Beta Deployment Guide for Sparktracks MVP

## Overview
This guide covers everything needed to launch Sparktracks MVP for beta testing on iOS (TestFlight) and Android (Google Play Beta).

---

## 📱 iOS App Store (TestFlight Beta)

### Prerequisites

1. **Apple Developer Account**
   - Enroll at https://developer.apple.com/programs/
   - Cost: $99/year
   - Processing time: 24-48 hours

2. **Development Environment**
   - Mac with Xcode installed
   - CocoaPods installed: `sudo gem install cocoapods`
   - Valid code signing certificates

### Steps to Deploy

#### 1. Configure App Identity

Update `ios/Runner.xcodeproj` settings:
- **Bundle Identifier**: Currently `com.sparktracks.mvp`
- **Display Name**: "Sparktracks" (user-facing name)
- **Version**: 1.0.0 (matches pubspec.yaml)
- **Build Number**: 1 (increment for each upload)

#### 2. Update Info.plist Permissions

Add required permission descriptions to `ios/Runner/Info.plist`:

```xml
<!-- Camera permission for profile photos -->
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take profile pictures</string>

<!-- Photo library permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select images</string>

<!-- Calendar permission (if using) -->
<key>NSCalendarsUsageDescription</key>
<string>We need access to your calendar to schedule tasks</string>
```

#### 3. Configure Firebase for iOS

Ensure `ios/Runner/GoogleService-Info.plist` is properly configured with your Firebase iOS credentials.

#### 4. Set Up App Store Connect

1. Go to https://appstoreconnect.apple.com/
2. Create a new app:
   - **Name**: Sparktracks MVP
   - **Bundle ID**: com.sparktracks.mvp
   - **SKU**: com.sparktracks.mvp (or unique identifier)
   - **Primary Language**: English (or your choice)

3. Fill in required metadata:
   - **App Icon**: 1024x1024px PNG
   - **Screenshots**: 
     - iPhone 6.7" (1290x2796)
     - iPhone 6.5" (1242x2688)
     - iPad Pro 12.9" (2048x2732)
   - **Description**: Comprehensive Learning Management Platform
   - **Keywords**: education, learning, tasks, management
   - **Support URL**: Your website
   - **Privacy Policy URL**: Required before submission

#### 5. Create Signing Certificate & Provisioning Profile

Using Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Enable "Automatically manage signing"
4. Select your Team
5. Or manually create:
   - Distribution Certificate
   - App Store Provisioning Profile

#### 6. Build and Archive

```bash
# Clean build
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# Or use Xcode
# Open ios/Runner.xcworkspace
# Product → Archive
# Distribute App → App Store Connect → Upload
```

#### 7. Upload to TestFlight

After archiving in Xcode:
1. Window → Organizer
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Upload
6. Wait for processing (30 min - 2 hours)

#### 8. Set Up TestFlight Beta

1. In App Store Connect → TestFlight
2. Add internal testers (up to 100, immediate access)
3. Add external testers (up to 10,000, requires Apple review)
4. Create a test group
5. Send invitations

**Beta Review Requirements:**
- What's new in this build
- Beta tester instructions
- Contact information
- Demo account credentials (if login required)

---

## 🤖 Android (Google Play Console Beta)

### Prerequisites

1. **Google Play Developer Account**
   - Sign up at https://play.google.com/console
   - One-time fee: $25
   - Verification: 24-48 hours

2. **Signing Configuration**
   - Create upload keystore (for signing releases)
   - Keep backup of keystore (cannot be recovered if lost!)

### Steps to Deploy

#### 1. Create Upload Keystore

```bash
# Navigate to android/app directory
cd android/app

# Generate keystore
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storetype JKS

# Follow prompts to set passwords
# SAVE THESE CREDENTIALS SECURELY!
```

#### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

Add to `.gitignore`:
```
**/android/key.properties
**/android/app/upload-keystore.jks
```

Update `android/app/build.gradle.kts`:

```kotlin
// Add before android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

#### 3. Update App Configuration

In `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.sparktracks.mvp"
    minSdk = 21  // Android 5.0 minimum
    targetSdk = 34  // Latest Android
    versionCode = 1  // Increment for each release
    versionName = "1.0.0"  // User-facing version
}
```

#### 4. Configure Permissions

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet for Firebase -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- Camera for profile photos -->
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <!-- Read external storage (for image picker) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    
    <!-- Write external storage (Android < 10) -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28"/>
</manifest>
```

#### 5. Add Firebase Configuration

Ensure `android/app/google-services.json` is present with proper Firebase Android credentials.

#### 6. Build Release APK/AAB

```bash
# Clean build
flutter clean
flutter pub get

# Build Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# Or build APK (for testing)
flutter build apk --release

# Output location:
# AAB: build/app/outputs/bundle/release/app-release.aab
# APK: build/app/outputs/flutter-apk/app-release.apk
```

#### 7. Create App in Google Play Console

1. Go to https://play.google.com/console
2. Create Application
3. Fill in Store Listing:
   - **App Name**: Sparktracks MVP
   - **Short Description**: 80 characters max
   - **Full Description**: 4000 characters max
   - **App Icon**: 512x512px PNG
   - **Feature Graphic**: 1024x500px PNG
   - **Screenshots**: 
     - Phone: 16:9 or 9:16 ratio
     - 7-inch tablet (optional)
     - 10-inch tablet (optional)
   - **Category**: Education
   - **Privacy Policy**: Required URL

4. Content Rating:
   - Complete questionnaire
   - Get rating certificate

5. App Access:
   - Specify if login required
   - Provide demo credentials

6. Target Audience:
   - Age range selection
   - Compliance declarations

#### 8. Set Up Internal/Closed Testing

1. **Internal Testing** (up to 100 testers, instant publishing)
   - Testing → Internal testing
   - Create release
   - Upload AAB
   - Add release notes
   - Save → Review → Start rollout

2. **Closed Testing** (up to custom limit, review required)
   - Testing → Closed testing
   - Create track (e.g., "Beta")
   - Upload AAB
   - Add testers (email list or Google Groups)
   - Submit for review

3. **Open Testing** (unlimited, public, review required)
   - Similar to closed, but accessible to anyone with link

#### 9. Invite Testers

**Internal Testing:**
```
https://play.google.com/apps/internaltest/<package-name>
```

**Closed/Open Testing:**
- Generate opt-in URL from console
- Share with testers
- Testers must opt-in before downloading

---

## 🎨 Required Assets

### App Icons

#### iOS
- 1024x1024px (App Store)
- Generated sizes in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

#### Android
- 512x512px (Play Store)
- Generated sizes in `android/app/src/main/res/mipmap-*/`

Use tool like https://appicon.co/ to generate all sizes.

### Screenshots

#### iOS Requirements:
- 6.7" iPhone (1290x2796) - Required
- 6.5" iPhone (1242x2688) - Optional
- iPad Pro 12.9" (2048x2732) - If supporting iPad

#### Android Requirements:
- Phone: 16:9 ratio (e.g., 1080x1920)
- Minimum 2 screenshots, maximum 8
- 7" tablet: 16:9 or 16:10
- 10" tablet: 16:9 or 16:10

### Marketing Assets

1. **Feature Graphic** (Android only)
   - 1024x500px
   - No text (will be overlaid)

2. **Promotional Graphic** (Optional)
   - 180x120px

3. **Privacy Policy**
   - Host online (required for both stores)
   - Must be accessible publicly

---

## 📝 App Store Metadata

### App Description Template

**Short Description (80 chars for Android):**
```
Comprehensive learning management platform for students and educators
```

**Full Description:**
```
Sparktracks MVP - Empowering Education Through Technology

Sparktracks is a comprehensive learning management platform designed to help parents, students, and coaches collaborate effectively.

KEY FEATURES:
• Task Management - Create, assign, and track educational tasks
• Calendar Integration - Never miss a deadline with our intuitive calendar
• Points & Rewards - Motivate students with achievement tracking
• Multi-User Support - Parents, children, and coaches all in one platform
• Real-time Updates - Stay connected with instant notifications
• Secure & Private - Your data protected with Firebase security

FOR PARENTS:
• Create and manage tasks for your children
• Track progress and completion
• Set up reward systems
• Monitor academic performance

FOR STUDENTS:
• View assigned tasks
• Submit completed work
• Earn points and rewards
• Stay organized with calendar view

FOR COACHES:
• Manage multiple students
• Provide feedback and guidance
• Track class progress
• Communicate effectively

Built with modern technology for a seamless experience across all devices.

Start your journey to better learning management today!
```

### Keywords (iOS)

```
education, learning, task management, student, teacher, parent, homework, 
study, school, academic, progress tracking, calendar, rewards, achievement
```

### What's New (Release Notes)

```
Welcome to Sparktracks MVP Beta!

This is our initial beta release. We're excited to have you test our platform.

Features included:
• User authentication and onboarding
• Task creation and management
• Calendar view for scheduling
• Points and rewards system
• Multi-role support (Parent/Child/Coach)
• Real-time notifications
• Financial ledger tracking

We value your feedback! Please report any issues or suggestions through 
the in-app feedback feature or email us at support@sparktracks.com.

Thank you for being an early tester!
```

---

## ⚠️ Critical Pre-Launch Checklist

### Code & Configuration

- [ ] Update app version in `pubspec.yaml` (currently 1.0.0+1)
- [ ] Configure real Firebase credentials (not demo keys)
- [ ] Update Firebase Security Rules for production
- [ ] Remove debug logs and print statements
- [ ] Test on both iOS and Android physical devices
- [ ] Verify all navigation flows work correctly
- [ ] Test authentication (login, register, reset password)
- [ ] Verify file upload functionality (image picker)

### Firebase Setup

- [ ] Create production Firebase project
- [ ] Add iOS app to Firebase (download GoogleService-Info.plist)
- [ ] Add Android app to Firebase (download google-services.json)
- [ ] Configure Authentication providers
- [ ] Set up Firestore database with proper structure
- [ ] Configure Firestore Security Rules:
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      // Users can only read/write their own data
      match /users/{userId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Tasks readable by assigned users
      match /tasks/{taskId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null;
      }
      
      // Add more rules based on your data model
    }
  }
  ```

### Legal & Compliance

- [ ] Create Privacy Policy (required)
  - What data you collect
  - How you use it
  - How you protect it
  - Third-party services (Firebase)
  - User rights (GDPR compliance)
  - Contact information

- [ ] Create Terms of Service
- [ ] Create Support Page
- [ ] Set up support email
- [ ] COPPA compliance (if users under 13)
- [ ] GDPR compliance (if EU users)

### Store Assets

- [ ] App icon (1024x1024 for both platforms)
- [ ] Screenshots for all required sizes
- [ ] Feature graphic (Android)
- [ ] App description reviewed
- [ ] Keywords/tags selected
- [ ] Age rating completed
- [ ] Category selected (Education)

### Testing

- [ ] Test on multiple devices (iPhone, iPad, Android phone, tablet)
- [ ] Test all user flows (parent, child, coach)
- [ ] Test offline behavior
- [ ] Verify error handling
- [ ] Test payment/points system
- [ ] Load testing (if expecting many users)
- [ ] Security audit

### Beta Testing Preparation

- [ ] Prepare list of beta testers (emails)
- [ ] Create testing instructions document
- [ ] Set up feedback collection method
- [ ] Create demo/test accounts
- [ ] Prepare FAQ for testers
- [ ] Set up analytics (optional but recommended)

---

## 🚀 Deployment Timeline

### Week 1: Preparation
- Set up developer accounts
- Create app store listings
- Generate assets (icons, screenshots)
- Write descriptions and policies

### Week 2: Configuration
- Configure signing certificates
- Set up Firebase production environment
- Update app with production credentials
- Final code cleanup and testing

### Week 3: Build & Submit
- Build release versions
- Upload to TestFlight (iOS)
- Upload to Internal Testing (Android)
- Wait for processing

### Week 4: Beta Testing
- Invite testers
- Collect feedback
- Fix critical bugs
- Iterate based on feedback

### Week 5-6: Refinement
- Address feedback
- Prepare for wider rollout or production release

---

## 🔧 Current Issues to Address

Based on your current setup:

### High Priority

1. **Firebase Configuration**
   - Replace demo Firebase keys in `lib/firebase_options.dart`
   - iOS: `AIzaSyDemoKey-Replace-With-Your-Actual-Key`
   - Android: `AIzaSyDemoKey-Replace-With-Your-Actual-Key`

2. **iOS Development Setup**
   - Xcode not fully configured
   - CocoaPods not installed
   - Run: `sudo gem install cocoapods`
   - Run: `cd ios && pod install`

3. **Android Development Setup**
   - Android SDK not configured
   - Install Android Studio
   - Configure Android SDK path

4. **App Signing**
   - Create release keystore for Android
   - Configure code signing for iOS

### Medium Priority

5. **Code Quality**
   - Fix unused imports (12 warnings)
   - Remove deprecated `withOpacity` calls
   - Remove print statements (production should use logger)

6. **Testing**
   - Write proper widget tests
   - Add integration tests
   - Test on physical devices

7. **Assets**
   - Add app icons (currently using default)
   - Create launch screens
   - Add screenshot assets

### Low Priority

8. **Documentation**
   - Update README with proper description
   - Add API documentation
   - Create user guide

---

## 📚 Helpful Resources

### Official Documentation
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)
- [iOS App Distribution](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [Android Publishing Guide](https://developer.android.com/studio/publish)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)

### Tools
- [App Icon Generator](https://appicon.co/)
- [Screenshot Builder](https://screenshot.pro/)
- [Privacy Policy Generator](https://www.privacypolicygenerator.info/)
- [Fastlane](https://fastlane.tools/) - Automate deployments

### Support
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Android Developers](https://developer.android.com/support)

---

## 💡 Beta Testing Best Practices

1. **Start Small**
   - Begin with internal testing (5-10 people)
   - Expand to closed beta (50-100 people)
   - Then open beta if needed

2. **Collect Structured Feedback**
   - Use in-app feedback forms
   - Set up Google Forms or Typeform
   - Track issues in a project management tool

3. **Communicate Regularly**
   - Send weekly updates to testers
   - Acknowledge reported issues
   - Share roadmap and timeline

4. **Iterate Quickly**
   - Fix critical bugs immediately
   - Release updates frequently
   - Keep beta testers engaged

5. **Monitor Analytics**
   - Add Firebase Analytics
   - Track user behavior
   - Identify problem areas

---

## 🎯 Next Steps

1. **Immediate** (Do Today)
   - [ ] Set up Apple Developer account (if not done)
   - [ ] Set up Google Play Developer account (if not done)
   - [ ] Create production Firebase project
   - [ ] Install Xcode and Android Studio

2. **This Week**
   - [ ] Generate app icons and screenshots
   - [ ] Write privacy policy and terms
   - [ ] Configure Firebase for production
   - [ ] Set up code signing

3. **Next Week**
   - [ ] Build and test release versions
   - [ ] Upload to TestFlight and Play Console
   - [ ] Invite initial beta testers

4. **Ongoing**
   - [ ] Monitor feedback
   - [ ] Fix bugs
   - [ ] Plan production release

---

## 📞 Need Help?

If you need assistance with any of these steps, consider:
- Hiring a DevOps consultant for deployment setup
- Using a CI/CD service like Codemagic or Bitrise
- Consulting Flutter deployment documentation
- Reaching out to Flutter community

Good luck with your beta launch! 🚀



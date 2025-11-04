# 📋 Beta Launch Quick Checklist

## ✅ Account Setup
- [ ] Apple Developer Account ($99/year) - https://developer.apple.com/programs/
- [ ] Google Play Developer Account ($25 one-time) - https://play.google.com/console/signup

## ✅ Development Environment
- [ ] Install Xcode (macOS only)
- [ ] Install Android Studio
- [ ] Install CocoaPods: `sudo gem install cocoapods`
- [ ] Configure Android SDK path

## ✅ App Configuration

### Firebase Production Setup
- [ ] Create production Firebase project
- [ ] Add iOS app → Download GoogleService-Info.plist → Place in `ios/Runner/`
- [ ] Add Android app → Download google-services.json → Place in `android/app/`
- [ ] Enable Authentication (Email/Password)
- [ ] Create Firestore database
- [ ] Configure Firestore Security Rules
- [ ] Update `lib/firebase_options.dart` with real credentials

### iOS Configuration
- [ ] Update Bundle ID in Xcode (default: com.sparktracks.mvp)
- [ ] Add permissions to Info.plist (Camera, Photos, Calendar)
- [ ] Configure code signing (Xcode → Signing & Capabilities)
- [ ] Run: `cd ios && pod install`

### Android Configuration
- [ ] Create signing keystore:
  ```bash
  keytool -genkey -v -keystore android/app/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- [ ] Create `android/key.properties` with keystore details
- [ ] Update `build.gradle.kts` with signing config
- [ ] Add permissions to AndroidManifest.xml

## ✅ Assets & Content

### App Icons
- [ ] 1024x1024px app icon (use https://appicon.co/ to generate all sizes)
- [ ] Replace icons in `ios/Runner/Assets.xcassets/`
- [ ] Replace icons in `android/app/src/main/res/mipmap-*/`

### Screenshots
- [ ] iPhone 6.7" (1290x2796) - 3-5 screenshots
- [ ] Android Phone (1080x1920) - 2-8 screenshots
- [ ] Feature Graphic for Android (1024x500px)

### Legal Documents
- [ ] Privacy Policy (required) - host online
- [ ] Terms of Service
- [ ] Support page/email: support@sparktracks.com

## ✅ App Store Connect (iOS)

### Initial Setup
- [ ] Go to https://appstoreconnect.apple.com/
- [ ] Click + → New App
- [ ] Bundle ID: com.sparktracks.mvp
- [ ] Name: Sparktracks MVP
- [ ] Primary Language: English

### App Information
- [ ] Upload app icon (1024x1024)
- [ ] Add screenshots
- [ ] Write app description
- [ ] Add keywords
- [ ] Privacy Policy URL
- [ ] Support URL
- [ ] Age Rating

### Build Upload
- [ ] Clean: `flutter clean && flutter pub get`
- [ ] Build: `flutter build ios --release`
- [ ] Open: `open ios/Runner.xcworkspace`
- [ ] Archive: Product → Archive
- [ ] Distribute: Organizer → Distribute App → App Store Connect

### TestFlight
- [ ] Wait for build to process (30-120 minutes)
- [ ] Add build to TestFlight
- [ ] Add internal testers (email addresses)
- [ ] Add test information
- [ ] Submit for beta review (if external testing)

## ✅ Google Play Console (Android)

### Initial Setup
- [ ] Go to https://play.google.com/console
- [ ] Create Application
- [ ] Default language: English
- [ ] Title: Sparktracks MVP
- [ ] App category: Education

### Store Listing
- [ ] App icon (512x512)
- [ ] Feature graphic (1024x500)
- [ ] Phone screenshots (min 2)
- [ ] Short description (80 chars)
- [ ] Full description
- [ ] Privacy Policy URL

### Content Rating
- [ ] Complete questionnaire
- [ ] Get rating certificate

### App Access & Target Audience
- [ ] Specify if login required
- [ ] Provide demo account (if needed)
- [ ] Select target age groups
- [ ] Complete declarations

### Build Upload
- [ ] Clean: `flutter clean && flutter pub get`
- [ ] Build: `flutter build appbundle --release`
- [ ] File location: `build/app/outputs/bundle/release/app-release.aab`
- [ ] Upload to Internal Testing track
- [ ] Add release notes
- [ ] Start rollout to internal testing

### Testing
- [ ] Add tester emails
- [ ] Generate opt-in URL
- [ ] Share with testers

## ✅ Code Quality

### Critical Fixes Needed
- [ ] Replace demo Firebase keys with production keys
- [ ] Remove all `print()` statements
- [ ] Fix unused imports (12 warnings currently)
- [ ] Test all features on physical devices

### Testing
- [ ] Test login/registration
- [ ] Test task creation
- [ ] Test calendar view
- [ ] Test image upload
- [ ] Test all user roles (Parent/Child/Coach)
- [ ] Test on low-end devices
- [ ] Test offline behavior

## ✅ Pre-Launch Testing

### Functionality
- [ ] User registration works
- [ ] Login/logout works
- [ ] Password reset works
- [ ] Email verification works
- [ ] Task creation works
- [ ] Task assignment works
- [ ] Calendar displays correctly
- [ ] Points system works
- [ ] Notifications work
- [ ] Image upload works
- [ ] All navigation flows work

### Performance
- [ ] App loads in < 3 seconds
- [ ] No crashes during normal use
- [ ] Smooth scrolling
- [ ] No memory leaks

### Security
- [ ] Firebase Security Rules configured
- [ ] No sensitive data in logs
- [ ] Secure authentication
- [ ] Data encryption (Firebase handles this)

## ✅ Beta Tester Preparation

### Documentation
- [ ] Create tester instructions
- [ ] List known issues
- [ ] Set up feedback form (Google Forms/Typeform)
- [ ] Prepare FAQs

### Communication
- [ ] Create tester email list
- [ ] Draft welcome email
- [ ] Set up support channel (email/Slack)
- [ ] Plan update schedule

## ✅ Launch Day

### iOS
- [ ] Verify build uploaded successfully
- [ ] Add testers to TestFlight
- [ ] Send invitations
- [ ] Monitor crash reports

### Android
- [ ] Verify app published to Internal Testing
- [ ] Share opt-in URL with testers
- [ ] Monitor crash reports in Play Console
- [ ] Check review status

### Post-Launch
- [ ] Monitor feedback channels
- [ ] Track user adoption
- [ ] Document bugs and feature requests
- [ ] Plan next iteration
- [ ] Send thank you to testers

## 🚨 CRITICAL - Don't Launch Without These

1. ❌ Demo Firebase credentials replaced with production
2. ❌ Privacy Policy live and accessible
3. ❌ App tested on real devices
4. ❌ Code signing configured correctly
5. ❌ Support email/page set up
6. ❌ Demo accounts created (if login required)
7. ❌ Crash reporting configured (Firebase Crashlytics)
8. ❌ At least 5 beta testers identified

## 📞 Quick Commands Reference

```bash
# iOS
flutter clean && flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
open ios/Runner.xcworkspace

# Android
flutter clean && flutter pub get
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Check for issues
flutter analyze
flutter test

# Version bump
# Edit pubspec.yaml: version: 1.0.1+2
```

## 🎯 Estimated Timeline

- **Day 1-2**: Set up developer accounts, create store listings
- **Day 3-4**: Configure Firebase, signing, build release
- **Day 5**: Upload builds, wait for processing
- **Day 6-7**: Invite testers, start beta
- **Week 2+**: Collect feedback, iterate

## 📚 Essential Links

- Apple Developer: https://developer.apple.com/
- Google Play Console: https://play.google.com/console
- Firebase Console: https://console.firebase.google.com/
- TestFlight: Via App Store Connect
- App Icon Generator: https://appicon.co/
- Privacy Policy Generator: https://privacypolicygenerator.info/

---

**Good luck with your beta launch! 🚀**

*Check off items as you complete them. Update this file with any additional steps specific to your launch.*



# 🎓 Sparktracks MVP - Comprehensive Learning Management Platform

A modern, multi-tenant learning management platform built with Flutter and Firebase, designed to connect parents, children, and coaches in a seamless educational ecosystem.

![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey.svg)

---

## 🌟 Overview

Sparktracks MVP empowers families and educators to collaborate effectively through:
- **Task Management** - Create, assign, and track educational activities
- **Points & Rewards** - Motivate children with achievement-based rewards
- **Class Management** - Coaches can create and manage classes with flexible scheduling
- **Multi-User Support** - Seamless experience for parents, children, and coaches
- **Complete Data Isolation** - Secure multi-tenant architecture

---

## ✨ Key Features

### 👨‍👩‍👧 Parent Features

#### Child Management
- Create unlimited child accounts per parent
- **Custom or Auto-Generated Credentials**
  - Auto: `firstname.######@sparktracks.child` / `FirstNameMMDD`
  - Custom: Parent-defined email and password
- Color-coded child profiles for easy identification
- Complete data isolation (see only your own children)

#### Task Management
- Create and assign tasks to specific children
- **Task Grouping** - Tasks organized by child with visual headers
- Set reward points for task completion
- **Weekly Recurring Tasks** - Select specific days (Mon, Tue, Wed, etc.)
- Task categories: Education, Chores, Activities, Health, Music, Sports
- Due date and time scheduling
- Approve or reject completed tasks
- Track points earned per child

#### Dashboard Features
- Overview of all children and their activity
- Active, completed, and approved task counts
- Points totals per child
- Recent activity feed
- Calendar view of all tasks
- Financial ledger
- Dev tools for testing (clear data options)

### 👶 Child Features

#### Personalized Experience
- Custom dashboard with child's name
- View only tasks assigned to them
- Clean, age-appropriate interface
- Points balance tracking

#### Task Completion
- View pending, in-progress, and completed tasks
- **Photo Upload** - Attach images when completing tasks (web & mobile compatible)
- Add completion notes
- See task status (Pending, Completed, Approved, Rejected)
- Track earned and pending points
- Calendar view of their tasks

#### Achievements
- Points accumulation
- Task completion tracking
- Achievement badges (future)

### 🏫 Coach Features

#### Profile Customization
- **Bio & Introduction** - Share coaching philosophy
- **Years of Experience** - Visual slider (0-50 years)
- **Professional Background** - Detailed experience description
- **Certifications** - Add multiple certifications with chip display
- **Specialties** - Quick-add or custom specialties:
  - Youth Development
  - Skills Training
  - Game Strategy
  - Physical Conditioning
  - Mental Coaching
  - Nutrition

#### Class Creation Wizard (4-Step Process)

**Step 1: Class Details**
- Title and description
- **Public/Private Toggle** - Public classes are browsable, private are invite-only
- **Group/Individual Toggle** - Group classes or 1-on-1 sessions

**Step 2: Schedule**
- One-time, Weekly, or Monthly classes
- **In-Person or Online**
  - In-Person: Physical location
  - Online: Meeting link (Zoom, Google Meet, etc.)
- Date and time selection
- Duration calculation

**Step 3: Pricing & Registration**
- **Multi-Currency Support** - USD, EUR, GBP, CAD, AUD, INR
- **Payment Schedules:**
  - Per Class
  - Monthly subscription
  - Per Term
- Maximum students (for group classes)
- **Make-up Classes Toggle** - Allow students to reschedule

**Step 4: Review**
- Summary of all settings
- **Shareable Link Generation** - Auto-generated for public classes
- Copy link to clipboard

#### Dashboard
- View all created classes
- Student roster management
- Attendance overview
- Financial tracking
- Calendar integration

---

## 🔐 Security & Data Isolation

### Multi-Tenant Architecture
- **Parent Isolation** - Each parent sees only their own children and tasks
- **Child Isolation** - Children see only tasks assigned to them
- **Coach Isolation** - Coaches see only their own classes

### Data Filtering
- All data filtered by user ID at the provider level
- Firebase Security Rules enforce access control
- No cross-tenant data leakage

### Authentication
- Email/password authentication via Firebase Auth
- Secure user sessions
- Role-based routing and access control

---

## 🛠️ Technical Stack

### Frontend
- **Flutter 3.8.1** - Cross-platform UI framework
- **Material Design 3** - Modern, beautiful UI
- **Provider** - State management
- **GoRouter** - Declarative routing

### Backend & Services
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - Image and file storage

### Key Packages
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  provider: ^6.1.2
  go_router: ^14.6.2
  table_calendar: ^3.1.2
  image_picker: ^1.1.2
  json_annotation: ^4.9.0
```

---

## 📱 Platform Support

- ✅ **Web** - Full Progressive Web App support
- ✅ **iOS** - Native iOS application
- ✅ **Android** - Native Android application
- ✅ **macOS** - Desktop application (beta)
- ✅ **Windows** - Desktop application (beta)
- ✅ **Linux** - Desktop application (beta)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0+
- Firebase project configured
- iOS development: Xcode, CocoaPods
- Android development: Android Studio, Android SDK

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/jvinaymohan/sparktracks-mvp.git
cd sparktracks-mvp
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure Firebase:**
   - Update `lib/firebase_options.dart` with your Firebase credentials
   - Or run: `flutterfire configure`

4. **Generate JSON serialization:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. **Run the app:**
```bash
# Web
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android
```

---

## 📖 Usage Guide

### For Parents

1. **Register** with email and select "PARENT" account type
2. **Add Children:**
   - Go to Children tab → Click "Add Child"
   - Option to use auto-generated or custom credentials
3. **Create Tasks:**
   - Click "Create Task" → Follow 4-step wizard
   - Assign to specific child
   - Set points and due date
   - Optional: Make it recurring with day selection
4. **Approve Tasks:**
   - Children complete tasks
   - Review in Tasks tab
   - Click "Approve" to award points

### For Children

1. **Login** with credentials provided by parent
2. **View Tasks** in personalized dashboard
3. **Complete Tasks:**
   - Click on task → "Complete Task"
   - Add notes and photos (optional)
   - Submit for approval
4. **Track Points** in Overview tab

### For Coaches

1. **Register** with "COACH" account type
2. **Customize Profile:**
   - Click person icon → Fill in bio, experience, certifications
3. **Create Classes:**
   - Click "Create Class" → 4-step wizard
   - Configure public/private, group/individual
   - Set pricing and currency
   - Get shareable link for public classes

---

## 🎨 User Interface

### Design Principles
- **Material Design 3** - Modern, consistent UI
- **Responsive Layout** - Works on all screen sizes
- **Color-Coded** - Children assigned colors for easy identification
- **Intuitive Navigation** - Tab-based dashboard structure
- **Visual Feedback** - Status indicators, loading states, success/error messages

### Theme
- Custom color palette with primary gradient
- Consistent spacing and typography
- Card-based layout for content organization
- Floating Action Buttons for primary actions

---

## 📊 Data Models

### Core Models
- **User** - Parent, Child, or Coach accounts
- **Student** - Child profile with parent association
- **Task** - Assignable activities with rewards
- **Class** - Coach-created educational sessions
- **Attendance** - Class attendance tracking
- **Payment** - Transaction records

### Key Enumerations
- **UserType:** Parent, Child, Coach
- **TaskStatus:** Pending, In Progress, Completed, Approved, Rejected
- **TaskPriority:** Low, Medium, High
- **ClassType:** One-Time, Weekly, Monthly
- **Currency:** USD, EUR, GBP, CAD, AUD, INR

---

## 🧪 Testing

### Quick Test
Follow the 5-minute quick start in `TEST_NOW.md`

### Comprehensive Testing
Complete 30-minute workflow in `COMPREHENSIVE_TEST_PLAN.md` covering:
- Multiple parent accounts
- Multiple children per parent
- Task creation and approval
- Coach accounts and classes
- Multi-tenancy verification

### Test Accounts
See `QUICK_TEST_REFERENCE.md` for suggested test account structure

### Dev Tools
- Click 🐛 icon in parent dashboard
- Clear all tasks
- Clear all children
- Reset test data

---

## 📚 Documentation

### For Users
- `TEST_NOW.md` - Quick 5-minute test guide
- `COMPREHENSIVE_TEST_PLAN.md` - Complete testing workflow
- `PARENT_CHILD_TEST_FLOW.md` - Detailed parent-child flow
- `DEMO_ACCOUNTS.md` - Troubleshooting guide

### For Developers
- `FIXES_SUMMARY.md` - All bugs fixed and features added
- `MULTI_TENANT_FIXES.md` - Data isolation implementation
- `ALL_FEATURES_COMPLETE.md` - Complete feature list

### For Deployment
- `BETA_DEPLOYMENT_GUIDE.md` - Complete app store submission guide
- `BETA_LAUNCH_CHECKLIST.md` - Pre-launch checklist
- `PRIVACY_POLICY_TEMPLATE.md` - Required privacy policy

---

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── user_model.dart
│   ├── student_model.dart
│   ├── task_model.dart
│   ├── class_model.dart
│   ├── attendance_model.dart
│   └── payment_model.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── children_provider.dart
│   ├── tasks_provider.dart
│   └── classes_provider.dart
├── screens/                     # UI screens
│   ├── auth/                   # Login, register, etc.
│   ├── dashboard/              # Parent, child, coach dashboards
│   ├── tasks/                  # Task creation and management
│   ├── children/               # Child management
│   ├── classes/                # Class creation wizard
│   ├── coach/                  # Coach profile
│   ├── calendar/               # Calendar view
│   ├── settings/               # Settings screens
│   └── ...
├── services/                    # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
├── utils/                       # Utilities
│   ├── app_config.dart
│   ├── app_theme.dart
│   └── dev_utils.dart
└── widgets/                     # Reusable widgets
```

---

## 🔧 Configuration

### Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com/
2. Enable Authentication (Email/Password)
3. Create Firestore database
4. Download configuration files:
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Android: `google-services.json` → `android/app/`
5. Update `lib/firebase_options.dart` with your credentials

### App Configuration

Edit `lib/utils/app_config.dart`:
```dart
static const String appName = 'Sparktracks MVP';
static const String appVersion = '1.0.0';
// Update API keys and configuration
```

---

## 🐛 Development Tools

### Built-in Dev Tools
Access via 🐛 icon in parent dashboard:
- Clear All Tasks
- Clear All Children
- Clear Everything

### Debugging
```bash
# Run with verbose logging
flutter run -d chrome --verbose

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 📦 Building for Production

### Web
```bash
flutter build web --release
```
Output: `build/web/`

### iOS
```bash
flutter build ios --release
```
Then archive in Xcode for App Store submission

### Android
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

See `BETA_DEPLOYMENT_GUIDE.md` for complete deployment instructions.

---

## 🚦 Current Status

### ✅ Fully Implemented
- Multi-tenant user management
- Parent dashboard with child & task management
- Child dashboard with task completion
- Coach dashboard with class creation
- Weekly recurring tasks with day selection
- Photo upload (web & mobile compatible)
- Points tracking and approval system
- Coach profile customization
- Currency support (6 currencies)
- Public/private and group/individual classes
- Shareable enrollment links
- Make-up class options
- Payment schedule options

### 🚧 In Development
- Class enrollment UI
- Attendance marking interface
- Payment tracking dashboard
- Automated notifications
- Make-up class scheduling interface
- Class browsing for parents/students

---

## 🤝 Contributing

### Development Workflow

1. Create a feature branch:
```bash
git checkout -b feature/your-feature-name
```

2. Make changes and test locally

3. Commit with descriptive messages:
```bash
git add .
git commit -m "Add: description of changes"
```

4. Push and create pull request:
```bash
git push origin feature/your-feature-name
```

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small

---

## 📄 License

This project is private and proprietary. All rights reserved.

---

## 🆘 Support & Documentation

### Quick Start
- `TEST_NOW.md` - 5-minute quick test
- `QUICK_TEST_REFERENCE.md` - Quick reference card

### Testing
- `COMPREHENSIVE_TEST_PLAN.md` - Complete testing workflow
- `PARENT_CHILD_TEST_FLOW.md` - Parent-child flow details

### Deployment
- `BETA_DEPLOYMENT_GUIDE.md` - App store submission
- `BETA_LAUNCH_CHECKLIST.md` - Pre-launch checklist
- `PRIVACY_POLICY_TEMPLATE.md` - Privacy policy template

### Troubleshooting
- `DEMO_ACCOUNTS.md` - Account issues
- `ORPHANED_ACCOUNT_FIX.md` - Fix account errors
- `DELETE_FIREBASE_ACCOUNT.md` - Remove test accounts

---

## 🎯 Roadmap

### Phase 1 - MVP (Current) ✅
- [x] User authentication (Parent, Child, Coach)
- [x] Child management with custom credentials
- [x] Task creation and assignment
- [x] Points and rewards system
- [x] Task approval workflow
- [x] Coach class creation
- [x] Multi-currency support
- [x] Coach profile customization

### Phase 2 - Enhanced Features (Next)
- [ ] Class enrollment UI
- [ ] Attendance marking for coaches
- [ ] Payment tracking dashboard
- [ ] Automated email notifications
- [ ] Make-up class scheduling interface
- [ ] Class browsing for parents

### Phase 3 - Advanced Features
- [ ] Analytics and reporting
- [ ] Advanced achievements system
- [ ] Parent-coach messaging
- [ ] Video integration for online classes
- [ ] Mobile app optimization
- [ ] Push notifications

### Phase 4 - Beta Launch
- [ ] App Store submission (iOS)
- [ ] Google Play submission (Android)
- [ ] Beta testing program
- [ ] User feedback integration

---

## 📞 Contact

- **Project Repository:** https://github.com/jvinaymohan/sparktracks-mvp
- **Issues:** Use GitHub Issues for bug reports
- **Email:** support@sparktracks.com (update with actual email)

---

## 🙏 Acknowledgments

Built with:
- [Flutter](https://flutter.dev/) - UI framework
- [Firebase](https://firebase.google.com/) - Backend services
- [Provider](https://pub.dev/packages/provider) - State management
- [GoRouter](https://pub.dev/packages/go_router) - Navigation
- [Table Calendar](https://pub.dev/packages/table_calendar) - Calendar widget

---

## 📈 Statistics

- **Total Lines of Code:** ~15,000+
- **Number of Screens:** 20+
- **Data Models:** 6 core models
- **Providers:** 5 state management providers
- **Supported Currencies:** 6
- **User Roles:** 3 (Parent, Child, Coach)

---

## 🎓 Use Cases

### Family Scenario
- Parents create accounts and add their children
- Assign homework, chores, and activities as tasks
- Children complete tasks and upload proof
- Parents approve and award points
- Track progress over time

### Coaching Scenario
- Coaches create profiles showcasing experience
- Set up classes (soccer, piano, tutoring, etc.)
- Choose public or private access
- Set pricing in local currency
- Share enrollment links with families
- Track enrolled students

### Educational Institution
- Multiple coaches manage different classes
- Parents enroll children in classes
- Track attendance and payments
- Coordinate schedules via calendar
- Manage multiple children per family

---

## 🔄 Version History

### v1.0.0 (Current - November 2025)
- Initial MVP release
- Complete parent-child-coach ecosystem
- Multi-tenant architecture
- Task management with points system
- Class creation and management
- Coach profile customization
- 6-currency support
- Comprehensive testing documentation

---

## ⚙️ Environment Setup

### Development
```bash
# Check Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run in debug mode
flutter run -d chrome --debug
```

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Production Build
```bash
# Clean build
flutter clean
flutter pub get

# Build for web
flutter build web --release

# Build for iOS
flutter build ios --release

# Build for Android
flutter build appbundle --release
```

---

## 🎨 Screenshots

### Parent Dashboard
- Overview with statistics
- Children list with color coding
- Tasks grouped by child
- Calendar integration

### Child Dashboard
- Personalized welcome
- Task list with status indicators
- Points balance
- Completion interface with photo upload

### Coach Dashboard
- Class management
- Student roster
- Profile customization
- Financial overview

_(Add actual screenshots here when available)_

---

## 🛡️ Security Considerations

- Firebase Security Rules enforce data access
- Authentication required for all protected routes
- User passwords hashed and salted (Firebase Auth)
- Child accounts require parent creation
- Secure credential storage
- HTTPS enforcement for all API calls

---

## 📝 Notes

- Child accounts use `@sparktracks.child` domain (not real email)
- Points system uses integer values for simplicity
- Tasks can have photos attached (stored in Firebase Storage)
- Classes can be public (browsable) or private (invite-only)
- Multiple payment schedules supported per class
- Dev tools available for testing and debugging

---

## 🎯 Core Principles

1. **User-Centric Design** - Simple, intuitive interfaces for all user types
2. **Data Privacy** - Complete isolation between families
3. **Flexibility** - Custom or auto-generated credentials, multiple currencies
4. **Scalability** - Built to handle hundreds of families and coaches
5. **Cross-Platform** - Single codebase for all platforms

---

**Built with ❤️ for better learning management**

---

© 2025 Sparktracks. All rights reserved.

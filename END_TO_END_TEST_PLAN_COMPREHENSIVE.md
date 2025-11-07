# 🧪 COMPREHENSIVE END-TO-END TEST PLAN - v2.5.0

**Date:** November 5, 2025  
**Version:** 2.5.0  
**Tester:** Manual & Automated  
**Coverage:** 100% Feature Set  

---

## 🎯 TEST OBJECTIVES

1. **Functional Testing** - All features work as expected
2. **Security Testing** - Data isolation & privacy
3. **User Flow Testing** - Complete user journeys
4. **Cross-Browser Testing** - Chrome, Safari, Firefox, Edge
5. **Performance Testing** - Load times, responsiveness
6. **Data Integrity** - Correct data storage & retrieval

---

## 📋 TEST MATRIX

### User Roles to Test:
- ✅ Parent (5 test accounts)
- ✅ Child (10 test accounts - 2 per parent)
- ✅ Coach (3 test accounts)
- ✅ Admin (1 test account)

### Platforms to Test:
- ✅ Web (Chrome, Safari, Firefox)
- ✅ Mobile Web (iOS Safari, Chrome)
- ⏸️ Android App (optional)
- ⏸️ iOS App (optional)

---

## 🔍 TEST CASES

### 1. AUTHENTICATION & ONBOARDING

#### Test 1.1: Parent Registration
**Steps:**
1. Go to https://sparktracks-mvp.web.app/
2. Click "Claim Your Spot"
3. Select "Parent" role
4. Enter:
   - Email: test-parent-1@test.com
   - Password: Test123!@#
   - Name: Test Parent One
5. Click "Start Your Journey"

**Expected:**
- ✅ Account created successfully
- ✅ Redirected to personalized welcome screen
- ✅ Welcome message: "Welcome Test Parent - you are all set to start managing your family's learning Journey"
- ✅ After "Let's Go!" → Parent Dashboard
- ✅ hasSeenWelcome = true (no more welcome screen on next login)

**Security Checks:**
- ✅ Password must be 8+ characters
- ✅ Email validation works
- ✅ Cannot register with existing email

---

#### Test 1.2: Child Account Creation (by Parent)
**Pre-requisite:** Logged in as Parent

**Steps:**
1. Go to Parent Dashboard
2. Click "Children" tab or Quick Add FAB
3. Enter:
   - Name: Test Child One
   - Age: 10
   - Color: Blue
4. Note auto-generated credentials

**Expected:**
- ✅ Child created with auto-generated email/password
- ✅ Credentials shown in popup
- ✅ Can copy credentials
- ✅ Child appears in Children list
- ✅ Child saved to Firebase with correct parentId

**Security Checks:**
- ✅ parentId correctly set
- ✅ Only this parent can see this child
- ✅ Child name validation (no special characters)

---

#### Test 1.3: Coach Registration
**Steps:**
1. Register as Coach
2. Email: test-coach-1@test.com
3. Select "Coach" role

**Expected:**
- ✅ Welcome dialog appears with profile setup guidance
- ✅ "Complete Profile" button works
- ✅ "Skip for Now" goes to dashboard (no old dialog)
- ✅ Profile completion % shown

**Security Checks:**
- ✅ UserType = coach
- ✅ No access to parent/child features

---

### 2. PARENT FEATURES

#### Test 2.1: Create Task (Quick)
**Pre-requisite:** Parent with at least 1 child

**Steps:**
1. Parent Dashboard → Tasks tab
2. Click Quick Task FAB
3. Enter:
   - Title: "Clean your room"
   - Child: Select child
   - Category: Chores
   - Reward: 20 points (slider in multiples of 10)
4. Click "Create Task"

**Expected:**
- ✅ Task created instantly
- ✅ Appears in Tasks tab
- ✅ Shows correct child name
- ✅ Points in multiples of 10
- ✅ Saved to Firebase with parentId and childId

**Security Checks:**
- ✅ Task has correct parentId
- ✅ Task has correct childId
- ✅ Only assigned child can see it

---

#### Test 2.2: Create Task (Advanced)
**Steps:**
1. Click "Need more options? Use advanced task creator"
2. Step 1: Enter title & description
3. Step 2: Select multiple children, set due date
4. Step 3: Choose category, set recurring (weekly), select days (Mon, Wed, Fri)
5. Step 4: Review & create

**Expected:**
- ✅ Advanced wizard opens
- ✅ Can assign to multiple children
- ✅ Weekly recurring with day selection works
- ✅ Creates separate task for each selected child
- ✅ All tasks saved to Firebase

**Security Checks:**
- ✅ All tasks have correct parentId
- ✅ Each task has correct childId

---

#### Test 2.3: Approve/Reject Task
**Pre-requisite:** Child has completed a task

**Steps:**
1. Parent Dashboard → "Waiting for Approval"
2. See completed tasks grouped by child
3. Click ✓ (approve) or ✗ (reject)

**Expected:**
- ✅ Tasks grouped by child (expansion tiles)
- ✅ Approve changes status to "approved"
- ✅ Reject changes status to "rejected"
- ✅ Task removed from "Waiting for Approval"
- ✅ Updated in Firebase

---

#### Test 2.4: View Children
**Steps:**
1. Parent Dashboard → Children tab
2. View list of children
3. Click 3-dot menu → Edit Profile
4. Update child name
5. Click 3-dot menu → Reset Password

**Expected:**
- ✅ All children for this parent shown
- ✅ Edit navigates to edit screen
- ✅ Updates save correctly
- ✅ Reset password generates new password

---

### 3. CHILD FEATURES

#### Test 3.1: Child Login & Dashboard
**Steps:**
1. Logout
2. Login with child credentials
3. View dashboard

**Expected:**
- ✅ Personalized welcome: "Hi [Child Name] - You are going to like Sparktracks"
- ✅ After "Let's Go!" → Child Dashboard
- ✅ "Tasks for Today" section shows pending tasks due today
- ✅ Recent tasks shown
- ✅ Points displayed (not $ values)

**Security Checks:**
- ✅ Can ONLY see own tasks
- ✅ Cannot see siblings' tasks
- ✅ Cannot access parent features

---

#### Test 3.2: Complete Task
**Pre-requisite:** Child has pending tasks

**Steps:**
1. Child Dashboard → Tasks tab
2. Find pending task
3. Click "Complete"
4. Add photo (optional)
5. Add comment
6. Submit

**Expected:**
- ✅ Can upload photo
- ✅ Photo preview works
- ✅ Comment saved
- ✅ Task status → "completed"
- ✅ Updated in Firebase
- ✅ Parent sees in "Waiting for Approval"

---

#### Test 3.3: View Achievements
**Steps:**
1. Child Dashboard → Achievements icon
2. View achievements

**Expected:**
- ✅ Shows earned achievements
- ✅ Shows progress bars
- ✅ Unlocked achievements highlighted

---

### 4. COACH FEATURES

#### Test 4.1: Complete Coach Profile
**Pre-requisite:** Logged in as Coach

**Steps:**
1. Go to Coach Profile
2. Fill in:
   - Bio
   - Experience
   - Certifications
   - Specialties
3. Click "Save"

**Expected:**
- ✅ Profile saved to Firebase
- ✅ Data persists (no empty fields on return)
- ✅ Progress % updates
- ✅ Profile completion dialog appears
- ✅ Options: "Later" (dashboard) or "Create a Class"

---

#### Test 4.2: Create Student (Coach)
**Steps:**
1. Coach Dashboard → Manage Students
2. Click "Create New Student"
3. Enter:
   - Name: Coach Student One
   - Email: coach-student-1@test.com
   - Password: (custom or auto)
   - Age: 12
4. Create

**Expected:**
- ✅ Student created with createdByCoachId = coach ID
- ✅ Credentials shown
- ✅ Student appears in coach's list
- ✅ Saved to Firebase

**CRITICAL SECURITY CHECK:**
- ✅ createdByCoachId field is set
- ✅ This coach can see this student
- ✅ OTHER coaches CANNOT see this student

---

#### Test 4.3: Create Class
**Steps:**
1. Coach Dashboard → Create Class
2. Step 1: Enter title, description, type (weekly), public
3. Step 2: Select day of week (e.g., Monday)
4. Step 3: Set price, currency, payment schedule
5. Step 4: Review & create

**Expected:**
- ✅ Class created
- ✅ Week day selection works
- ✅ Public/private toggle works
- ✅ Currency symbol shows correctly
- ✅ Saved to Firebase with coachId

---

#### Test 4.4: Assign Students to Class
**Steps:**
1. Coach Dashboard → Classes tab
2. Find class → 3-dot menu → "Assign Students"
3. Search/select students
4. Assign

**Expected:**
- ✅ Shows ONLY students visible to coach:
  - Students coach created
  - Students enrolled in coach's classes
- ✅ Does NOT show students from other coaches
- ✅ Enrollment created in Firebase

**CRITICAL SECURITY CHECK:**
- ✅ Coach A creates students → Coach B CANNOT see them
- ✅ Privacy filter working perfectly

---

#### Test 4.5: Browse Public Classes (as Parent/Child)
**Steps:**
1. Logout from coach
2. Login as parent or child
3. Click "Browse Classes"
4. View public classes

**Expected:**
- ✅ Shows ONLY public classes (isPublic == true)
- ✅ Private classes NOT shown
- ✅ Can enroll in public classes

---

### 5. CROSS-USER SECURITY TESTS

#### Test 5.1: Parent A Cannot See Parent B's Data
**Steps:**
1. Parent A creates child "Emma"
2. Parent A creates task for "Emma"
3. Logout
4. Login as Parent B
5. Try to view children & tasks

**Expected:**
- ✅ Parent B sees ONLY their children
- ✅ Parent B sees ONLY their tasks
- ✅ "Emma" and her tasks NOT visible to Parent B

---

#### Test 5.2: Coach A Cannot See Coach B's Students
**Steps:**
1. Coach A creates student "Student A1"
2. Logout
3. Login as Coach B
4. Go to Manage Students
5. Search for "Student A1"

**Expected:**
- ✅ "Student A1" NOT found
- ✅ Coach B cannot see any of Coach A's students
- ✅ Complete isolation verified

---

#### Test 5.3: Child Cannot Access Parent Features
**Steps:**
1. Login as child
2. Try to navigate to:
   - `/parent-dashboard`
   - `/create-task`
   - `/children`

**Expected:**
- ✅ Redirected to child dashboard
- ✅ No access to parent routes
- ✅ Role-based routing working

---

### 6. PERFORMANCE TESTS

#### Test 6.1: Page Load Times
**Test on:**
- Landing page
- Registration
- Login
- Dashboard (Parent, Child, Coach)
- Browse Classes

**Expected:**
- ✅ Initial load < 3 seconds
- ✅ Navigation < 1 second
- ✅ No blank screens
- ✅ Smooth animations

---

#### Test 6.2: Large Data Sets
**Steps:**
1. Create parent with 10 children
2. Create 100 tasks
3. View dashboard

**Expected:**
- ✅ Dashboard loads smoothly
- ✅ Pagination/lazy loading works
- ✅ No performance degradation

---

### 7. DATA INTEGRITY TESTS

#### Test 7.1: Data Persistence
**Steps:**
1. Create child, task, class
2. Logout
3. Login again
4. Verify data is still there

**Expected:**
- ✅ All data persists in Firebase
- ✅ No data loss
- ✅ Correct relationships maintained

---

#### Test 7.2: Concurrent Updates
**Steps:**
1. Open 2 browser windows
2. Window 1: Parent approves task
3. Window 2: Parent views same task

**Expected:**
- ✅ Real-time updates
- ✅ Both windows show correct status
- ✅ No data conflicts

---

### 8. EDGE CASES & ERROR HANDLING

#### Test 8.1: Invalid Inputs
**Test:**
- Email: not-an-email
- Password: 123
- Child name: Test@123#
- Age: -5

**Expected:**
- ✅ Validation errors shown
- ✅ Cannot submit invalid data
- ✅ User-friendly error messages

---

#### Test 8.2: Network Errors
**Steps:**
1. Disable internet
2. Try to create task
3. Re-enable internet

**Expected:**
- ✅ Error message shown
- ✅ Can retry after reconnection
- ✅ No data corruption

---

#### Test 8.3: Expired Session
**Steps:**
1. Login
2. Wait for token expiry (or manually clear)
3. Try to perform action

**Expected:**
- ✅ Redirected to login
- ✅ Session handled gracefully
- ✅ No crashes

---

## 📊 TEST EXECUTION TRACKING

### Priority 1: Critical Paths (MUST TEST)
- [ ] Parent Registration & Login
- [ ] Child Creation
- [ ] Task Creation & Completion
- [ ] Task Approval
- [ ] Coach Student Privacy (CRITICAL!)
- [ ] Cross-User Data Isolation

### Priority 2: Core Features
- [ ] Profile Management
- [ ] Class Creation
- [ ] Enrollment
- [ ] Browse Classes
- [ ] Achievements
- [ ] Financial Ledger

### Priority 3: Nice-to-Have
- [ ] Messaging
- [ ] Analytics
- [ ] Advanced Achievements
- [ ] Payment Tracking

---

## ✅ AUTOMATED TEST SCRIPT

```bash
# Run from project root

# 1. Build app
flutter build web --release

# 2. Run linter
flutter analyze

# 3. Run unit tests (if any)
flutter test

# 4. Deploy to test environment
firebase use test-project
firebase deploy --only hosting

# 5. Run integration tests
# TODO: Add Selenium/Puppeteer tests
```

---

## 🎯 ACCEPTANCE CRITERIA

**To Pass End-to-End Testing:**
- ✅ All Priority 1 tests pass (100%)
- ✅ 90%+ Priority 2 tests pass
- ✅ No CRITICAL bugs
- ✅ No security vulnerabilities
- ✅ Page load < 3 seconds
- ✅ Coach privacy working perfectly
- ✅ Data persistence confirmed

---

## 📝 BUG TRACKING TEMPLATE

**Bug ID:** [Number]  
**Severity:** Critical / High / Medium / Low  
**Title:** [Brief description]  
**Steps to Reproduce:**
1. Step 1
2. Step 2

**Expected:** [What should happen]  
**Actual:** [What actually happened]  
**Screenshot:** [If applicable]  
**Environment:** [Browser, OS, etc.]  
**Status:** Open / In Progress / Fixed / Closed

---

## ✅ TEST COMPLETION CHECKLIST

Before declaring "READY FOR PRODUCTION":

1. [ ] All Priority 1 tests pass
2. [ ] Security audit complete (firestore.rules deployed)
3. [ ] API keys rotated
4. [ ] Admin password fixed
5. [ ] Cross-browser testing done
6. [ ] Mobile web testing done
7. [ ] Performance benchmarks met
8. [ ] Data backup verified
9. [ ] Rollback plan documented
10. [ ] User documentation updated

---

**Ready to execute? Start with Priority 1 tests!** 🚀


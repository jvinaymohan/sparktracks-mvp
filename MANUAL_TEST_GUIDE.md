# 📋 MANUAL E2E TEST GUIDE

**Test Date:** November 5, 2025  
**App URL:** http://localhost:8080 (or https://sparktracks-mvp.web.app)  

---

## 🎯 OBJECTIVE

Test all features end-to-end with real user interactions:
1. ✅ Create 5 parent accounts
2. ✅ Create 5 children (1 per parent)
3. ✅ Create tasks as parents
4. ✅ Complete tasks as children with comments
5. ✅ Approve tasks as parents
6. ✅ Coach creates classes, assigns children

---

## 📝 TEST ACCOUNTS

### Parents (to create):
```
1. parent1@test.com / Password123!
2. parent2@test.com / Password123!
3. parent3@test.com / Password123!
4. parent4@test.com / Password123!
5. parent5@test.com / Password123!
```

### Children (to create by parents):
```
1. child1@test.com / Password123! → Parent: parent1@test.com
2. child2@test.com / Password123! → Parent: parent2@test.com
3. child3@test.com / Password123! → Parent: parent3@test.com
4. child4@test.com / Password123! → Parent: parent4@test.com
5. child5@test.com / Password123! → Parent: parent5@test.com
```

### Coach (to create):
```
1. coach1@test.com / Password123!
```

---

## 🧪 PHASE 1: CREATE 5 PARENT ACCOUNTS

### Steps for Each Parent:

1. **Open App** → http://localhost:8080
2. **Click** "Sign Up Free" (top right)
3. **Fill Form:**
   - Email: `parent1@test.com`
   - Password: `Password123!`
   - Confirm Password: `Password123!`
   - Name: `Test Parent 1`
   - User Type: **Parent** ← Click Parent card
4. **Click** "Create Account"
5. **Welcome Screen** should appear → Click "Get Started"
6. **Verify:** Parent Dashboard loads
7. **Logout** → Click home icon → Logout

**Repeat for:** parent2, parent3, parent4, parent5

### ✅ Checklist:
- [ ] Parent 1 created & logged in
- [ ] Parent 2 created & logged in
- [ ] Parent 3 created & logged in
- [ ] Parent 4 created & logged in
- [ ] Parent 5 created & logged in
- [ ] Welcome screen showed for each
- [ ] All dashboards loaded correctly

---

## 🧪 PHASE 2: CREATE 5 CHILDREN

### Steps for Each Parent:

1. **Login** as `parent1@test.com`
2. **Navigate** to "Children" tab in dashboard
3. **Click** "Add Child" button (purple circle with +)
4. **Fill Form:**
   - Name: `Test Child 1`
   - Age: `10`
   - Enable "Set custom login credentials"
   - Email: `child1@test.com`
   - Password: `Password123!`
   - Color: Choose a color
5. **Click** "Save"
6. **Verify:** Child appears in Children tab
7. **Logout**

**Repeat for:** parent2→child2, parent3→child3, parent4→child4, parent5→child5

### ✅ Checklist:
- [ ] Child 1 created by Parent 1
- [ ] Child 2 created by Parent 2
- [ ] Child 3 created by Parent 3
- [ ] Child 4 created by Parent 4
- [ ] Child 5 created by Parent 5
- [ ] All children visible in their parent's dashboard
- [ ] Custom credentials work

---

## 🧪 PHASE 3: CREATE TASKS AS PARENTS

### Test Different Task Types:

#### Parent 1 - Daily Task:
1. **Login** as `parent1@test.com`
2. **Click** "Create Task" (bottom right purple button)
3. **Step 1:**
   - Title: `Morning Chores`
   - Description: `Make bed, brush teeth, get dressed`
4. **Step 2:**
   - Select child: `Test Child 1`
   - Date: Today
5. **Step 3:**
   - Category: Home
   - Recurring: **Daily**
   - Reward: `5` points
6. **Step 4:** Review → Create
7. **Verify:** Task appears in "Tasks for Today"

#### Parent 2 - Weekly Task (Test Day Selection):
1. **Login** as `parent2@test.com`
2. **Click** "Create Task"
3. **Step 1:**
   - Title: `Soccer Practice`
   - Description: `Attend soccer training`
4. **Step 2:**
   - Select child: `Test Child 2`
   - Date: Today
5. **Step 3:**
   - Category: Sports
   - Recurring: **Weekly**
   - **Select Days:** Monday, Wednesday, Friday ← **TEST THIS**
   - Reward: `10` points
6. **Step 4:** Verify days show → Create
7. **Verify:** Task created with correct days

#### Parent 3 - Monthly Task (Test Day of Month):
1. **Login** as `parent3@test.com`
2. **Click** "Create Task"
3. **Step 1:**
   - Title: `Piano Recital`
   - Description: `Monthly performance`
4. **Step 2:**
   - Select child: `Test Child 3`
   - Date: Today
5. **Step 3:**
   - Category: Music
   - Recurring: **Monthly**
   - **Day of Month:** 15th ← **TEST THIS**
   - Reward: `20` points
6. **Step 4:** Verify day shows → Create

#### Parent 4 - Multi-Child Task:
1. **Login** as `parent4@test.com`
2. **Create child for parent4**
3. **Create another child:** `child4b@test.com`
4. **Click** "Create Task"
5. **Step 2:** Select **BOTH children** ← **TEST THIS**
6. Complete task creation
7. **Verify:** Task created for both children

### ✅ Checklist:
- [ ] Daily task created
- [ ] Weekly task with day selection works
- [ ] Monthly task with day of month works
- [ ] Multi-child assignment works
- [ ] All tasks visible in parent dashboard
- [ ] Tasks show in "Tasks for Today"

---

## 🧪 PHASE 4: CHILD COMPLETES TASKS

### Steps for Each Child:

1. **Logout** from parent account
2. **Login** as `child1@test.com` / `Password123!`
3. **Verify:** Dashboard shows assigned tasks
4. **Check:** "Tasks for Today" section
5. **Click** on a task card
6. **Click** "Complete Task" button
7. **Add Comment:** "I finished all the chores!"
8. **Add Photo:** (Optional - test image upload)
9. **Click** "Submit"
10. **Verify:** Task status changes to "Pending Approval"
11. **Verify:** Task shows in completed section

**Repeat for:** child2, child3, child4, child5

### ✅ Checklist:
- [ ] Child 1 completed task with comment
- [ ] Child 2 completed task with comment
- [ ] Child 3 completed task with comment
- [ ] Child 4 completed task with comment
- [ ] Child 5 completed task with comment
- [ ] Comments saved correctly
- [ ] Photo upload works (if tested)
- [ ] Status changed to "Pending Approval"
- [ ] Points not awarded yet (pending approval)

---

## 🧪 PHASE 5: PARENT APPROVES TASKS

### Steps for Each Parent:

1. **Logout** from child account
2. **Login** as `parent1@test.com`
3. **Check:** "Waiting for Approval" section in Overview tab
4. **Verify:** Child's completed task appears
5. **Read:** Child's comment
6. **View:** Photo (if uploaded)
7. **Click** task card
8. **Click** "Approve" button
9. **Verify:** Success message
10. **Verify:** Task moves to completed section
11. **Verify:** Points awarded to child
12. **Navigate** to Financial Ledger
13. **Verify:** Transaction recorded

**Repeat for:** parent2, parent3, parent4, parent5

### ✅ Checklist:
- [ ] Parent 1 approved child's task
- [ ] Parent 2 approved child's task
- [ ] Parent 3 approved child's task
- [ ] Parent 4 approved child's task
- [ ] Parent 5 approved child's task
- [ ] Points awarded correctly
- [ ] Financial ledger updated
- [ ] No mock transactions in ledger
- [ ] Comment visible to parent

---

## 🧪 PHASE 6: COACH CLASS MANAGEMENT

### Part A: Coach Registration & Profile

1. **Logout** from parent account
2. **Click** "Sign Up Free"
3. **Fill Form:**
   - Email: `coach1@test.com`
   - Password: `Password123!`
   - Name: `Test Coach 1`
   - User Type: **Coach** ← Click Coach card
4. **Click** "Create Account"
5. **Welcome Dialog** should appear
6. **Click** "Set Up Profile"
7. **Fill Profile:**
   - Bio: "Experienced soccer coach with 10 years"
   - Experience: "10 years coaching youth soccer"
   - Certifications: "UEFA B License"
   - Specialties: "Youth Development, Technical Skills"
8. **Click** "Save Profile"
9. **Verify:** Success message

### Part B: Create Weekly Class (Test Day Selection)

1. **Click** "Create Class" (bottom right)
2. **Step 1: Basic Details**
   - Title: `Soccer Training`
   - Description: `Weekly soccer skills training`
   - Type: **Group Class**
   - Location Type: **In-Person**
   - Location: `Community Sports Field`
   - Public/Private: **Public**
3. **Click** "Next"
4. **Step 2: Schedule**
   - Class Type: **Weekly** ← **Click this**
   - **Select Days:** Monday, Wednesday, Friday ← **TEST THIS**
   - **Verify:** Days are highlighted
   - **Verify:** Validation if no days selected
   - Start Date: Tomorrow
   - Start Time: 4:00 PM
   - End Time: 6:00 PM
5. **Click** "Next"
6. **Step 3: Pricing**
   - Price: `25`
   - **Currency: USD** ← **Verify $ symbol shows**
   - **Change to EUR** ← **Verify € symbol updates** ← **TEST THIS**
   - Max Students: `15`
   - Payment Schedule: Per Class
   - Make-up Classes: Yes
7. **Click** "Next"
8. **Step 4: Review**
   - **Verify:** All details correct
   - **Verify:** Days show: "Mon, Wed, Fri"
   - **Verify:** Currency symbol correct
9. **Click** "Create Class"
10. **Verify:** Success message
11. **Verify:** Class appears in coach dashboard

### Part C: Create Monthly Class (Test Day of Month)

1. **Click** "Create Class"
2. **Step 1:** Fill basic details
   - Title: `Piano Lessons`
   - Type: **Individual**
   - Location: **Online**
3. **Step 2: Schedule**
   - Class Type: **Monthly** ← **Click this**
   - **Select Day:** 15th ← **TEST THIS**
   - **Verify:** Shows "Day 15th of each month"
4. **Step 3: Pricing**
   - Price: `50`
   - **Currency: INR** ← **Verify ₹ symbol** ← **TEST THIS**
5. Complete and create

### Part D: Create One-Time Class

1. **Click** "Create Class"
2. **Step 1:** Fill basic details
   - Title: `Basketball Workshop`
3. **Step 2: Schedule**
   - Class Type: **One-Time**
   - Date: Next Saturday
4. **Step 3: Pricing**
   - Currency: **CAD** ← **Verify C$ symbol**
5. Complete and create

### Part E: Edit Class (Test Edit Functionality)

1. **Navigate** to "My Classes" tab
2. **Find** "Soccer Training" class
3. **Click** menu (⋮) → **Edit Class** ← **TEST THIS**
4. **Verify:** All fields pre-filled with existing data
5. **Modify:** Change price to `30`
6. **Change:** Currency to GBP (£)
7. **Click** "Save Changes"
8. **Verify:** Class updated
9. **Verify:** New price and currency show

### Part F: Assign Students (Test Assignment Feature)

1. **Find** "Soccer Training" class
2. **Click** menu (⋮) → **Assign Students** ← **TEST THIS**
3. **Verify:** Dialog opens with search field
4. **Type** in search: "child" ← **TEST search**
5. **Select** multiple children using checkboxes:
   - ☑ Test Child 1
   - ☑ Test Child 2
   - ☑ Test Child 3
6. **Verify:** Count updates "Assign 3 Student(s)"
7. **Click** "Assign"
8. **Verify:** Success message
9. **Verify:** Students now show as enrolled

### Part G: Create New Child for Class

1. **Click** "Manage Students" (top right)
2. **Click** "Create New Student"
3. **Fill Form:**
   - Name: `New Group Child`
   - Email: `groupchild@test.com`
   - **Option:** Custom password or auto-generate
4. **Click** "Create"
5. **Verify:** Child created
6. **Go back** to Soccer Training class
7. **Assign** new child to class
8. **Verify:** Enrollment successful

### Part H: Verify Enrollment in Child View

1. **Logout** from coach account
2. **Login** as `child1@test.com`
3. **Click** "Browse Classes" (top right)
4. **Verify:** Can see "Soccer Training" class
5. **Verify:** Shows "Enrolled" status
6. **Logout**
7. **Login** as `parent1@test.com`
8. **Navigate** to Children tab
9. **Click** on Child 1 profile
10. **Verify:** Shows enrolled classes

### ✅ Checklist - Coach Features:
- [ ] Coach account created
- [ ] Welcome dialog appeared
- [ ] Profile setup complete
- [ ] Dashboard loaded

### ✅ Checklist - Weekly Class:
- [ ] Class created with weekly type
- [ ] Day selection works (Mon, Wed, Fri)
- [ ] Days highlighted when selected
- [ ] Days show in review screen
- [ ] Class appears in dashboard

### ✅ Checklist - Monthly Class:
- [ ] Class created with monthly type
- [ ] Day of month selector works
- [ ] Shows "15th of each month"
- [ ] Day saved correctly

### ✅ Checklist - Currency:
- [ ] USD symbol ($) displays
- [ ] EUR symbol (€) displays and updates
- [ ] INR symbol (₹) displays
- [ ] CAD symbol (C$) displays
- [ ] GBP symbol (£) displays
- [ ] Symbol updates when currency changes
- [ ] Prefix and suffix display correctly

### ✅ Checklist - Edit Class:
- [ ] Edit option available in menu
- [ ] All fields pre-filled
- [ ] Can modify fields
- [ ] Save updates class
- [ ] Changes reflected in dashboard

### ✅ Checklist - Assign Students:
- [ ] Assign students dialog opens
- [ ] Search functionality works
- [ ] Multi-select with checkboxes works
- [ ] Already enrolled students disabled
- [ ] Assignment creates enrollments
- [ ] Success message shown

### ✅ Checklist - Manage Students:
- [ ] Can create new students
- [ ] Custom password option works
- [ ] Student can be assigned to class
- [ ] Student created successfully

### ✅ Checklist - Enrollment Verification:
- [ ] Child can see enrolled classes
- [ ] Parent can see child's classes
- [ ] Enrollment status displays
- [ ] Browse classes shows public classes

---

## 🐛 BUGS TO REPORT

### Critical Issues:
```
Issue #1:
Description: 
Steps to Reproduce:
Expected Result:
Actual Result:
```

### Medium Issues:
```
Issue #1:
Description:
Steps to Reproduce:
```

### Minor Issues:
```
Issue #1:
Description:
```

---

## 📊 FINAL TEST SUMMARY

**Total Features Tested:** ___  
**Features Working:** ___  
**Features With Issues:** ___  
**Critical Bugs:** ___  
**Success Rate:** ___%  

**Overall Status:** 🟢 PASS / 🟡 PASS WITH ISSUES / 🔴 FAIL  

**Ready for Production:** ☐ YES  ☐ NO  ☐ WITH FIXES  

---

## 📝 NOTES

_Add any additional observations, feedback, or suggestions here..._

---

**Test Completed By:** _________________  
**Date:** _________________  
**Time Taken:** _________________  

---

🎉 **Thank you for testing Sparktracks MVP!**


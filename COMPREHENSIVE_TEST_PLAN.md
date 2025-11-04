# 🧪 Comprehensive End-to-End Test Plan

## Overview

This document provides a complete testing workflow for all features:
- Multiple Parents
- Multiple Children per Parent
- Task Management (Create, Assign, Complete, Approve)
- Multiple Coaches
- Class Creation
- Student Enrollment
- All Features Validation

**Estimated Time:** 30-45 minutes

---

## 🎯 Test Scenario: Complete Workflow

### Phase 1: Parent Accounts & Children (15 min)

#### Parent Account 1: "Sarah Johnson"
**Step 1.1: Register Parent A**
1. Navigate to: Register page
2. Fill in:
   - First Name: `Sarah`
   - Last Name: `Johnson`
   - Email: `sarah.johnson@test.com`
   - Password: `test123456`
   - Account Type: **PARENT**
3. Click "Create Account"
4. ✓ Should redirect to Parent Dashboard

**Step 1.2: Add Children for Parent A**

**Child 1 - Emma (Auto-Generated Credentials)**
1. Click "Children" tab
2. Click "Add Child"
3. Fill in:
   - Name: `Emma Johnson`
   - Date of Birth: `March 15, 2015` (select from calendar)
   - Color: Green
   - Credentials Toggle: **OFF** (auto-generate)
4. Click "Save Child"
5. ✓ Copy credentials dialog appears
6. **COPY THESE:**
   - Email: `emma.######@sparktracks.child`
   - Password: `Emma0315`
7. Click "Copy to Clipboard"
8. Click "Continue to Login"
9. Re-login as `sarah.johnson@test.com` / `test123456`

**Child 2 - Liam (Custom Credentials)**
1. Click "Add Child" again
2. Fill in:
   - Name: `Liam Johnson`
   - Date of Birth: `July 22, 2013`
   - Color: Blue
   - Credentials Toggle: **ON** (custom)
   - Email: `liam.johnson@test.com`
   - Password: `liam123456`
3. Click "Save Child"
4. ✓ Copy credentials
5. Re-login as Sarah

**Verify:**
- ✓ Children tab shows 2 children (Emma & Liam)
- ✓ Both have different colors
- ✓ Overview shows "2 Children"

---

#### Parent Account 2: "Michael Chen"

**Step 1.3: Create Parent B**
1. Logout from Sarah's account
2. Register:
   - First Name: `Michael`
   - Last Name: `Chen`
   - Email: `michael.chen@test.com`
   - Password: `test123456`
   - Account Type: **PARENT**
3. ✓ Redirect to Parent Dashboard

**Step 1.4: Add Children for Parent B**

**Child 1 - Sophia (Custom)**
1. Click "Add Child"
2. Fill in:
   - Name: `Sophia Chen`
   - Date of Birth: `November 8, 2014`
   - Color: Purple
   - Toggle ON
   - Email: `sophia.chen@test.com`
   - Password: `sophia123`
3. Save & re-login as Michael

**Child 2 - Noah (Auto)**
1. Add Child:
   - Name: `Noah Chen`
   - DOB: `January 5, 2016`
   - Color: Orange
   - Toggle OFF (auto)
2. Copy credentials: `noah.######@sparktracks.child`
3. Re-login as Michael

**Verify Multi-Tenancy:**
- ✓ Michael sees only Sophia & Noah (NOT Emma & Liam)
- ✓ Overview shows "2 Children"

---

### Phase 2: Task Management (10 min)

#### Parent A Creates Tasks

**Step 2.1: Login as Sarah**
1. Login: `sarah.johnson@test.com` / `test123456`
2. Go to Tasks tab

**Step 2.2: Create Task for Emma**
1. Click "Create Task" (bottom right FAB)
2. Step 1 - Basic Info:
   - Title: `Complete Math Homework`
   - Description: `Finish pages 45-50 in workbook`
   - Category: Education
3. Step 2 - Assign & Schedule:
   - Assign to: **Emma Johnson**
   - Due Date: Tomorrow
   - Due Time: 5:00 PM
4. Step 3 - Rewards:
   - Points: `10`
5. Step 4 - Review:
   - Verify all details
6. Click "Create Task"
7. ✓ Task appears in Tasks tab under Emma's section

**Step 2.3: Create Weekly Task for Liam**
1. Click "Create Task"
2. Fill in:
   - Title: `Piano Practice`
   - Description: `Practice for 30 minutes`
   - Assign to: **Liam Johnson**
   - Due Date: Next Monday
   - Recurring: **ON**
   - Pattern: **Weekly**
   - Days: **Mon, Wed, Fri** (select all 3)
   - Points: `5`
3. Create Task
4. ✓ Verify: Shows "WEEKLY (Mon, Wed, Fri)" in review

**Step 2.4: Create More Tasks**

For Emma:
- `Clean Your Room` - 5 points, Due tomorrow
- `Read for 20 minutes` - 3 points, Due in 2 days

For Liam:
- `Practice Soccer` - 8 points, Due tomorrow
- `Help with Dishes` - 4 points, Due today

**Verify:**
- ✓ Tasks tab shows 2 sections: Emma (3 tasks) & Liam (3 tasks)
- ✓ Each section shows child name and color
- ✓ Total points displayed per child

---

#### Parent B Creates Tasks

**Step 2.5: Logout & Login as Michael**
1. Logout from Sarah
2. Login: `michael.chen@test.com` / `test123456`

**Step 2.6: Create Tasks for Michael's Children**

For Sophia:
- `Complete Science Project` - 15 points
- `Study for Test` - 10 points

For Noah:
- `Brush Teeth` - 2 points
- `Make Bed` - 2 points

**Verify Multi-Tenancy:**
- ✓ Michael sees ONLY Sophia & Noah's tasks
- ✓ Does NOT see Emma or Liam's tasks
- ✓ Task count correct for each child

---

### Phase 3: Child Task Completion (10 min)

#### Test Emma's Account

**Step 3.1: Login as Emma**
1. Logout from Sarah
2. Login:
   - Email: `emma.######@sparktracks.child` (use copied email)
   - Password: `Emma0315`
3. ✓ Should see Child Dashboard with "Welcome back, Emma! 👋"

**Step 3.2: View Tasks**
1. Go to Tasks tab
2. ✓ Should see 3 tasks assigned to Emma
3. ✓ Should NOT see Liam's tasks
4. ✓ Should NOT see Sophia or Noah's tasks

**Step 3.3: Complete a Task with Photo**
1. Click on "Complete Math Homework" task
2. Click "Complete Task" button
3. Dialog appears:
   - Add completion notes: `Finished all problems correctly!`
   - Click "Gallery" button
   - Select a test image
   - ✓ Image preview shows
4. Click "Complete Task"
5. ✓ Success message appears
6. ✓ Task status changes to "Pending Approval"

**Step 3.4: Complete Another Task (No Photo)**
1. Click "Clean Your Room"
2. Complete without adding photo
3. Notes: `Room is clean!`
4. ✓ Task marked as completed

**Verify:**
- ✓ 2 tasks show "Pending Approval"
- ✓ 1 task still "Pending"
- ✓ Points show 0 (not approved yet)

---

#### Test Liam's Account

**Step 3.5: Login as Liam**
1. Logout
2. Login: `liam.johnson@test.com` / `liam123456`
3. ✓ See "Welcome back, Liam! 👋"

**Step 3.6: Complete Tasks**
1. View Tasks → See 3 tasks
2. Complete "Piano Practice"
3. Complete "Practice Soccer"
4. Leave "Help with Dishes" pending

**Verify:**
- ✓ Shows correct tasks for Liam only
- ✓ 2 tasks completed, 1 pending

---

#### Test Sophia's Account

**Step 3.7: Login as Sophia**
1. Logout
2. Login: `sophia.chen@test.com` / `sophia123`
3. ✓ See Sophia's dashboard

**Step 3.8: Complete Task**
1. Complete "Complete Science Project"
2. Add note and photo
3. ✓ Task marked for approval

---

### Phase 4: Parent Task Approval (5 min)

#### Sarah Approves Emma's Tasks

**Step 4.1: Login as Sarah**
1. Logout from child account
2. Login: `sarah.johnson@test.com` / `test123456`

**Step 4.2: View Completed Tasks**
1. Go to Tasks tab
2. ✓ See Emma's section with completed tasks
3. ✓ Tasks show "APPROVE" button

**Step 4.3: Approve Tasks**
1. Click "Approve" on "Complete Math Homework"
2. ✓ Success message shows
3. Click "Approve" on "Clean Your Room"
4. ✓ Points update: Emma shows 15 pts (10 + 5)

**Step 4.4: Approve Liam's Tasks**
1. In Liam's section
2. Approve "Piano Practice" (5 pts)
3. Approve "Practice Soccer" (8 pts)
4. ✓ Liam shows 13 pts

**Verify:**
- ✓ Emma's approved tasks show different status
- ✓ Liam's approved tasks show points
- ✓ Overview tab shows updated statistics

---

#### Michael Approves Sophia's Task

**Step 4.5: Login as Michael**
1. Logout
2. Login: `michael.chen@test.com` / `test123456`

**Step 4.6: Approve**
1. Go to Tasks tab
2. ✓ See ONLY Sophia's completed task (not Emma/Liam's)
3. Approve "Complete Science Project"
4. ✓ Sophia's points: 15 pts

**Critical Verification:**
- ✓ Michael does NOT see Sarah's children's tasks
- ✓ Complete data isolation between parents

---

### Phase 5: Coach Accounts & Classes (10 min)

#### Coach Account 1: "David Martinez"

**Step 5.1: Create Coach A**
1. Logout
2. Register:
   - Name: `David Martinez`
   - Email: `coach.david@test.com`
   - Password: `coach123456`
   - Type: **COACH**
3. ✓ Redirect to Coach Dashboard

**Step 5.2: Create Public Group Class**
1. Click "Create Class" button
2. **Step 1 - Details:**
   - Title: `Soccer Training for Beginners`
   - Description: `Learn soccer fundamentals in a fun environment`
   - Public Class: **ON**
   - Group Class: **ON**
3. **Step 2 - Schedule:**
   - Type: **Weekly**
   - Location Type: **In-Person**
   - Location: `Community Sports Center, Field 1`
   - Date: Next Monday
   - Start Time: 10:00 AM
   - End Time: 11:30 AM
4. **Step 3 - Pricing:**
   - Price: `25`
   - Payment Schedule: **Per Class**
   - Max Students: `15`
   - Make-up Classes: **ON**
5. **Step 4 - Review:**
   - Verify all details
   - Click "Create Class"
6. ✓ Dialog shows shareable link
7. **COPY LINK**
8. Click "Done"

**Step 5.3: Create Private Individual Class**
1. Create Class again
2. Fill in:
   - Title: `Advanced Soccer Training (1-on-1)`
   - Description: `Personalized soccer coaching`
   - Public: **OFF** (Private)
   - Group: **OFF** (Individual)
   - Schedule: Weekly, In-Person
   - Price: $50
   - Payment: **Monthly**
   - Make-up: **ON**
3. Create
4. ✓ No shareable link (private class)

**Verify:**
- ✓ Coach dashboard shows 2 classes
- ✓ One public, one private
- ✓ Different pricing models

---

#### Coach Account 2: "Lisa Wang"

**Step 5.4: Create Coach B**
1. Logout
2. Register:
   - Name: `Lisa Wang`
   - Email: `coach.lisa@test.com`
   - Password: `coach123456`
   - Type: **COACH**
3. ✓ Coach Dashboard

**Step 5.5: Create Online Group Class**
1. Create Class:
   - Title: `Piano Lessons - Group`
   - Description: `Learn piano in a fun group setting`
   - Public: **ON**
   - Group: **ON**
   - Type: Weekly
   - Location: **Online**
   - Meeting Link: `https://zoom.us/j/123456789`
   - Price: $30
   - Payment: **Per Class**
   - Max Students: 10
   - Make-up: **ON**
2. Create & copy link

**Step 5.6: Create Online Individual Class**
1. Create Class:
   - Title: `Piano Lessons - Private (1-on-1)`
   - Description: `Personalized piano instruction`
   - Public: **OFF**
   - Group: **OFF**
   - Online: Zoom link
   - Price: $60
   - Payment: **Monthly**
2. Create class

**Verify:**
- ✓ Lisa sees only her 2 classes
- ✓ Does NOT see David's classes
- ✓ Both online classes show meeting links

---

### Phase 6: Cross-Feature Testing (5 min)

#### Test: View as Emma (Points Update)

**Step 6.1: Login as Emma**
1. Logout
2. Login: Emma's credentials
3. Go to Overview tab
4. ✓ Total Points: 15 pts (approved tasks)
5. ✓ Completed tasks show "Approved" status
6. ✓ Pending task still shows "Complete" button

---

#### Test: Sarah's Complete View

**Step 6.2: Login as Sarah**
1. Login: `sarah.johnson@test.com` / `test123456`
2. **Overview Tab:**
   - ✓ Shows 2 children
   - ✓ Shows active tasks count
   - ✓ Shows completed tasks count
3. **Children Tab:**
   - ✓ Shows Emma & Liam
   - ✓ Each with their color
   - ✓ Email addresses shown
4. **Tasks Tab:**
   - ✓ Emma's section: 3 tasks, 15 pts earned
   - ✓ Liam's section: 3 tasks, 13 pts earned
   - ✓ Approved tasks marked differently
5. **Calendar Tab:**
   - ✓ Navigate to calendar
   - ✓ See tasks on calendar
   - ✓ Color-coded by child

---

#### Test: Michael's Isolation

**Step 6.3: Login as Michael**
1. Login: `michael.chen@test.com` / `test123456`
2. **Verify Isolation:**
   - ✓ Children tab: ONLY Sophia & Noah
   - ✓ Tasks tab: ONLY Sophia & Noah's tasks
   - ✓ Does NOT see Emma, Liam, or their tasks
   - ✓ Points shown are for Sophia only

---

### Phase 7: Dev Tools Testing (2 min)

**Step 7.1: Clear Tasks Test**
1. Login as Sarah
2. Click bug icon (🐛)
3. Click "Clear All Tasks"
4. ✓ Confirm tasks cleared
5. Go to Tasks tab
6. ✓ Shows "No tasks yet"

**Step 7.2: Verify Other Parents Unaffected**
1. Logout
2. Login as Michael
3. Go to Tasks tab
4. ✓ Michael's tasks ALSO cleared (global clear)
5. ✓ Children still present

---

## 📊 Complete Test Checklist

### Parent Features Testing

- [ ] Register Parent A (Sarah)
- [ ] Register Parent B (Michael)
- [ ] Add child with auto credentials (Emma)
- [ ] Add child with custom credentials (Liam)
- [ ] Add children for Parent B (Sophia, Noah)
- [ ] Verify Parent A sees only their children
- [ ] Verify Parent B sees only their children
- [ ] Create tasks for Emma (3 tasks)
- [ ] Create tasks for Liam (3 tasks)
- [ ] Create weekly task with day selection
- [ ] Verify tasks grouped by child
- [ ] Verify Parent A sees only their tasks
- [ ] Verify Parent B sees only their tasks
- [ ] Approve completed tasks
- [ ] See points update after approval
- [ ] Use dev tools to clear tasks
- [ ] Verify children persist after clearing tasks

### Child Features Testing

- [ ] Login as Emma (auto-generated credentials)
- [ ] Login as Liam (custom credentials)
- [ ] Login as Sophia (custom credentials)
- [ ] Login as Noah (auto-generated credentials)
- [ ] Verify each child sees personalized welcome
- [ ] Verify each child sees only their tasks
- [ ] Complete task with photo upload
- [ ] Complete task without photo
- [ ] Verify photo preview works (web)
- [ ] See "Pending Approval" status
- [ ] See points update after approval
- [ ] View calendar with their tasks

### Coach Features Testing

- [ ] Register Coach A (David)
- [ ] Register Coach B (Lisa)
- [ ] Create public group class (David)
- [ ] Create private individual class (David)
- [ ] Create online group class (Lisa)
- [ ] Create online private class (Lisa)
- [ ] Verify shareable link for public classes
- [ ] Verify no link for private classes
- [ ] Coach A sees only their classes
- [ ] Coach B sees only their classes
- [ ] Payment schedule options work
- [ ] Make-up classes toggle works
- [ ] In-person vs online selection works

### Multi-Tenancy Testing

- [ ] Create 2 parents
- [ ] Each adds 2 children
- [ ] Each creates tasks for their children
- [ ] Parent A cannot see Parent B's children
- [ ] Parent A cannot see Parent B's tasks
- [ ] Child A cannot see Child B's tasks
- [ ] Coach A cannot see Coach B's classes

### UI/UX Testing

- [ ] Tasks grouped by child show correctly
- [ ] Child colors display in headers
- [ ] Points totals calculate correctly
- [ ] Approval button appears only for completed tasks
- [ ] Custom credentials toggle works
- [ ] Weekly day selection displays chips
- [ ] Selected days show in review
- [ ] Image upload shows preview
- [ ] Dev tools menu accessible

---

## 🎨 Expected Results

### Parent Dashboard - Sarah Johnson

**Overview Tab:**
```
Total Children: 2
Active Tasks: 2
Completed Tasks: 4
Upcoming Classes: 0
```

**Children Tab:**
```
1. Emma Johnson (🟢 Green)
   emma.######@sparktracks.child

2. Liam Johnson (🔵 Blue)  
   liam.johnson@test.com
```

**Tasks Tab:**
```
┌─────────────────────────────────┐
│ 🟢 Emma Johnson                 │
│ 3 tasks  ⭐ 15 pts             │
├─────────────────────────────────┤
│ ✅ Complete Math Homework (10)  │
│ ✅ Clean Your Room (5)          │
│ ⏰ Read for 20 minutes (3)      │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 🔵 Liam Johnson                 │
│ 3 tasks  ⭐ 13 pts             │
├─────────────────────────────────┤
│ ✅ Piano Practice (5) [WEEKLY]  │
│ ✅ Practice Soccer (8)          │
│ ⏰ Help with Dishes (4)         │
└─────────────────────────────────┘
```

### Child Dashboard - Emma

**Overview Tab:**
```
Welcome back, Emma! 👋

Total Points: 15 pts
Pending: 0 pts
Tasks Done: 2
```

**Tasks Tab:**
```
✅ Complete Math Homework - APPROVED (10 pts)
✅ Clean Your Room - APPROVED (5 pts)
⏰ Read for 20 minutes - PENDING (3 pts)
```

### Coach Dashboard - David Martinez

**Overview Tab:**
```
Welcome back, David Martinez!

Total Students: 0
Active Classes: 2
Today's Revenue: $0
```

**Classes Tab:**
```
1. Soccer Training for Beginners
   📍 Community Sports Center
   👥 Group (0/15)
   💰 $25 per class
   🔗 Shareable Link Available

2. Advanced Soccer Training (1-on-1)
   📍 In-Person
   👥 Individual (0/1)
   💰 $50 monthly
   🔒 Private
```

---

## 🐛 Common Issues & Solutions

### Issue: "Email already in use"
**Solution:** Account already exists. Try logging in or use different email

### Issue: Coach redirect not working
**Solution:** Fixed! Should now go to coach dashboard. Refresh browser.

### Issue: Can't see tasks as child
**Solution:** Make sure task was assigned using child's Firebase User ID (fixed now)

### Issue: "Unknown Child" showing
**Solution:** Fixed! Now looks up by userId

### Issue: Picture upload fails on web
**Solution:** Fixed! Now uses network image for web

### Issue: See other parent's data
**Solution:** Fixed! Each parent sees only their own data

---

## 💡 Pro Testing Tips

1. **Keep a notepad** with all credentials you create
2. **Use browser tabs** - Keep parent in one tab, child in incognito
3. **Check console (F12)** - Watch for errors
4. **Use dev tools** - Clear data between test runs
5. **Take screenshots** - Document what you see
6. **Test systematically** - Follow this plan in order

---

## 📝 Test Data Template

Use this to track your test accounts:

```
PARENT ACCOUNTS:
1. sarah.johnson@test.com / test123456
   - Children: Emma (auto), Liam (custom: liam.johnson@test.com)
   
2. michael.chen@test.com / test123456
   - Children: Sophia (custom: sophia.chen@test.com), Noah (auto)

CHILD ACCOUNTS:
1. emma.######@sparktracks.child / Emma0315
2. liam.johnson@test.com / liam123456
3. sophia.chen@test.com / sophia123
4. noah.######@sparktracks.child / Noah0105

COACH ACCOUNTS:
1. coach.david@test.com / coach123456
   - Classes: Soccer (public, group), Advanced (private, 1-on-1)
   
2. coach.lisa@test.com / coach123456
   - Classes: Piano Group (public), Piano Private (private, 1-on-1)
```

---

## ✅ Success Criteria

You've successfully completed all tests when:

1. ✅ All 6 accounts created (2 parents, 4 children)
2. ✅ Parents see only their own children
3. ✅ 10+ tasks created across all children
4. ✅ Tasks properly grouped by child in parent view
5. ✅ Children complete tasks successfully
6. ✅ Photo upload works
7. ✅ Parents approve tasks
8. ✅ Points calculate correctly
9. ✅ 2 coach accounts created
10. ✅ 4 classes created (different configurations)
11. ✅ Shareable links generated for public classes
12. ✅ Complete data isolation verified
13. ✅ All features work without errors

---

## 🚀 Ready to Start!

**The app is running in Chrome.**

**Follow this test plan step by step to validate all functionality!**

**Start with Phase 1 → Parent Accounts & Children**

**Good luck! Let me know if you encounter any issues during testing.** 🎉


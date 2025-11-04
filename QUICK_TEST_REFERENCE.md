# 🚀 Quick Test Reference Card

## Test Accounts to Create

### Parents
```
1. sarah.johnson@test.com / test123456
2. michael.chen@test.com / test123456
```

### Children (Created by Parents)
```
Sarah's Children:
  - Emma (auto): emma.######@sparktracks.child / Emma0315
  - Liam (custom): liam.johnson@test.com / liam123456

Michael's Children:
  - Sophia (custom): sophia.chen@test.com / sophia123
  - Noah (auto): noah.######@sparktracks.child / Noah0105
```

### Coaches
```
1. coach.david@test.com / coach123456
2. coach.lisa@test.com / coach123456
```

---

## Quick Actions

### Clear All Data
`Login as Parent → Click 🐛 icon → Clear All Tasks`

### Add Child (Auto)
`Children Tab → Add Child → Name + DOB + Color → Toggle OFF → Save`

### Add Child (Custom)
`Children Tab → Add Child → Name + DOB + Color → Toggle ON → Email + Password → Save`

### Create Task
`Tasks Tab → Create Task → 4 Steps → Create`

### Create Weekly Task
`Create Task → Step 2 → Recurring ON → Weekly → Select Days`

### Create Class
`Coach Dashboard → Create Class → 4 Steps → Create`

### Complete Task (Child)
`Tasks Tab → Select Task → Complete → Add Note/Photo → Confirm`

### Approve Task (Parent)
`Tasks Tab → Find Completed Task → Click APPROVE button`

---

## Feature Checklist

### ✅ What's Working:
- Multi-parent isolation
- Multiple children per parent
- Custom & auto child credentials
- Task creation & assignment
- Tasks grouped by child
- Weekly tasks with day selection
- Task completion with photos (web!)
- Task approval & points
- Coach account creation
- Class creation wizard
- Public/Private classes
- Group/Individual classes
- Payment schedules
- Make-up classes toggle
- Shareable links
- Dev tools

### 🚧 Advanced Features (Future):
- Class enrollment UI
- Attendance marking interface
- Payment tracking dashboard
- Automated notifications

---

## Test Flow (30 min)

```
1. Clear Data (1 min)
   └─ Login as parent → 🐛 → Clear All

2. Create Parents (3 min)
   ├─ Register Sarah → Add Emma & Liam
   └─ Register Michael → Add Sophia & Noah

3. Create Tasks (5 min)
   ├─ Sarah: 6 tasks (3 for Emma, 3 for Liam)
   └─ Michael: 4 tasks (2 for Sophia, 2 for Noah)

4. Complete Tasks (5 min)
   ├─ Login as Emma → Complete 2 tasks
   ├─ Login as Liam → Complete 2 tasks
   └─ Login as Sophia → Complete 1 task

5. Approve Tasks (3 min)
   ├─ Login as Sarah → Approve Emma & Liam's tasks
   └─ Login as Michael → Approve Sophia's task

6. Create Coaches (2 min)
   ├─ Register David
   └─ Register Lisa

7. Create Classes (8 min)
   ├─ David: 2 classes (public group, private 1-on-1)
   └─ Lisa: 2 classes (online group, online 1-on-1)

8. Verify (3 min)
   ├─ Check data isolation
   ├─ Check points calculation
   └─ Check class creation
```

---

## 🎯 Critical Tests

**Must Verify:**

1. **Data Isolation:**
   - Parent A can't see Parent B's children ✓
   - Parent A can't see Parent B's tasks ✓
   - Child A can't see Child B's tasks ✓

2. **Points System:**
   - Points = 0 before approval ✓
   - Points update after approval ✓
   - Points total shows in parent view ✓

3. **Custom Credentials:**
   - Child can login with custom email ✓
   - Child sees correct personalized name ✓

4. **Weekly Tasks:**
   - Can select multiple days ✓
   - Days show in review ✓

5. **Class Creation:**
   - Public gets shareable link ✓
   - Private has no link ✓
   - Payment options work ✓

---

## 📱 Where to Find Things

**Dev Tools:** Parent Dashboard → Top right → 🐛 icon

**Add Child:** Parent Dashboard → Children tab → "Add Child" button

**Create Task:** Parent Dashboard → Bottom right → "Create Task" FAB

**Create Class:** Coach Dashboard → Bottom right → "Create Class" FAB

**Complete Task:** Child Dashboard → Tasks tab → Click task → "Complete Task" button

**Approve Task:** Parent Dashboard → Tasks tab → Completed task → "APPROVE" button

---

## 🎨 Visual Indicators

**Child Colors in Parent Dashboard:**
- 🟢 Green
- 🔵 Blue  
- 🟣 Purple
- 🟠 Orange

**Task Status:**
- ⏰ Pending
- ▶️ In Progress
- ✓ Completed (awaiting approval)
- ✅ Approved

**Class Visibility:**
- 🔗 Public (has shareable link)
- 🔒 Private (invite only)

**Class Type:**
- 👥 Group (multiple students)
- 👤 Individual (1-on-1)

---

**Open `COMPREHENSIVE_TEST_PLAN.md` for detailed step-by-step instructions!**

**App is running in Chrome - start testing now!** 🚀


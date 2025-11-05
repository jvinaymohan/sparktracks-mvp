# 🚀 QUICK TEST REFERENCE CARD

**App URL:** http://localhost:8080

---

## 📋 TEST ACCOUNTS (Copy & Paste Ready)

### Parents:
```
parent1@test.com / Password123!
parent2@test.com / Password123!
parent3@test.com / Password123!
parent4@test.com / Password123!
parent5@test.com / Password123!
```

### Children (create via parent accounts):
```
child1@test.com / Password123! → parent1
child2@test.com / Password123! → parent2
child3@test.com / Password123! → parent3
child4@test.com / Password123! → parent4
child5@test.com / Password123! → parent5
```

### Coach:
```
coach1@test.com / Password123!
```

---

## ⚡ QUICK TEST FLOW

### 1️⃣ CREATE PARENTS (5 mins)
- Sign Up → Parent → Register 5 accounts
- Each sees welcome screen → Dashboard

### 2️⃣ CREATE CHILDREN (5 mins)
- Login as each parent
- Children tab → Add Child
- Enable custom credentials
- Use child emails above

### 3️⃣ CREATE TASKS (10 mins)
- Parent 1: Daily task
- Parent 2: **Weekly** → Select Mon, Wed, Fri ⭐
- Parent 3: **Monthly** → Select 15th ⭐
- Parent 4: Multi-child task ⭐

### 4️⃣ COMPLETE TASKS (5 mins)
- Login as each child
- Complete task
- Add comment
- Check "Pending Approval"

### 5️⃣ APPROVE TASKS (5 mins)
- Login as each parent
- Check "Waiting for Approval"
- Approve tasks
- Verify points awarded

### 6️⃣ COACH CLASSES (15 mins)
- Register coach
- Create weekly class → **Select days** ⭐
- Create monthly class → **Select day 15th** ⭐
- Test **currency changes** (USD→EUR→INR) ⭐
- **Edit class** ⭐
- **Assign students** (multi-select) ⭐
- Create new child via Manage Students ⭐
- Verify enrollment in child view

---

## 🎯 KEY FEATURES TO TEST

### ⭐ NEW FEATURES (Priority):
- [ ] Weekly day selection (Mon, Tue, Wed, etc.)
- [ ] Monthly day selection (1st-31st)
- [ ] Currency symbol updates ($ → € → ₹)
- [ ] Edit class functionality
- [ ] Assign students with search
- [ ] Multi-child task assignment
- [ ] No mock transactions in ledger

### ✅ Core Features:
- [ ] Parent registration & login
- [ ] Child creation with custom credentials
- [ ] Task creation (daily, weekly, monthly)
- [ ] Task completion with comments
- [ ] Task approval & points
- [ ] Coach registration & profile
- [ ] Class creation & enrollment

---

## 📱 BROWSER TOOLS

### Open Dev Console (F12):
- **Console tab:** Check for errors
- **Network tab:** Check API calls
- **Application tab:** Check local storage

### Test Responsiveness:
- Press Ctrl+Shift+M (Cmd+Shift+M on Mac)
- Test mobile, tablet, desktop views

---

## 🐛 IF YOU FIND BUGS:

Note down:
1. **What you did:** Step-by-step actions
2. **What happened:** Actual result
3. **What you expected:** Expected result
4. **Screenshot:** If visual issue
5. **Console errors:** From F12 console

---

## ⏱️ ESTIMATED TIME

- **Full Test:** 45 minutes
- **Quick Test:** 20 minutes (key features only)
- **New Features Only:** 10 minutes

---

## 📞 TEST SUPPORT

If stuck, check:
1. **MANUAL_TEST_GUIDE.md** - Detailed step-by-step
2. **END_TO_END_TEST_RESULTS.md** - Test template
3. **CLASS_MANAGEMENT_IMPROVEMENTS.md** - Feature docs

---

**🎯 FOCUS:** Test the 7 NEW features we deployed today!

1. ✨ Weekly day selection
2. ✨ Monthly day selection  
3. ✨ Dynamic currency symbol
4. ✨ Edit class
5. ✨ Assign students
6. ✨ Multi-child tasks
7. ✨ Clean financial ledger

---

**Ready? Let's test! 🚀**

Open: http://localhost:8080

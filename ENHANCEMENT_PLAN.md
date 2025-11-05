# 🚀 Sparktracks Enhancement Plan

## 📋 User Feedback & Feature Requests

### Priority: HIGH (Quick Wins - Do First!)

#### 1. ✅ Remove Default Tasks
**Issue:** Default tasks showing for children  
**Fix:** Clear mock data, ensure clean slate  
**Time:** 5 minutes  
**Impact:** HIGH

#### 2. ✅ Show Points Instead of Dollar Values
**Issue:** Child sees $ instead of points  
**Fix:** Already fixed in parent dashboard, need to fix child dashboard  
**Time:** 5 minutes  
**Impact:** HIGH

#### 3. 📅 Add Day of Month Selection for Monthly Tasks
**Issue:** Can't choose which day of month for recurring monthly tasks  
**Fix:** Add day selector (1-31) in task wizard  
**Time:** 15 minutes  
**Impact:** MEDIUM

#### 4. 👥 Assign Task to Multiple Children
**Issue:** Can only assign to one child at a time  
**Fix:** Change dropdown to multi-select checkboxes  
**Time:** 20 minutes  
**Impact:** HIGH

---

### Priority: MEDIUM (Important UX Improvements)

#### 5. 📊 Parent Dashboard - Tasks for Today
**Enhancement:** Show today's tasks prominently  
**Implementation:**
- Add "Tasks for Today" card at top
- Filter tasks where dueDate = today
- Group by child
**Time:** 30 minutes  
**Impact:** HIGH

#### 6. 👶 Parent Dashboard - Group Tasks by Child
**Enhancement:** Main screen shows tasks grouped by child  
**Implementation:**
- Already partially done
- Make it more prominent
- Add child avatars/colors
**Time:** 20 minutes  
**Impact:** MEDIUM

#### 7. 📅 Calendar View on Main Screen
**Enhancement:** Show calendar view on parent/child dashboards  
**Implementation:**
- Add mini calendar widget
- Show tasks on calendar
- Click to see details
**Time:** 45 minutes  
**Impact:** HIGH

#### 8. 👦 Child Dashboard - Tasks for Today
**Enhancement:** Show today's tasks first  
**Implementation:**
- Add "Today's Tasks" section
- Separate from "All Tasks"
**Time:** 20 minutes  
**Impact:** MEDIUM

---

### Priority: LOW (Advanced Features - Future)

#### 9. 🎨 Optimize Task Creation UX
**Enhancement:** Make task creation wizard even simpler  
**Ideas:**
- Reduce steps from 4 to 3
- Add quick-create option
- Save as template
- Duplicate existing task
**Time:** 1-2 hours  
**Impact:** MEDIUM

#### 10. 👨‍🏫 Coach - Assign Homework to All Students
**Enhancement:** Coaches can assign tasks to entire class  
**Implementation:**
- New "Assign Homework" feature
- Select class
- Create task
- Assigned to all enrolled students
**Time:** 1 hour  
**Impact:** HIGH (for coaches)

#### 11. 🤖 Coach - AI-Powered Profile Page
**Enhancement:** Generate professional coach website with AI  
**Implementation:**
- Integrate OpenAI API
- Generate profile based on:
  - Experience
  - Classes taught
  - Certifications
  - Style preferences
- Create shareable link
- Allow public class registration
**Time:** 3-4 hours  
**Impact:** VERY HIGH (game-changer!)

#### 12. 🔗 Coach - Shareable Profile Page
**Enhancement:** Coach profile acts as personal website  
**Features:**
- Public URL: sparktracks.com/coach/[username]
- Show classes, bio, schedule
- Allow direct enrollment
- Testimonials
- Photo gallery
**Time:** 2 hours  
**Impact:** HIGH

---

## 🎯 RECOMMENDED IMPLEMENTATION ORDER

### Phase 1: Quick Fixes (Tonight - 1 hour)
1. ✅ Remove default tasks
2. ✅ Fix child dashboard points display
3. ✅ Add day of month selector for monthly tasks
4. ✅ Enable multi-child task assignment

### Phase 2: Dashboard Improvements (This Week - 2 hours)
5. Add "Tasks for Today" to parent dashboard
6. Improve task grouping by child
7. Add calendar view to parent dashboard
8. Add "Tasks for Today" to child dashboard

### Phase 3: Advanced Features (Next Week - 4 hours)
9. Optimize task creation UX
10. Coach homework assignment feature
11. Basic coach shareable profile

### Phase 4: AI Features (Future - 6 hours)
12. AI-powered coach profile generation
13. Dynamic website creation
14. Smart recommendations

---

## 💡 TECHNICAL NOTES

### For Multi-Child Assignment:
```dart
// Change from single child:
String? _selectedChildId;

// To multiple children:
Set<String> _selectedChildIds = {};

// UI: CheckboxListTile for each child
```

### For Day of Month Selection:
```dart
// Add to monthly tasks:
int? _selectedDayOfMonth; // 1-31

// Validation: 
// - Feb: 1-28/29
// - Apr, Jun, Sep, Nov: 1-30
// - Others: 1-31
```

### For Tasks for Today:
```dart
// Filter:
final todaysTasks = tasks.where((task) {
  return task.dueDate != null &&
         DateUtils.isSameDay(task.dueDate, DateTime.now());
}).toList();
```

### For AI Profile Generation:
```dart
// Use OpenAI API or Claude API:
final profile = await generateCoachProfile(
  experience: coach.experience,
  classes: coach.classes,
  style: coach.preferredStyle,
);

// Generate:
// - Professional bio
// - Class descriptions
// - Testimonial templates
// - Color scheme
// - Layout
```

---

## 🚀 LET'S START WITH PHASE 1!

**Ready to implement the quick fixes:**
1. Remove default tasks
2. Fix points display
3. Add day of month selector
4. Multi-child assignment

**These will make the biggest immediate impact!**

**Shall I start implementing these now?**


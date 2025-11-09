# Sparktracks Design System v1.0
**Last Updated:** November 10, 2025  
**Author:** UX Design Team

---

## 🎨 **DESIGN PHILOSOPHY**

**"Simple. Elegant. Consistent."**

Every screen, every interaction, every component should feel like part of one unified experience. Whether you're a parent managing tasks, a coach creating classes, or a child completing activities - the experience should be **familiar, intuitive, and delightful**.

---

## 🏗️ **CORE PRINCIPLES**

### 1. **Progressive Disclosure**
Start simple, reveal complexity only when needed.
- Default views show essential information
- Details available on interaction
- Wizards guide step-by-step for complex tasks

### 2. **Visual Hierarchy**
Information organized by importance:
- Primary actions: Large, colorful, prominent
- Secondary actions: Subtle, accessible
- Tertiary actions: Hidden in menus

### 3. **Consistent Patterns**
Same patterns used everywhere:
- Navigation: Tab-based dashboards
- Actions: Floating Action Button (FAB)
- Forms: Multi-step wizards
- Lists: Card-based layouts

### 4. **Feedback & Delight**
Users always know what's happening:
- Loading states
- Success animations
- Error messages (friendly, helpful)
- Celebration moments (confetti, lottie)

---

## 🎯 **COMPONENT LIBRARY**

### **1. DASHBOARD STRUCTURE** (Universal)

**ALL dashboards (Parent/Coach/Child/Admin) follow this pattern:**

```dart
Scaffold(
  appBar: AppBar(
    // [1] Leading: Home Icon Button (gradient background)
    leading: GradientHomeButton(),
    
    // [2] Title: Personalized greeting
    title: WelcomeText(name: userName),
    
    // [3] Bottom: Tab Bar (if multi-section dashboard)
    bottom: TabBar(...),
    
    // [4] Actions: 3-5 consistent actions
    actions: [
      NotificationsButton(),
      CalendarButton(),
      FeedbackButton(),
      SettingsButton(),
      LogoutButton(),
    ],
  ),
  
  body: TabBarView(...) or SingleChildScrollView(...),
  
  // [5] FAB: Context-aware primary action
  floatingActionButton: SmartFAB(),
);
```

**Key Elements:**

1. **Gradient Home Icon** (top-left)
   - Purple-pink gradient background
   - Home icon in white
   - Always returns to Overview/first tab
   - Consistent across all dashboards

2. **Personalized Title**
   - Parent: "Welcome, {FirstName}"
   - Coach: "Coach Dashboard" or "Welcome, Coach {Name}"
   - Child: "Welcome back, {Name}! 👋"
   - Admin: "Admin Portal"

3. **Tab Navigation** (when multiple sections)
   - 4-6 tabs maximum
   - Icon + Text label
   - Positioned in AppBar bottom
   - Scrollable if >4 tabs

4. **Action Icons** (top-right)
   - Consistent order: Notifications → Calendar → Feedback → Settings → Logout
   - Each with tooltip
   - Minimal icons (no text)

5. **Smart FAB** (bottom-right)
   - Changes based on active tab
   - Primary action for that context
   - Example: "Add Task", "Create Class", "Complete Activity"

---

### **2. WIZARD PATTERN** (Universal)

**ALL multi-step forms (Task Creation, Class Creation, Profile Setup) use:**

```
┌─────────────────────────────────────────────────┐
│  [Step 1] ━━━━ [Step 2] ━━━━ [Step 3] ━━━━ ✓  │ ← Progress Indicator
├─────────────────────────────────────────────────┤
│                                                 │
│  📝 Step Title                                  │
│  Brief description of what to do                │
│                                                 │
│  [Input Fields]                                 │
│                                                 │
│  [Preview/Validation]                           │
│                                                 │
├─────────────────────────────────────────────────┤
│  [< Back]                    [Next / Publish >] │ ← Navigation Buttons
└─────────────────────────────────────────────────┘
```

**Elements:**

1. **Progress Indicator**
   - Numbered steps (1, 2, 3, 4)
   - Active step highlighted
   - Completed steps: checkmark
   - Future steps: greyed out

2. **Step Content**
   - Clear title (e.g., "Choose Activity", "Set Schedule")
   - Brief description (1-2 sentences)
   - Form fields (max 3-5 per step)
   - Live preview when helpful

3. **Navigation**
   - Back button (left): Goes to previous step
   - Next/Publish button (right): Primary action
   - Skip option if applicable

4. **Validation**
   - Inline validation (as user types)
   - Error messages below fields
   - Can't proceed if errors exist

---

### **3. CARD LAYOUTS** (Universal)

**ALL lists use card-based layouts:**

**Small Card** (Grid View - 2-4 per row):
```
┌─────────────────┐
│ 🎨 [Icon/Image] │
│                 │
│ Title           │
│ Subtitle        │
│                 │
│ [Stat] [Stat]   │
│ [Action Button] │
└─────────────────┘
```

**Large Card** (List View - 1 per row):
```
┌────────────────────────────────────────┐
│ [Icon] Title              [Badge] [⋮]  │
│        Subtitle                        │
│                                        │
│ [Detail 1] [Detail 2] [Detail 3]      │
│                                        │
│ [Action 1] [Action 2]                 │
└────────────────────────────────────────┘
```

**Consistent Elements:**
- 16px border radius
- 4-8px elevation
- 16px padding
- Gradient headers for categories
- Badge for status (pending, active, completed)
- Action buttons at bottom

---

### **4. STAT CARDS** (Universal)

**Used for dashboards metrics:**

```
┌────────────────┐
│   [Icon]       │
│   123          │ ← Large number
│   Label        │ ← Small text
└────────────────┘
```

**Variations:**
- 2x2 grid (mobile)
- 4x1 row (desktop)
- Color-coded by type:
  * Success: Green (completed, earned)
  * Warning: Orange (pending, due)
  * Primary: Purple (total, active)
  * Info: Blue (classes, enrolled)

---

### **5. MARKETPLACE VIEWS** (Universal)

**Browse Classes / Discover Marketplace:**

```
┌────────────────────────────────────────────────┐
│ 🔍 Search Classes...          [🎛️ Filters]    │
├────────────────────────────────────────────────┤
│ [All] [Online] [In-Person] [Sports] [Music]... │ ← Filter Chips
├────────────────────────────────────────────────┤
│                                                │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐          │
│ │Class │ │Class │ │Class │ │Class │          │
│ │Card  │ │Card  │ │Card  │ │Card  │          │
│ │[Icon]│ │[Icon]│ │[Icon]│ │[Icon]│          │
│ │Title │ │Title │ │Title │ │Title │          │
│ │Coach │ │Coach │ │Coach │ │Coach │          │
│ │5/10  │ │8/12  │ │FULL  │ │2/8   │          │
│ │[$50] │ │[$35] │ │[Wait]│ │[$45] │          │
│ │[Book]│ │[Book]│ │[List]│ │[Book]│          │
│ └──────┘ └──────┘ └──────┘ └──────┘          │
│                                                │
└────────────────────────────────────────────────┘
```

**Consistent Features:**
- Search bar at top
- Filter chips below search
- Grid of compact class cards (4 per row on desktop, 2 on mobile)
- Each card shows:
  * Category icon/badge
  * Class title
  * Coach name
  * Enrollment status (X/Y)
  * Price
  * Action button (Book / Waitlist)

---

## 🎨 **COLOR SYSTEM**

### **Primary Palette**
```dart
primaryColor: Color(0xFF6366F1),      // Indigo
accentColor: Color(0xFFEC4899),       // Pink
primaryGradient: LinearGradient(
  colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
)
```

### **Semantic Colors**
```dart
successColor: Color(0xFF10B981),      // Green
warningColor: Color(0xFFF59E0B),      // Amber
errorColor: Color(0xFFEF4444),        // Red
infoColor: Color(0xFF3B82F6),         // Blue
```

### **Neutral Palette**
```dart
neutral50: Color(0xFFF9FAFB),
neutral100: Color(0xFFF3F4F6),
neutral200: Color(0xFFE5E7EB),
neutral300: Color(0xFFD1D5DB),
neutral400: Color(0xFF9CA3AF),
neutral500: Color(0xFF6B7280),
neutral600: Color(0xFF4B5563),
neutral700: Color(0xFF374151),
neutral800: Color(0xFF1F2937),
neutral900: Color(0xFF111827),
```

### **Usage Guidelines**

**Backgrounds:**
- Primary screen: `Colors.white` or `neutral50`
- Cards: `Colors.white`
- Sections: `neutral100`

**Text:**
- Headings: `neutral900`
- Body: `neutral700`
- Captions: `neutral600`
- Disabled: `neutral400`

**Interactive:**
- Primary buttons: `primaryGradient`
- Secondary buttons: `primaryColor`
- Links: `primaryColor`
- Hover: `primaryColor` with 10% opacity

---

## 📏 **SPACING SYSTEM**

```dart
spacingXS:  4.0,   // Tight spacing (icon-text gap)
spacingS:   8.0,   // Small spacing (list item gap)
spacingM:   16.0,  // Medium spacing (card padding)
spacingL:   24.0,  // Large spacing (section gap)
spacingXL:  32.0,  // Extra large spacing (major sections)
spacingXXL: 48.0,  // Huge spacing (page sections)
```

**Usage:**
- Between elements: `spacingS` (8px)
- Card padding: `spacingM` (16px)
- Section spacing: `spacingL` (24px)
- Page margins: `spacingXL` (32px)

---

## 🔤 **TYPOGRAPHY**

```dart
// Headings
headline1: 96px, ExtraBold, letterSpacing: -1.5
headline2: 60px, ExtraBold, letterSpacing: -0.5
headline3: 48px, Bold
headline4: 34px, Bold
headline5: 24px, SemiBold
headline6: 20px, SemiBold

// Body Text
bodyLarge:  16px, Regular, lineHeight: 1.5
bodyMedium: 14px, Regular, lineHeight: 1.5
bodySmall:  12px, Regular, lineHeight: 1.5

// Special
button:     14px, SemiBold, UPPERCASE
caption:    12px, Regular
overline:   10px, SemiBold, UPPERCASE
```

---

## 🧩 **INTERACTION PATTERNS**

### **Buttons**

**Primary (Gradient):**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    gradient: primaryGradient,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
)
```

**Secondary (Outlined):**
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: primaryColor, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
)
```

**Text:**
```dart
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: primaryColor,
  ),
)
```

### **Input Fields**

```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    prefixIcon: Icon(...),
    hintText: '...',
    helperText: '...',
  ),
)
```

### **Loading States**

**Skeleton Loaders:**
- Use shimmer effect
- Match layout of actual content
- Show while fetching data

**Spinners:**
- Use `CircularProgressIndicator`
- Center of screen or inline
- Show during actions (save, load)

### **Empty States**

```
┌───────────────────────────┐
│                           │
│        [Icon]             │ ← Large icon (64px)
│      No Items Yet         │ ← Headline6
│  Add your first item to   │ ← BodyMedium
│      get started!         │
│                           │
│   [+ Add Item Button]     │ ← Primary Action
│                           │
└───────────────────────────┘
```

---

## 🎭 **ANIMATION & MOTION**

### **Transitions**

```dart
// Page transitions
Duration(milliseconds: 300)
Curves.easeInOut

// Card hover/press
Duration(milliseconds: 150)
Curves.easeOut

// Success animations
Lottie animation (1-2 seconds)
Confetti (2 seconds)
```

### **Micro-interactions**

- Button press: Scale 0.95 (150ms)
- Card hover: Elevation 2 → 8 (200ms)
- FAB press: Rotate 45° (if menu)
- Checkbox: Scale in checkmark (200ms)

---

## 📱 **RESPONSIVE DESIGN**

### **Breakpoints**

```dart
mobile:   width < 600px
tablet:   600px ≤ width < 1024px
desktop:  width ≥ 1024px
```

### **Adaptive Layouts**

**Mobile:**
- Single column
- Full-width cards
- Bottom navigation
- FAB primary action

**Tablet:**
- 2-column grids
- Sidebar navigation
- Larger touch targets

**Desktop:**
- 3-4 column grids
- Side navigation always visible
- Hover states
- Keyboard shortcuts

---

## ✅ **ACCESSIBILITY**

### **Requirements**

1. **Color Contrast:** WCAG AA minimum (4.5:1 text, 3:1 large text)
2. **Touch Targets:** Minimum 44x44px
3. **Focus Indicators:** Visible keyboard focus
4. **Screen Readers:** Semantic HTML, ARIA labels
5. **Font Scaling:** Support up to 200%

### **Best Practices**

- Use semantic color + icon (not color alone)
- Provide alt text for images
- Keyboard navigation support
- Error messages with instructions
- Loading announcements

---

## 🚀 **IMPLEMENTATION CHECKLIST**

### **For Every New Screen:**

- [ ] Uses standard dashboard structure
- [ ] Has gradient home button (top-left)
- [ ] Title is personalized or descriptive
- [ ] Actions follow consistent pattern
- [ ] Tab navigation if multi-section
- [ ] FAB for primary action
- [ ] Cards follow standard layouts
- [ ] Colors from design system
- [ ] Spacing from spacing system
- [ ] Typography from type system
- [ ] Loading states implemented
- [ ] Empty states designed
- [ ] Error states handled
- [ ] Success feedback shown
- [ ] Responsive on mobile
- [ ] Accessible (contrast, touch, screen readers)

---

## 🎯 **SPECIFIC PATTERNS**

### **Task Creation = Class Creation**

Both should follow **identical wizard pattern:**

**Steps:**
1. **What** - Choose activity/class type
2. **Details** - Title, description, category
3. **Schedule** - Date, time, recurrence
4. **Settings** - Price/points, participants, location
5. **Review** - Preview + confirm

**Visual:**
- Same progress indicator
- Same navigation buttons
- Same validation style
- Same success animation

### **Dashboard Stat Cards**

**All dashboards show 4 stat cards:**
- Parent: Tasks, Points, Classes, Children
- Coach: Students, Classes, Revenue, Reviews
- Child: Points, Tasks, Classes, Achievements

**Format:**
- 2x2 grid (mobile)
- 4x1 row (desktop)
- Same card style
- Same interaction (tap for details)

### **Marketplace Views**

**Same for all user types:**
- Same search bar
- Same filter chips
- Same class card design
- Same booking flow
- Parent & Child see identical views

---

## 📖 **EXAMPLES**

### **Dashboard AppBar (Universal)**

```dart
AppBar(
  leading: Container(
    margin: EdgeInsets.all(8),
    decoration: BoxDecoration(
      gradient: AppTheme.primaryGradient,
      borderRadius: BorderRadius.circular(8),
    ),
    child: IconButton(
      icon: Icon(Icons.home, color: Colors.white),
      onPressed: () => _goToHome(),
    ),
  ),
  title: Text('Welcome, ${firstName}'),
  bottom: TabBar(
    tabs: [
      Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
      Tab(icon: Icon(Icons.list), text: 'Items'),
      Tab(icon: Icon(Icons.settings), text: 'Settings'),
    ],
  ),
  actions: [
    IconButton(icon: Icon(Icons.notifications), onPressed: ...),
    IconButton(icon: Icon(Icons.calendar_today), onPressed: ...),
    IconButton(icon: Icon(Icons.settings), onPressed: ...),
    IconButton(icon: Icon(Icons.logout), onPressed: ...),
  ],
)
```

### **Wizard Step (Universal)**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Progress
    LinearProgressIndicator(value: currentStep / totalSteps),
    SizedBox(height: 24),
    
    // Title
    Text('Step ${currentStep}: ${stepTitle}', style: AppTheme.headline5),
    SizedBox(height: 8),
    Text(stepDescription, style: AppTheme.bodyMedium),
    SizedBox(height: 32),
    
    // Content
    ...buildStepContent(),
    
    Spacer(),
    
    // Navigation
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          icon: Icon(Icons.arrow_back),
          label: Text('Back'),
          onPressed: currentStep > 1 ? _previousStep : null,
        ),
        ElevatedButton.icon(
          icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
          label: Text(isLastStep ? 'Publish' : 'Next'),
          onPressed: _nextStep,
        ),
      ],
    ),
  ],
)
```

---

## 🎨 **BRAND VOICE**

### **Tone**
- Friendly but professional
- Encouraging but not childish
- Clear and direct
- Celebrate successes

### **Writing Style**
- Short sentences
- Active voice
- Action-oriented verbs
- Positive framing

### **Examples**

**Good:**
- "Create your first class to get started!"
- "3 students enrolled 🎉"
- "Task completed! +10 points"

**Bad:**
- "There are no classes available at this time."
- "Student enrollment has been recorded."
- "Task status updated to completed."

---

## 📝 **SUMMARY**

**Every screen should:**
1. ✅ Feel familiar (consistent patterns)
2. ✅ Be intuitive (clear hierarchy)
3. ✅ Look polished (attention to detail)
4. ✅ Work everywhere (responsive + accessible)

**Key Patterns:**
- Dashboard: Tabs + Smart FAB
- Forms: Multi-step wizards
- Lists: Card-based layouts
- Marketplace: Search + Grid + Filters

**Design Tokens:**
- Colors: Primary gradient (purple-pink)
- Spacing: 4, 8, 16, 24, 32, 48
- Typography: Headlines (Bold) + Body (Regular)
- Radius: 12px for cards, 8px for buttons

---

**This is a living document. Update as patterns evolve!**

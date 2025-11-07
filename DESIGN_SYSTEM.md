# 🎨 Sparktracks Design System v1.0

**Version:** 1.0  
**Last Updated:** November 5, 2025  
**Status:** Official Design System for Web & Mobile Launch  

---

## 📋 Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing & Layout](#spacing--layout)
5. [Components](#components)
6. [Navigation Patterns](#navigation-patterns)
7. [Forms & Inputs](#forms--inputs)
8. [Feedback & States](#feedback--states)
9. [Animations & Transitions](#animations--transitions)
10. [Mobile Guidelines](#mobile-guidelines)
11. [Accessibility](#accessibility)
12. [Implementation Guide](#implementation-guide)

---

## 🎯 Design Philosophy

### Core Principles

**1. Clarity Over Complexity**
- Information should be immediately understandable
- Reduce cognitive load at every step
- Use familiar patterns and conventions

**2. Consistency Across Roles**
- Parents, Children, and Coaches have role-specific features
- But common actions (navigation, feedback) feel consistent
- Visual language stays the same across user types

**3. Delight in Details**
- Smooth animations enhance, don't distract
- Gradients add depth and visual interest
- Micro-interactions provide feedback

**4. Mobile-First, Desktop-Enhanced**
- Core experience works perfectly on mobile
- Desktop adds convenience, not functionality
- Touch targets are generous, text is readable

**5. Accessible by Default**
- Colors meet WCAG AA standards
- Focus states are clearly visible
- Screen reader friendly

---

## 🎨 Color System

### Primary Colors

```dart
Primary Color: #6366F1 (Indigo)
RGB: (99, 102, 241)
Use: Main actions, primary buttons, focus states
```

```dart
Primary Variant: #4F46E5 (Indigo Dark)
RGB: (79, 70, 229)
Use: Hover states, active states, gradients
```

### Secondary Colors

```dart
Secondary Color: #10B981 (Emerald)
RGB: (16, 185, 129)
Use: Success states, positive actions, achievements
```

```dart
Secondary Variant: #059669 (Emerald Dark)
RGB: (5, 150, 105)
Use: Hover states for success actions
```

### Accent Colors

```dart
Accent Color: #F59E0B (Amber)
RGB: (245, 158, 11)
Use: Highlights, rewards, points, special features
```

```dart
Warning Color: #F59E0B (Amber)
RGB: (245, 158, 11)
Use: Warnings, attention-needed states
```

### Semantic Colors

```dart
Success: #10B981 (Emerald)
Error: #EF4444 (Red)
Info: #3B82F6 (Blue)
Warning: #F59E0B (Amber)
```

### Neutral Palette

```dart
neutral50:  #F9FAFB (Backgrounds, inputs)
neutral100: #F3F4F6 (Subtle borders)
neutral200: #E5E7EB (Borders)
neutral300: #D1D5DB (Dividers)
neutral400: #9CA3AF (Placeholders)
neutral500: #6B7280 (Secondary text)
neutral600: #4B5563 (Body text)
neutral700: #374151 (Primary text)
neutral800: #1F2937 (Headings)
neutral900: #111827 (Strong headings)
```

### Gradients

**Primary Gradient**
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [#6366F1, #4F46E5],
)
```

**Secondary Gradient**
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [#10B981, #059669],
)
```

**Accent Gradient**
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [#F59E0B, #F59E0B],
)
```

### Color Usage Rules

**DO:**
- ✅ Use primary color for main CTAs
- ✅ Use secondary (green) for success/approval
- ✅ Use accent (amber) for rewards/points
- ✅ Use neutrals for text hierarchy
- ✅ Ensure 4.5:1 contrast ratio for text

**DON'T:**
- ❌ Mix gradients on the same screen
- ❌ Use more than 3 colors per component
- ❌ Use pure black (#000000)
- ❌ Use semantic colors for decoration

---

## 📝 Typography

### Font Family

**Primary Font:** Poppins (Google Fonts)
- Modern, friendly, highly readable
- Excellent on screens
- Wide language support

**Fallback Stack:**
```css
font-family: 'Poppins', -apple-system, BlinkMacSystemFont, 
             'Segoe UI', 'Roboto', 'Helvetica', sans-serif;
```

### Type Scale

**Headlines**

```dart
headline1: 32px, Bold, #111827, line-height: 1.2
// Use: Page titles, major sections

headline2: 28px, Bold, #111827, line-height: 1.2
// Use: Section headers

headline3: 24px, Bold, #111827, line-height: 1.2
// Use: Card headers, subsections

headline4: 20px, Bold, #111827, line-height: 1.2
// Use: Component titles

headline5: 18px, Bold, #111827, line-height: 1.2
// Use: List headers, labels

headline6: 16px, Bold, #111827, line-height: 1.2
// Use: Small headers, emphasized text
```

**Body Text**

```dart
bodyLarge: 16px, Regular, #374151, line-height: 1.5
// Use: Main content, descriptions

bodyMedium: 14px, Regular, #374151, line-height: 1.5
// Use: Secondary content, lists

bodySmall: 12px, Regular, #4B5563, line-height: 1.4
// Use: Helper text, metadata

caption: 11px, Regular, #6B7280, line-height: 1.3
// Use: Timestamps, tiny labels
```

### Typography Rules

**DO:**
- ✅ Use headline1-3 for page structure
- ✅ Maintain consistent line-height
- ✅ Use bodyMedium as default body text
- ✅ Keep line length 50-75 characters
- ✅ Use bold for emphasis, not color

**DON'T:**
- ❌ Use more than 3 type sizes per screen
- ❌ Mix font weights randomly
- ❌ Use all caps for long text
- ❌ Set font size below 11px

---

## 📐 Spacing & Layout

### Spacing Scale

```dart
spacingXS:  4px   // Tight spacing (icon to text)
spacingS:   8px   // Small spacing (list items)
spacingM:   16px  // Medium spacing (components)
spacingL:   24px  // Large spacing (sections)
spacingXL:  32px  // XLarge spacing (major sections)
spacingXXL: 48px  // XXLarge spacing (page sections)
```

### Border Radius

```dart
radiusSmall:  4px   // Buttons, small elements
radiusMedium: 8px   // Inputs, chips, badges
radiusLarge:  12px  // Cards, large components
radiusXL:     16px  // Dialogs, major containers
```

### Shadows

**Small Shadow**
```dart
BoxShadow(
  color: Color(0x0A000000),  // 4% black
  blurRadius: 4,
  offset: Offset(0, 1),
)
// Use: Cards, chips, small elevations
```

**Medium Shadow**
```dart
BoxShadow(
  color: Color(0x0A000000),  // 4% black
  blurRadius: 8,
  offset: Offset(0, 2),
)
// Use: Modals, dialogs, elevated cards
```

**Large Shadow**
```dart
BoxShadow(
  color: Color(0x0A000000),  // 4% black
  blurRadius: 16,
  offset: Offset(0, 4),
)
// Use: Floating actions, major elevation
```

### Layout Grid

**Desktop (> 1024px)**
- Container max-width: 1200px
- Margin: 48px
- Gutters: 24px
- Columns: 12

**Tablet (768px - 1024px)**
- Container max-width: 100%
- Margin: 32px
- Gutters: 16px
- Columns: 8

**Mobile (< 768px)**
- Container max-width: 100%
- Margin: 16px
- Gutters: 8px
- Columns: 4

### Layout Rules

**DO:**
- ✅ Use spacing scale consistently
- ✅ Align elements to 8px grid
- ✅ Group related elements closely
- ✅ Increase spacing between sections

**DON'T:**
- ❌ Use random spacing values
- ❌ Pack elements too tightly
- ❌ Mix spacing patterns

---

## 🧩 Components

### Buttons

#### Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
      horizontal: 24, vertical: 16
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  ),
  child: Text('Primary Action'),
)
```

**Use Cases:**
- Main CTAs (Create Task, Save, Submit)
- Form submissions
- Confirmation actions

#### Secondary Button (Outlined)
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppTheme.primaryColor,
    side: BorderSide(color: AppTheme.primaryColor),
    padding: EdgeInsets.symmetric(
      horizontal: 24, vertical: 16
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Secondary Action'),
)
```

**Use Cases:**
- Cancel actions
- Alternative choices
- Less important actions

#### Text Button
```dart
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: AppTheme.primaryColor,
    padding: EdgeInsets.symmetric(
      horizontal: 16, vertical: 8
    ),
  ),
  child: Text('Text Action'),
)
```

**Use Cases:**
- Tertiary actions
- Navigation links
- Inline actions

#### Gradient Button (Special)
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
    borderRadius: BorderRadius.circular(8),
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: 24, vertical: 16
      ),
    ),
    child: Text('Special Action'),
  ),
)
```

**Use Cases:**
- Home dashboard button
- Featured actions
- Call-to-action highlights

### Cards

#### Standard Card
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  color: AppTheme.surfaceColor,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(...),
  ),
)
```

#### Elevated Card (with shadow)
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: AppTheme.shadowSmall,
    border: Border.all(color: AppTheme.neutral200),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(...),
  ),
)
```

#### Gradient Card (special)
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(...),
  ),
)
```

### Chips & Badges

#### Filter Chip
```dart
FilterChip(
  label: Text('Category'),
  selected: isSelected,
  onSelected: (selected) => {...},
  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
  checkmarkColor: AppTheme.primaryColor,
)
```

#### Status Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppTheme.successColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'COMPLETED',
    style: TextStyle(
      color: AppTheme.successColor,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### Lists & List Items

#### Task List Item
```dart
Card(
  margin: EdgeInsets.only(bottom: 12),
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: AppTheme.primaryColor,
      child: Icon(Icons.task, color: Colors.white),
    ),
    title: Text('Task Title'),
    subtitle: Text('Due date • Points'),
    trailing: Icon(Icons.chevron_right),
    onTap: () => {...},
  ),
)
```

### Dialogs

#### Standard Dialog
```dart
Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Container(
    constraints: BoxConstraints(maxWidth: 500),
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(...),
    ),
  ),
)
```

---

## 🧭 Navigation Patterns

### 1. Bottom Navigation (Mobile Primary)

**Use For:** Main app sections
**Components:** Parent Dashboard, Child Dashboard, Coach Dashboard

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  selectedItemColor: AppTheme.primaryColor,
  unselectedItemColor: AppTheme.neutral400,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Overview',
    ),
    // ... more items
  ],
)
```

### 2. Tab Navigation (Sectional)

**Use For:** Content categories within a section
**Components:** Dashboard tabs, Admin tabs

```dart
TabBar(
  labelColor: AppTheme.primaryColor,
  unselectedLabelColor: AppTheme.neutral500,
  indicatorColor: AppTheme.primaryColor,
  tabs: [
    Tab(text: 'Tab 1'),
    Tab(text: 'Tab 2'),
  ],
)
```

### 3. App Bar Actions

**Standard App Bar:**
```dart
AppBar(
  backgroundColor: AppTheme.surfaceColor,
  foregroundColor: AppTheme.neutral900,
  elevation: 0,
  centerTitle: true,
  title: Text('Screen Title'),
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => NavigationHelper.goToDashboard(context),
  ),
  actions: [
    NavigationHelper.buildGradientHomeButton(context),
  ],
)
```

### 4. Floating Action Button (FAB)

**Use For:** Primary action on a screen
**Pattern:** Context-aware per tab

```dart
FloatingActionButton.extended(
  onPressed: () => {...},
  backgroundColor: AppTheme.primaryColor,
  icon: Icon(Icons.add),
  label: Text('Quick Task'),
)
```

### Navigation Rules

**DO:**
- ✅ Use consistent back button behavior
- ✅ Provide gradient home button on all screens
- ✅ Keep navigation depth < 3 levels
- ✅ Use breadcrumbs for deep navigation

**DON'T:**
- ❌ Mix navigation patterns on same level
- ❌ Hide back button on child screens
- ❌ Use > 5 tabs in tab navigation

---

## 📝 Forms & Inputs

### Text Input

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Placeholder text',
    helperText: 'Helper text',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: AppTheme.neutral50,
  ),
  validator: (value) => {...},
)
```

### Dropdown

```dart
DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: 'Select Option',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  items: [...],
  onChanged: (value) => {...},
)
```

### Date Picker

```dart
OutlinedButton.icon(
  icon: Icon(Icons.calendar_today),
  label: Text('Select Date'),
  onPressed: () async {
    final date = await showDatePicker(...);
  },
)
```

### Slider

```dart
Slider(
  value: _value,
  min: 0,
  max: 100,
  divisions: 10,
  label: '$_value points',
  activeColor: AppTheme.successColor,
  onChanged: (value) => setState(() => _value = value),
)
```

### Form Rules

**DO:**
- ✅ Group related fields in cards
- ✅ Show validation inline
- ✅ Provide clear error messages
- ✅ Disable submit until form is valid
- ✅ Use appropriate input types

**DON'T:**
- ❌ Show all errors at once
- ❌ Use generic error messages
- ❌ Hide required field indicators

---

## 💬 Feedback & States

### Success Message

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Text('Task created successfully!'),
      ],
    ),
    backgroundColor: AppTheme.successColor,
    duration: Duration(seconds: 3),
  ),
)
```

### Error Message

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.error, color: Colors.white),
        SizedBox(width: 12),
        Text('An error occurred'),
      ],
    ),
    backgroundColor: AppTheme.errorColor,
  ),
)
```

### Loading State

```dart
if (isLoading)
  Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
    ),
  )
```

### Empty State

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox, size: 64, color: AppTheme.neutral400),
      SizedBox(height: 16),
      Text('No tasks yet', style: AppTheme.headline6),
      SizedBox(height: 8),
      Text('Create your first task!', style: AppTheme.bodyMedium),
    ],
  ),
)
```

---

## ✨ Animations & Transitions

### Screen Transitions

**Default:** Fade + Slide
```dart
Duration: 300ms
Curve: easeInOut
```

### Button Press

```dart
onTapDown: scale to 0.95
onTapUp: scale back to 1.0
Duration: 100ms
```

### Card Hover (Desktop)

```dart
Elevation: 0 → 4
Shadow: small → medium
Duration: 200ms
Curve: easeOut
```

### Loading Indicators

```dart
Circular Progress: Indeterminate
Color: AppTheme.primaryColor
Size: 24px (small), 40px (medium)
```

---

## 📱 Mobile Guidelines

### Touch Targets

**Minimum:** 44x44 dp (iOS), 48x48 dp (Android)
**Recommended:** 48x48 dp everywhere

### Responsive Breakpoints

```dart
Mobile: < 768px
Tablet: 768px - 1024px
Desktop: > 1024px
```

### Mobile-Specific

**DO:**
- ✅ Use bottom sheets for actions
- ✅ Make swipeable gestures obvious
- ✅ Keep forms single-column
- ✅ Use system keyboards
- ✅ Test on small screens (iPhone SE)

**DON'T:**
- ❌ Require horizontal scrolling
- ❌ Use hover-only interactions
- ❌ Place actions in corners
- ❌ Use tiny tap targets

---

## ♿ Accessibility

### Color Contrast

**Text:**
- Small text: 4.5:1 minimum
- Large text (18px+): 3:1 minimum

**Interactive:**
- Focus indicators: 3:1 minimum
- Active states: clearly visible

### Screen Readers

```dart
Semantics(
  label: 'Create Task',
  button: true,
  child: IconButton(...),
)
```

### Keyboard Navigation

- All interactive elements focusable
- Logical tab order
- Visible focus indicators
- Escape key closes modals

---

## 🚀 Implementation Guide

### Using AppTheme

```dart
// Import
import 'package:sparktracks_mvp/utils/app_theme.dart';

// Use colors
Container(color: AppTheme.primaryColor)

// Use text styles
Text('Hello', style: AppTheme.headline4)

// Use spacing
SizedBox(height: AppTheme.spacingL)

// Use shadows
decoration: BoxDecoration(boxShadow: AppTheme.shadowMedium)
```

### Creating Consistent Components

**Always:**
1. Check if component exists in design system
2. Use AppTheme constants
3. Follow spacing guidelines
4. Test on mobile first
5. Add accessibility labels

**Never:**
1. Hardcode colors or sizes
2. Create one-off styles
3. Ignore responsive breakpoints
4. Skip accessibility

---

## ✅ Design System Checklist

**Before Launching:**
- [ ] All screens use AppTheme colors
- [ ] Text styles are consistent
- [ ] Spacing follows 8px grid
- [ ] Buttons use standard styles
- [ ] Forms have proper validation
- [ ] Touch targets are 48x48dp minimum
- [ ] Color contrast meets WCAG AA
- [ ] Loading states implemented
- [ ] Empty states designed
- [ ] Error messages are helpful
- [ ] Animations are smooth (60fps)
- [ ] Works on iPhone SE (small)
- [ ] Works on iPad (tablet)
- [ ] Keyboard navigation works
- [ ] Screen reader tested

---

## 📚 Resources

**Color Tools:**
- WebAIM Contrast Checker
- Coolors (palette generator)

**Typography:**
- Google Fonts (Poppins)
- Type Scale Calculator

**Icons:**
- Material Icons
- Feather Icons

**Testing:**
- Chrome DevTools (responsive)
- iOS Simulator
- Android Emulator

---

**This is the official Sparktracks Design System. All new features should follow these guidelines.**

**Questions? Check existing screens for examples, or ask the team!** 🎨


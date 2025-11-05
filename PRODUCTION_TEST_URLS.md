# 🌐 PRODUCTION TEST URLS

## ⚠️ IMPORTANT: Use PRODUCTION URLs for Testing!

The issue reported is that `localhost:8080` (debug mode) has a blank page.  
**Solution:** Use the PRODUCTION builds instead!

---

## ✅ OPTION 1: Firebase Hosting (RECOMMENDED)

**URL:** https://sparktracks-mvp.web.app/

**Why use this:**
- ✅ Production build (optimized)
- ✅ Already deployed
- ✅ Proper routing configured
- ✅ SSL/HTTPS enabled
- ✅ Firebase backend connected

**Use this for all testing!**

---

## ✅ OPTION 2: Local Production Build

**URL:** http://localhost:8081

**Why use this:**
- ✅ Production build (optimized)
- ✅ Faster loading than debug mode
- ✅ Same code as Firebase
- ✅ Good for offline testing

**I just started this for you!**

---

## ❌ DON'T USE: Debug Mode

**URL:** http://localhost:8080 ← **AVOID THIS**

**Why NOT to use this:**
- ❌ Debug mode (slow, large files)
- ❌ May have loading issues
- ❌ Not representative of production
- ❌ Large JavaScript files
- ❌ Extra debugging overhead

---

## 🧪 WHICH URL TO USE FOR TESTING?

### For E2E Testing:
**Use:** https://sparktracks-mvp.web.app/

### For Quick Local Testing:
**Use:** http://localhost:8081

### NEVER Use:
**Avoid:** http://localhost:8080 (debug mode)

---

## 📝 TEST ACCOUNTS (Same for All URLs)

```
PARENTS:
parent1@test.com / Password123!
parent2@test.com / Password123!
parent3@test.com / Password123!
parent4@test.com / Password123!
parent5@test.com / Password123!

CHILDREN:
child1@test.com / Password123!
child2@test.com / Password123!
child3@test.com / Password123!
child4@test.com / Password123!
child5@test.com / Password123!

COACH:
coach1@test.com / Password123!
```

---

## 🔧 HOW TO CHECK IF IT'S WORKING

### Test 1: Page Loads
1. Open URL
2. Wait 2-3 seconds
3. You should see: "Welcome to Sparktracks" or login/signup options
4. ❌ If you see: Only "Enable accessibility" button → It's broken

### Test 2: Registration Works
1. Click "Sign Up Free"
2. You should see: Registration form with email, password fields
3. ❌ If you see: Blank page → It's broken

### Test 3: Login Works
1. Click "Login"
2. You should see: Login form with email, password fields
3. ❌ If you see: Blank page → It's broken

---

## 🐛 IF FIREBASE IS ALSO BLANK:

This means there's a critical build issue. Check:

1. **Browser Console (F12):**
   - Look for JavaScript errors
   - Look for failed network requests
   - Screenshot and share

2. **Network Tab (F12):**
   - Check if `main.dart.js` loaded
   - Check if files are 404ing
   - Screenshot and share

3. **Clear Browser Cache:**
   - Press Ctrl+Shift+Delete (Cmd+Shift+Delete on Mac)
   - Clear cached images and files
   - Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)

4. **Try Incognito:**
   - Open in Incognito/Private window
   - Test if it works there

---

## ✅ EXPECTED BEHAVIOR (Production URLs)

### Landing Page:
- ✅ "Welcome to Sparktracks" heading
- ✅ "Sign Up Free" button
- ✅ "Login" button
- ✅ Feature descriptions
- ✅ About Us section

### After clicking "Sign Up Free":
- ✅ Registration form appears
- ✅ Email field
- ✅ Password field
- ✅ Name field
- ✅ Parent/Coach role selection cards
- ✅ "Create Account" button

### After registration:
- ✅ Welcome screen with role-specific message
- ✅ "Get Started" button
- ✅ Redirects to appropriate dashboard

---

## 🚀 READY TO TEST!

**Primary URL:** https://sparktracks-mvp.web.app/  
**Backup URL:** http://localhost:8081  

**Start testing now!** 🎯


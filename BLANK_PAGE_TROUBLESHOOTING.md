# 🔧 BLANK PAGE TROUBLESHOOTING GUIDE

**Issue:** AI Agent reported "Only Enable accessibility button visible, no registration form"

---

## ⚠️ ROOT CAUSE IDENTIFIED

**Problem:** Using DEBUG MODE `localhost:8080` instead of PRODUCTION BUILD

**Solution:** Use Firebase production URL instead!

---

## ✅ SOLUTION: Use Production URLs

### OPTION 1: Firebase Hosting (BEST)
```
https://sparktracks-mvp.web.app/
```

### OPTION 2: Local Production Build
```
http://localhost:8081
```

### ❌ DON'T USE
```
http://localhost:8080 ← This is DEBUG mode (causes blank page)
```

---

## 🧪 IMMEDIATE TEST STEPS

1. **Open:** https://sparktracks-mvp.web.app/
2. **Wait:** 3-5 seconds for page to load
3. **Expect to see:**
   - ✅ "Welcome to Sparktracks" heading
   - ✅ "Transform Tasks into Adventures" subtitle
   - ✅ "Sign Up Free" button (top right)
   - ✅ "Login" button (top right)
   - ✅ Feature cards
   - ✅ About Us section

4. **Click:** "Sign Up Free"
5. **Expect to see:**
   - ✅ Email input field
   - ✅ Password input field
   - ✅ Confirm Password field
   - ✅ Name field
   - ✅ Parent/Coach role selection cards
   - ✅ "Create Account" button

---

## 🐛 IF STILL BLANK ON FIREBASE:

### Step 1: Check Browser Console

1. Press **F12** (or Cmd+Option+I on Mac)
2. Click **Console** tab
3. Look for red error messages
4. **Screenshot and share these errors**

Common errors:
- `Failed to load resource: 404` → File missing
- `Uncaught TypeError` → JavaScript error
- `CORS error` → Firebase configuration issue

### Step 2: Check Network Tab

1. Press **F12**
2. Click **Network** tab
3. Refresh page (Ctrl+R / Cmd+R)
4. Look for:
   - ✅ `main.dart.js` - Should be 200 OK (3.4 MB)
   - ✅ `flutter_bootstrap.js` - Should be 200 OK
   - ✅ `flutter_service_worker.js` - Should be 200 OK
   - ❌ Any 404 errors? Screenshot them

### Step 3: Clear Browser Cache

1. Press **Ctrl+Shift+Delete** (Cmd+Shift+Delete on Mac)
2. Select:
   - ☑ Cached images and files
   - ☑ Cookies and site data
3. Time range: **Last hour**
4. Click "Clear data"
5. **Hard refresh:** Ctrl+Shift+R (Cmd+Shift+R)

### Step 4: Test in Incognito

1. Press **Ctrl+Shift+N** (Cmd+Shift+N on Mac)
2. Go to: https://sparktracks-mvp.web.app/
3. Does it work in Incognito?
   - ✅ YES → Clear your regular browser cache
   - ❌ NO → Continue to Step 5

### Step 5: Try Different Browser

Test in:
- Chrome ✓
- Firefox
- Safari
- Edge

Does it work in ANY browser?

---

## 🔍 DEBUGGING CHECKLIST

### Check 1: Firebase Deployment Status
```bash
firebase hosting:sites:list
```
Expected: `sparktracks-mvp` should be listed

### Check 2: Latest Deploy Time
- Go to: https://console.firebase.google.com/project/sparktracks-mvp/hosting
- Check "Last deployed" timestamp
- Should be: ~30 minutes ago (when we deployed)

### Check 3: Build Directory Contents
```bash
ls -la build/web/
```
Expected files:
- ✅ `index.html`
- ✅ `main.dart.js` (large file ~3MB)
- ✅ `flutter_bootstrap.js`
- ✅ `flutter_service_worker.js`
- ✅ `assets/` directory
- ✅ `canvaskit/` directory

### Check 4: Index.html Base Href
```bash
grep "base href" build/web/index.html
```
Expected: `<base href="/">`
❌ NOT: `<base href="$FLUTTER_BASE_HREF">`

---

## 🚨 IF FIREBASE IS CONFIRMED BROKEN:

### Emergency Fix: Rebuild & Redeploy

```bash
cd /Users/vinayhome/Documents/sparktracks_mvp

# Clean build
flutter clean

# Rebuild
flutter build web --release

# Check index.html
cat build/web/index.html | grep "base href"

# If shows $FLUTTER_BASE_HREF, fix it:
sed -i '' 's|$FLUTTER_BASE_HREF|/|g' build/web/index.html

# Redeploy
firebase deploy --only hosting

# Test immediately:
# https://sparktracks-mvp.web.app/
```

---

## ✅ EXPECTED WORKING STATE

### Firebase Page Source (View Page Source)
Should contain:
```html
<base href="/">
<script src="flutter_bootstrap.js" async></script>
```

### Browser Console (F12)
Should show:
```
Flutter Web application starting...
[flutter] Registering service worker...
```

### Network Tab
Should load:
- ✅ 200 OK for all resources
- ✅ main.dart.js (3.4 MB)
- ✅ flutter_bootstrap.js (8 KB)

---

## 📊 CURRENT STATUS

**Last Deployment:** ~30 minutes ago  
**Build Status:** ✅ SUCCESS  
**GitHub Status:** ✅ Pushed  
**Firebase Status:** ✅ Deployed  

**Expected to work:** YES  
**Actual status:** TESTING NOW  

---

## 🆘 IF NOTHING WORKS:

**Contact Support With:**
1. Screenshot of F12 Console (errors)
2. Screenshot of F12 Network tab (404s)
3. Screenshot of blank page
4. Browser name and version
5. Operating system
6. URL you're testing

---

## 🎯 NEXT STEPS

1. Test https://sparktracks-mvp.web.app/ RIGHT NOW
2. Open F12 console
3. Report back:
   - ✅ "It works! I see the landing page"
   - ❌ "Still blank. Console shows: [error message]"

---

**Let's confirm if Firebase is working!** 🔍


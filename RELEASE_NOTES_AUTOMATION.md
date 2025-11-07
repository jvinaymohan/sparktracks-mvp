# 🤖 Release Notes Automation Guide

**Goal:** Automatically sync release notes to Firestore when code is committed to GitHub.

---

## 🚀 Quick Start (Right Now - 5 minutes)

### Option 1: Run Sync Script Manually

**Step 1:** Install dependencies
```bash
cd /Users/vinayhome/Documents/sparktracks_mvp
npm install firebase-admin
```

**Step 2:** Get Firebase Service Account Key
1. Go to: https://console.firebase.google.com/project/sparktracks-mvp/settings/serviceaccounts
2. Click "Generate new private key"
3. Save as `serviceAccountKey.json` in project root

**Step 3:** Run the sync script
```bash
node scripts/sync_release_notes.js
```

**Step 4:** Verify
1. Go to: https://sparktracks-mvp.web.app/admin/dashboard
2. Click "Releases" tab
3. ✅ See all 4 releases!

---

## 🤖 Future: GitHub Actions Automation (15 minutes setup)

### How It Works

```
Git Commit → GitHub Actions → Sync Script → Firestore → Admin Panel
```

**When it runs:**
- ✅ Every push to `main` branch
- ✅ When RELEASE_NOTES.md changes
- ✅ When code in `lib/` changes
- ✅ Manual trigger via GitHub Actions UI

### Setup Steps

**Step 1: Create Firebase Service Account Secret**

1. Get service account key (same as above)
2. Go to: https://github.com/jvinaymohan/sparktracks-mvp/settings/secrets/actions
3. Click "New repository secret"
4. Name: `FIREBASE_SERVICE_ACCOUNT`
5. Value: Paste entire contents of serviceAccountKey.json
6. Click "Add secret"

**Step 2: Enable GitHub Actions**

The workflow file is already in place:
```
.github/workflows/sync-release-notes.yml
```

It will automatically run on next commit!

**Step 3: Test It**

1. Make any commit to `main` branch
2. Go to: https://github.com/jvinaymohan/sparktracks-mvp/actions
3. See the "Sync Release Notes to Firestore" workflow running
4. ✅ Wait for completion
5. Check admin panel - release notes updated!

---

## 📝 How to Add New Releases

### Method 1: Update the Sync Script (Recommended)

**File:** `scripts/sync_release_notes.js`

**Add new release object:**
```javascript
{
  version: 'v2.6.0',
  releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-10T10:00:00Z')),
  title: 'Performance & Mobile Optimization',
  description: 'Major speed improvements and mobile enhancements',
  features: [
    'Pagination for large lists',
    'Image optimization',
    'Offline mode support',
    'Push notifications',
  ],
  fixes: [
    'Fixed mobile keyboard overlap',
    'Improved touch targets',
  ],
  security: [
    'Enhanced session management',
  ],
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
}
```

**Run sync:**
```bash
node scripts/sync_release_notes.js
```

### Method 2: Use Admin Panel

1. Login to admin panel
2. Click "Releases" tab
3. Click "Add Release" button
4. Fill in form:
   - Version: v2.6.0
   - Date & Time: Select
   - Title: Enter title
   - Features: Add items
   - Fixes: Add items
   - Security: Add items
5. Click "Save Release"
6. ✅ Appears immediately!

### Method 3: Direct Firestore

1. Go to: https://console.firebase.google.com/project/sparktracks-mvp/firestore
2. Open `releaseNotes` collection
3. Click "Add document"
4. Document ID: v2.6.0
5. Add fields (see structure below)
6. ✅ Appears in admin panel!

---

## 📊 Release Note Structure

**Firestore Document Structure:**
```javascript
{
  version: "v2.6.0",                    // string
  releaseDate: Timestamp,               // timestamp
  title: "Release Title",               // string
  description: "Brief description",     // string
  features: ["Feature 1", "Feature 2"], // array of strings
  fixes: ["Fix 1", "Fix 2"],           // array of strings
  security: ["Security 1"],             // array of strings
  createdAt: Timestamp                  // timestamp (auto)
}
```

---

## 🔄 Workflow Triggers

**GitHub Actions workflow runs when:**

1. **Code Changes:**
   ```bash
   git add lib/screens/new_feature.dart
   git commit -m "Add new feature"
   git push origin main
   # → Workflow runs automatically
   ```

2. **Release Notes Updated:**
   ```bash
   # Edit RELEASE_NOTES.md
   git add RELEASE_NOTES.md
   git commit -m "Update release notes"
   git push origin main
   # → Workflow runs automatically
   ```

3. **Manual Trigger:**
   - Go to: https://github.com/jvinaymohan/sparktracks-mvp/actions
   - Click "Sync Release Notes to Firestore"
   - Click "Run workflow"
   - ✅ Runs immediately

---

## 🧪 Testing

### Test Manual Sync
```bash
node scripts/sync_release_notes.js
```

**Expected output:**
```
🚀 Starting Release Notes Sync...

✅ Syncing v2.5.3: Navigation & Recurring Tasks Update
✅ Syncing v2.5.0: Critical Privacy & Security Update
✅ Syncing v2.4.1: Major UX Improvements
✅ Syncing v2.4.0: Feature Complete Release

🎉 Successfully synced release notes to Firestore!

📝 Synced versions:
   - v2.5.3 (11/5/2025)
   - v2.5.0 (11/5/2025)
   - v2.4.1 (11/5/2025)
   - v2.4.0 (11/4/2025)

✅ Release notes are now visible in Admin Panel → Releases tab
   URL: https://sparktracks-mvp.web.app/admin/dashboard
```

### Test GitHub Actions
1. Make a small change
2. Commit and push
3. Go to: https://github.com/jvinaymohan/sparktracks-mvp/actions
4. See workflow running
5. Check logs for success

---

## 🛠️ Troubleshooting

### "No Firebase credentials found"
**Solution:** Create serviceAccountKey.json from Firebase Console

### "Permission denied" in Firestore
**Solution:** Check Firestore rules allow admin writes:
```javascript
match /releaseNotes/{noteId} {
  allow read: if request.auth != null;
  allow write: if isAdmin() || request.auth != null;
}
```

### GitHub Actions failing
**Solution:** 
1. Check secret `FIREBASE_SERVICE_ACCOUNT` exists
2. Verify service account has Firestore access
3. Check workflow logs for specific error

### Release notes not appearing in admin panel
**Solution:**
1. Run sync script manually
2. Check Firestore console for data
3. Hard refresh admin panel (Cmd+Shift+R)
4. Check browser console for errors

---

## 📋 Maintenance Checklist

**Monthly:**
- [ ] Review release notes in admin panel
- [ ] Archive old releases (optional)
- [ ] Update RELEASE_NOTES.md
- [ ] Sync to Firestore

**Per Release:**
- [ ] Update sync script with new version
- [ ] Run manual sync
- [ ] Verify in admin panel
- [ ] Update RELEASE_NOTES.md
- [ ] Commit and push (triggers auto-sync if enabled)

---

## 🎯 Best Practices

1. **Version Naming:**
   - Follow semantic versioning: v2.5.3
   - Don't skip versions
   - Use consistent format

2. **Release Dates:**
   - Use UTC timezone
   - Match actual deploy time
   - Be consistent

3. **Features/Fixes:**
   - Be specific, not vague
   - Use past tense ("Added", "Fixed")
   - One item per line
   - User-focused language

4. **Security Updates:**
   - Always document security changes
   - Be transparent but not too detailed
   - Emphasize user benefits

---

## 🚀 Advanced: Auto-Generate from Git Commits

**Future enhancement:** Parse git commits to auto-generate release notes.

**Example script:**
```bash
# Get commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Format into release notes
# Create Firestore document
# Upload automatically
```

**Coming soon!**

---

## ✅ Current Status

**✅ What's Working:**
- Manual sync script
- RELEASE_NOTES.md file
- In-app admin panel
- GitHub workflow file created

**⏰ Next Steps:**
1. Run manual sync right now (5 min)
2. Set up GitHub Actions secret (5 min)
3. Test automation on next commit
4. ✅ Never manually update again!

---

## 🎉 Summary

**Immediate Solution (5 min):**
```bash
npm install firebase-admin
# Get serviceAccountKey.json from Firebase Console
node scripts/sync_release_notes.js
```

**Long-term Solution (15 min):**
1. Add FIREBASE_SERVICE_ACCOUNT secret to GitHub
2. Push any commit
3. Watch it auto-sync!

**Result:**
- ✅ Release notes always in sync
- ✅ Visible in admin panel
- ✅ History preserved
- ✅ Professional tracking

---

**Let's get your release notes working right now!** 🚀


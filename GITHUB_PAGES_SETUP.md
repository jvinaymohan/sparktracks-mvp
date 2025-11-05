# 🌐 GitHub Pages Setup - Live in 2 Minutes!

## ✅ Landing Page Deployed!

Your Sparktracks landing page is being deployed to GitHub Pages!

---

## 🎯 Your URLs

### Current URL (Ready Now!)
**URL:** `https://jvinaymohan.github.io/sparktracks-mvp`

**To Activate:**
1. Go to: https://github.com/jvinaymohan/sparktracks-mvp
2. Click **Settings**
3. Scroll to **Pages** (left sidebar)
4. Under "Branch", select: **gh-pages**
5. Click **Save**
6. Wait 2-3 minutes
7. Your site will be live at: `https://jvinaymohan.github.io/sparktracks-mvp`

---

## 🎯 To Get sparktracks.github.io

To get the URL `sparktracks.github.io`, you have two options:

### Option 1: Create GitHub Organization (Recommended)

**Steps:**
1. Go to https://github.com/organizations/new
2. Organization name: **sparktracks**
3. Create organization (free)
4. Transfer your repo to the organization
5. Repo will be at: `github.com/sparktracks/sparktracks-mvp`
6. Deploy to GitHub Pages
7. Your URL: `https://sparktracks.github.io/sparktracks-mvp`

**OR for root domain:**
8. Create new repo named exactly: **sparktracks.github.io**
9. Push landing page files
10. Auto-deploys to: `https://sparktracks.github.io` ✨

### Option 2: Create New Repo (Simpler)

**For sparktracks.github.io:**
1. Create GitHub account with username: **sparktracks**
2. Create repo named: **sparktracks.github.io**
3. Push landing page files
4. Auto-deploys to: `https://sparktracks.github.io`

---

## 🚀 Quick Deploy Commands

### If You Create Organization:
```bash
# After creating organization and repo
cd /Users/vinayhome/Documents/sparktracks_mvp/web_landing

# Add new remote
git remote add org https://github.com/sparktracks/sparktracks.github.io.git

# Push
git add .
git commit -m "Initial deploy"
git push org main

# Site auto-deploys to: https://sparktracks.github.io
```

### Current Setup (Already Done!):
```bash
# Your landing page is on gh-pages branch
# Will be at: https://jvinaymohan.github.io/sparktracks-mvp
```

---

## 🎨 Custom Domain (Even Better!)

### If You Own a Domain:

**Example: www.sparktracks.com**

1. **In GitHub:**
   - Settings → Pages → Custom domain
   - Enter: `www.sparktracks.com`
   - Save

2. **In Your DNS (GoDaddy, Namecheap, etc.):**
   ```
   Type: CNAME
   Name: www
   Value: jvinaymohan.github.io
   ```

3. **Wait 10-60 minutes**
4. **Your site:** `https://www.sparktracks.com` ✨

**Benefits:**
- Professional domain
- Free hosting (GitHub Pages)
- Auto SSL certificate
- No server costs!

---

## 📊 What's Deployed

### Your Landing Page Includes:
- ✅ Hero section with "Early Access"
- ✅ Instant signup form
- ✅ Login toggle
- ✅ Feature showcase (9 features)
- ✅ User type breakdowns
- ✅ Statistics
- ✅ Responsive design
- ✅ Professional UI

### Forms Redirect To:
- Signup → `/register` (your Flutter app)
- Login → `/login` (your Flutter app)

---

## 🎯 Recommended Setup

**Best Professional Setup:**

1. **Landing Page:** `www.sparktracks.com` (or GitHub Pages)
2. **Main App:** Deploy Flutter web app to Firebase Hosting
3. **Admin Portal:** Included in main app at `/admin/login`

**Alternative Quick Setup:**

1. **Everything on GitHub Pages:**
   - Landing: `jvinaymohan.github.io/sparktracks-mvp`
   - App: Deploy Flutter build to gh-pages
   - Works perfectly!

---

## 🚀 Next Steps

### Right Now (2 minutes):
1. Go to GitHub Settings → Pages
2. Select **gh-pages** branch
3. Save
4. Wait 2 minutes
5. Visit: `https://jvinaymohan.github.io/sparktracks-mvp`
6. **YOUR LANDING PAGE IS LIVE!** 🎉

### Optional (Create sparktracks.github.io):
1. Create organization "sparktracks"
2. Create repo "sparktracks.github.io"
3. Push landing page
4. Auto-live at: `sparktracks.github.io`

### Deploy Main App:
```bash
cd /Users/vinayhome/Documents/sparktracks_mvp
flutter build web --release

# Option 1: GitHub Pages (add to gh-pages branch)
# Option 2: Firebase Hosting
firebase deploy --only hosting

# Option 3: Netlify (after installing Node)
cd build/web
npx netlify-cli deploy --prod
```

---

## 🎊 You're Live!

**In 2 minutes, your landing page will be at:**
`https://jvinaymohan.github.io/sparktracks-mvp`

**To get sparktracks.github.io:**
Create GitHub organization called "sparktracks"

---

**Go to GitHub Settings → Pages and enable it now!** 🚀

Then test your live landing page! 🎉


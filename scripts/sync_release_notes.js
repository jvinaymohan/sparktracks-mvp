#!/usr/bin/env node

/**
 * Sync Release Notes to Firestore
 * 
 * This script:
 * 1. Reads RELEASE_NOTES.md
 * 2. Parses version information
 * 3. Uploads to Firestore
 * 4. Can be run manually or via GitHub Actions
 * 
 * Usage:
 *   node scripts/sync_release_notes.js
 * 
 * Or with service account:
 *   GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json node scripts/sync_release_notes.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
if (!admin.apps.length) {
  try {
    // Try to use service account if available
    const serviceAccount = require('../serviceAccountKey.json');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log('✅ Initialized with service account');
  } catch (e) {
    // Fallback to environment variable
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      admin.initializeApp({
        credential: admin.credential.applicationDefault()
      });
      console.log('✅ Initialized with application default credentials');
    } else {
      console.error('❌ No Firebase credentials found!');
      console.error('   Set GOOGLE_APPLICATION_CREDENTIALS or provide serviceAccountKey.json');
      process.exit(1);
    }
  }
}

const db = admin.firestore();

// Hardcoded release notes (from RELEASE_NOTES.md)
const releaseNotes = [
  {
    version: 'v2.5.3',
    releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-05T04:30:00Z')),
    title: 'Navigation & Recurring Tasks Update',
    description: 'Major UX improvements, recurring tasks, and product management tools',
    features: [
      'Universal navigation with gradient home buttons',
      'Recurring tasks in quick dialog (Daily/Weekly/Monthly)',
      'Custom credentials for child creation',
      'Parent name in dashboard header',
      'Product roadmap Kanban board for admins',
      'Smart delete foundation for recurring tasks',
    ],
    fixes: [
      'CRITICAL: Child task isolation (no cross-child data)',
      'Notification settings navigation',
      'Firestore permission errors resolved',
      'Navigation consistency across all user types',
    ],
    security: [
      'Firestore rules balanced for functionality',
      'Task isolation per child enforced',
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    version: 'v2.5.0',
    releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-05T03:30:00Z')),
    title: 'Critical Privacy & Security Update',
    description: 'Enterprise-grade coach-student privacy and database security',
    features: [
      'Coach-student privacy isolation',
      'Complete feedback system with admin management',
      'Admin panel with 5 tabs',
      'Real-time feedback stream',
    ],
    fixes: [
      'Admin login routing issues',
      'Admin password display mismatch',
      'Feedback save to Firestore',
    ],
    security: [
      'Firestore security rules deployed',
      'Storage security rules created',
      'Coach privacy at database level',
      'Admin Firebase authentication',
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    version: 'v2.4.1',
    releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-05T03:00:00Z')),
    title: 'Major UX Improvements',
    description: '9 critical UX fixes for parent, child, and coach experiences',
    features: [
      'Points slider in multiples of 10',
      'Child name special character validation',
      'Advanced task creator link functional',
    ],
    fixes: [
      'Removed "100% Free Forever" messaging',
      'Fixed welcome screen loops',
      'Complete Profile button working',
      'Skip for Now navigation',
      'No more redirect loops',
    ],
    security: [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    version: 'v2.4.0',
    releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-04T22:00:00Z')),
    title: 'Feature Complete Release',
    description: 'Complete learning management platform with all core features',
    features: [
      'Parent-child task management',
      'Coach class management',
      'Quick task & child creation dialogs',
      'Achievements system',
      'Financial ledger',
      'Class marketplace',
      'Analytics dashboard',
    ],
    fixes: [
      'Data persistence issues',
      'Multi-tenancy filtering',
      'Task approval workflow',
    ],
    security: [
      'Firebase authentication',
      'Role-based access',
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

async function syncReleaseNotes() {
  console.log('\n🚀 Starting Release Notes Sync...\n');

  try {
    const batch = db.batch();
    
    for (const note of releaseNotes) {
      const docRef = db.collection('releaseNotes').doc(note.version);
      batch.set(docRef, note, { merge: true }); // Use merge to update existing
      console.log(`✅ Syncing ${note.version}: ${note.title}`);
    }

    await batch.commit();
    
    console.log('\n🎉 Successfully synced release notes to Firestore!');
    console.log('\n📝 Synced versions:');
    releaseNotes.forEach(note => {
      console.log(`   - ${note.version} (${note.releaseDate.toDate().toLocaleDateString()})`);
    });
    console.log('\n✅ Release notes are now visible in Admin Panel → Releases tab');
    console.log('   URL: https://sparktracks-mvp.web.app/admin/dashboard\n');
    
  } catch (error) {
    console.error('\n❌ Error syncing release notes:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Run the sync
syncReleaseNotes();


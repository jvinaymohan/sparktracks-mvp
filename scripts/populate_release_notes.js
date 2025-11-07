// Populate Release Notes in Firestore
// Run this with: node populate_release_notes.js

const admin = require('firebase-admin');

// Initialize Firebase Admin (use your service account key)
// Download from: Firebase Console → Project Settings → Service Accounts
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function populateReleaseNotes() {
  console.log('🚀 Populating Release Notes...');

  const releaseNotes = [
    {
      version: 'v2.5.3',
      releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-05T04:30:00')),
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
      releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-05T03:30:00')),
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
      releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-05T03:00:00')),
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
      releaseDate: admin.firestore.Timestamp.fromDate(new Date('2025-11-04T22:00:00')),
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

  try {
    const batch = db.batch();
    
    for (const note of releaseNotes) {
      const docRef = db.collection('releaseNotes').doc(note.version);
      batch.set(docRef, note);
      console.log(`✅ Adding ${note.version}`);
    }

    await batch.commit();
    console.log('🎉 Successfully populated release notes!');
    console.log('\n📝 Created 4 release notes:');
    console.log('   - v2.5.3 (Latest)');
    console.log('   - v2.5.0');
    console.log('   - v2.4.1');
    console.log('   - v2.4.0');
    console.log('\n✅ Go refresh your admin panel!');
    
  } catch (error) {
    console.error('❌ Error:', error);
  }

  process.exit(0);
}

populateReleaseNotes();


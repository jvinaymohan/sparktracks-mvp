const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkReleaseNotes() {
  console.log('🔍 Checking Firestore for release notes...\n');
  
  try {
    const snapshot = await db.collection('releaseNotes').get();
    
    console.log(`📊 Found ${snapshot.docs.length} release notes in Firestore\n`);
    
    if (snapshot.docs.length === 0) {
      console.log('❌ No release notes found! Collection is empty.');
    } else {
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        console.log(`✅ ${doc.id}:`);
        console.log(`   Title: ${data.title}`);
        console.log(`   Date: ${data.releaseDate ? data.releaseDate.toDate() : 'N/A'}`);
        console.log(`   Features: ${data.features?.length || 0}`);
        console.log(`   Fixes: ${data.fixes?.length || 0}`);
        console.log('');
      });
    }
  } catch (error) {
    console.error('❌ Error reading Firestore:', error.message);
  }
  
  process.exit(0);
}

checkReleaseNotes();

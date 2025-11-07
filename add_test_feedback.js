// Test feedback data to add to Firestore
// Run this in Firebase Console or use Firebase CLI

const testFeedback = [
  {
    id: 'feedback_test_001',
    userId: 'test_user_001',
    userName: 'Test Parent',
    userEmail: 'testparent@test.com',
    userType: 'parent',
    title: 'Love the new task creation feature!',
    description: 'The quick task creator is so much easier to use than the multi-step wizard. The points slider in multiples of 10 is perfect!',
    category: 'feature',
    rating: 5,
    status: 'pending',
    submittedAt: new Date(),
    metadata: {}
  },
  {
    id: 'feedback_test_002',
    userId: 'test_user_002',
    userName: 'Test Coach',
    userEmail: 'testcoach@test.com',
    userType: 'coach',
    title: 'Student privacy feature is excellent',
    description: 'I can only see my own students now. This is exactly what we needed for privacy. Great work!',
    category: 'feature',
    rating: 5,
    status: 'pending',
    submittedAt: new Date(),
    metadata: {}
  },
  {
    id: 'feedback_test_003',
    userId: 'test_user_003',
    userName: 'Test Child',
    userEmail: 'testchild@test.com',
    userType: 'child',
    title: 'Minor bug with photo upload',
    description: 'Sometimes the photo upload takes a long time to process. Otherwise everything works great!',
    category: 'bug',
    rating: 4,
    status: 'pending',
    submittedAt: new Date(),
    metadata: {}
  },
  {
    id: 'feedback_test_004',
    userId: 'test_user_004',
    userName: 'Beta Tester',
    userEmail: 'betatester@test.com',
    userType: 'parent',
    title: 'Suggestion: Dark mode',
    description: 'Would love to see a dark mode option for nighttime use. The app is beautiful but bright at night.',
    category: 'feature',
    rating: 4,
    status: 'reviewed',
    submittedAt: new Date(Date.now() - 86400000), // Yesterday
    reviewedAt: new Date(),
    reviewedBy: 'admin@sparktracks.com',
    adminNotes: 'Great suggestion! Added to roadmap for v3.0',
    metadata: {}
  },
  {
    id: 'feedback_test_005',
    userId: 'test_user_005',
    userName: 'Happy Parent',
    userEmail: 'happyparent@test.com',
    userType: 'parent',
    title: 'This platform is amazing!',
    description: 'My kids are actually excited to complete tasks now. The achievement system is brilliant. Thank you for building this!',
    category: 'general',
    rating: 5,
    status: 'resolved',
    submittedAt: new Date(Date.now() - 172800000), // 2 days ago
    reviewedAt: new Date(Date.now() - 86400000),
    reviewedBy: 'admin@sparktracks.com',
    adminNotes: 'Wonderful feedback! Shared with the team.',
    metadata: {}
  }
];

console.log('Test feedback data ready!');
console.log('Add these to Firestore "feedback" collection');


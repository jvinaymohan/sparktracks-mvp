import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/task_model.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../models/coach_profile_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ============ USERS ============
  
  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }
  
  Future<User?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return User.fromJson(doc.data()!);
  }
  
  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }
  
  // ============ CHILDREN ============
  
  Future<void> addChild(Student child) async {
    await _firestore.collection('children').doc(child.id).set(child.toJson());
  }
  
  Future<List<Student>> getChildren(String parentId) async {
    final snapshot = await _firestore
        .collection('children')
        .where('parentId', isEqualTo: parentId)
        .get();
    
    return snapshot.docs
        .map((doc) => Student.fromJson(doc.data()))
        .toList();
  }
  
  Future<void> updateChild(Student child) async {
    await _firestore.collection('children').doc(child.id).update(child.toJson());
  }
  
  Future<void> deleteChild(String childId) async {
    await _firestore.collection('children').doc(childId).delete();
  }
  
  Stream<List<Student>> watchChildren(String parentId) {
    return _firestore
        .collection('children')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromJson(doc.data()))
            .toList());
  }
  
  // ============ TASKS ============
  
  Future<List<Task>> getTasksForParent(String parentId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('parentId', isEqualTo: parentId)
        .get();
    
    return snapshot.docs
        .map((doc) => Task.fromJson(doc.data()))
        .toList();
  }
  
  Future<List<Task>> getTasksForChild(String childId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('childId', isEqualTo: childId)
        .get();
    
    return snapshot.docs
        .map((doc) => Task.fromJson(doc.data()))
        .toList();
  }
  
  Future<void> addTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).set(task.toJson());
  }
  
  Future<List<Task>> getTasks(String userId, {UserType? userType}) async {
    Query query = _firestore.collection('tasks');
    
    if (userType == UserType.parent) {
      query = query.where('parentId', isEqualTo: userId);
    } else if (userType == UserType.child) {
      query = query.where('childId', isEqualTo: userId);
    } else if (userType == UserType.coach) {
      query = query.where('coachId', isEqualTo: userId);
    }
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
  
  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toJson());
  }
  
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
  
  Stream<List<Task>> watchTasks(String userId, {UserType? userType}) {
    Query query = _firestore.collection('tasks');
    
    if (userType == UserType.parent) {
      query = query.where('parentId', isEqualTo: userId);
    } else if (userType == UserType.child) {
      query = query.where('childId', isEqualTo: userId);
    } else if (userType == UserType.coach) {
      query = query.where('coachId', isEqualTo: userId);
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }
  
  // ============ CLASSES ============
  
  Future<void> addClass(Class classItem) async {
    await _firestore.collection('classes').doc(classItem.id).set(classItem.toJson());
  }
  
  Future<List<Class>> getClasses(String userId, {UserType? userType}) async {
    Query query = _firestore.collection('classes');
    
    if (userType == UserType.coach) {
      query = query.where('coachId', isEqualTo: userId);
    }
    // For parent/child, we'd need to check enrolled students - implement as needed
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Class.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
  
  Future<void> updateClass(Class classItem) async {
    await _firestore.collection('classes').doc(classItem.id).update(classItem.toJson());
  }
  
  Future<void> deleteClass(String classId) async {
    await _firestore.collection('classes').doc(classId).delete();
  }
  
  Stream<List<Class>> watchClasses(String userId, {UserType? userType}) {
    Query query = _firestore.collection('classes');
    
    if (userType == UserType.coach) {
      query = query.where('coachId', isEqualTo: userId);
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Class.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }
  
  // ============ COACH PROFILES (v3.0) ============
  
  Future<void> saveCoachProfile(CoachProfile profile) async {
    await _firestore.collection('coachProfiles').doc(profile.id).set(profile.toJson());
  }
  
  /// Get coach profile by ID or slug (friendly URL name)
  /// Tries slug lookup first, then falls back to ID lookup
  Future<CoachProfile?> getCoachProfile(String coachIdOrSlug) async {
    // First, try direct ID lookup (faster)
    final directDoc = await _firestore.collection('coachProfiles').doc(coachIdOrSlug).get();
    if (directDoc.exists) {
      return CoachProfile.fromJson(directDoc.data()!);
    }
    
    // If not found, try slug-based lookup
    final querySnapshot = await _firestore
        .collection('coachProfiles')
        .where('preferences.profileSlug', isEqualTo: coachIdOrSlug)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      return CoachProfile.fromJson(querySnapshot.docs.first.data());
    }
    
    return null;
  }
  
  Future<void> updateCoachProfile(CoachProfile profile) async {
    await _firestore.collection('coachProfiles').doc(profile.id).update(profile.toJson());
  }
  
  Future<List<CoachProfile>> getAllCoachProfiles() async {
    final snapshot = await _firestore
        .collection('coachProfiles')
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => CoachProfile.fromJson(doc.data())).toList();
  }
  
  Future<List<CoachProfile>> searchCoaches({
    String? city,
    String? specialization,
    List<String>? categories,
  }) async {
    Query query = _firestore.collection('coachProfiles').where('isActive', isEqualTo: true);
    
    if (city != null) {
      query = query.where('location.city', isEqualTo: city);
    }
    
    if (categories != null && categories.isNotEmpty) {
      query = query.where('categories', arrayContainsAny: categories);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => CoachProfile.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  // ============ REVIEWS ============
  
  /// Add a new review for a coach
  Future<void> addReview(Review review) async {
    await _firestore.collection('reviews').doc(review.id).set(review.toJson());
  }
  
  /// Get all reviews for a specific coach
  Future<List<Review>> getCoachReviews(String coachId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('coachId', isEqualTo: coachId)
        .where('isFlagged', isEqualTo: false) // Only show non-flagged reviews
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => Review.fromJson(doc.data()))
        .toList();
  }
  
  /// Get reviews by a specific parent
  Future<List<Review>> getParentReviews(String parentId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => Review.fromJson(doc.data()))
        .toList();
  }
  
  /// Check if a parent has already reviewed a coach
  Future<bool> hasParentReviewedCoach(String parentId, String coachId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('parentId', isEqualTo: parentId)
        .where('coachId', isEqualTo: coachId)
        .limit(1)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }
  
  /// Get a parent's review for a specific coach
  Future<Review?> getParentReviewForCoach(String parentId, String coachId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('parentId', isEqualTo: parentId)
        .where('coachId', isEqualTo: coachId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return Review.fromJson(snapshot.docs.first.data());
  }
  
  /// Update an existing review
  Future<void> updateReview(Review review) async {
    await _firestore.collection('reviews').doc(review.id).update(review.toJson());
  }
  
  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }
  
  /// Flag a review for moderation
  Future<void> flagReview(String reviewId, String reason) async {
    await _firestore.collection('reviews').doc(reviewId).update({
      'isFlagged': true,
      'flagReason': reason,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
  
  /// Calculate rating statistics for a coach
  Future<CoachRatingStats> getCoachRatingStats(String coachId) async {
    final reviews = await getCoachReviews(coachId);
    return CoachRatingStats.fromReviews(coachId, reviews);
  }
  
  /// Stream reviews for a coach (real-time updates)
  Stream<List<Review>> watchCoachReviews(String coachId) {
    return _firestore
        .collection('reviews')
        .where('coachId', isEqualTo: coachId)
        .where('isFlagged', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromJson(doc.data()))
            .toList());
  }
  
  /// Get recent reviews across all coaches (for admin)
  Future<List<Review>> getAllRecentReviews({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => Review.fromJson(doc.data()))
        .toList();
  }
  
  /// Get flagged reviews (for moderation)
  Future<List<Review>> getFlaggedReviews() async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('isFlagged', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => Review.fromJson(doc.data()))
        .toList();
  }

  // ============ GENERIC HELPERS ============
  
  /// Add a document to any collection (generic helper)
  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    final docRef = await _firestore.collection(collection).add(data);
    return docRef.id;
  }
  
  /// Update a document in any collection
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }
  
  /// Delete a document from any collection
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }
  
  /// Get a document from any collection
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}


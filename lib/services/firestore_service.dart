import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/task_model.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../models/coach_profile_model.dart';

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
  
  Future<CoachProfile?> getCoachProfile(String coachId) async {
    final doc = await _firestore.collection('coachProfiles').doc(coachId).get();
    if (!doc.exists) return null;
    return CoachProfile.fromJson(doc.data()!);
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
}


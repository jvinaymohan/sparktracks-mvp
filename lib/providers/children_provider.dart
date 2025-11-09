import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

class ChildrenProvider extends ChangeNotifier {
  final List<Student> _children = [];
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  List<Student> get children => _children;
  bool get isLoading => _isLoading;
  
  // Load children from Firebase for a parent
  Future<void> loadChildren(String parentId) async {
    try {
      print('👶 Loading children for parent: $parentId');
      _isLoading = true;
      notifyListeners();
      
      final loadedChildren = await _firestoreService.getChildren(parentId);
      _children.clear();
      _children.addAll(loadedChildren);
      
      print('✅ Loaded ${loadedChildren.length} children for parent $parentId');
      
      // Log each child for debugging
      for (final child in loadedChildren) {
        print('   👶 Child: ${child.name} (ID: ${child.id}, ParentID: ${child.parentId})');
      }
      
      if (loadedChildren.isEmpty) {
        print('⚠️ WARNING: No children found for parent $parentId');
        print('   Check Firestore children collection for parentId field!');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading children: $e');
      print('📍 Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get children for specific parent (from memory)
  List<Student> getChildrenForParent(String parentId) {
    return _children.where((child) => child.parentId == parentId).toList();
  }
  
  /// Get students visible to a specific coach (PRIVACY FILTER)
  /// Returns only students that:
  /// 1. Were created by this coach (createdByCoachId == coachId)
  /// 2. OR are enrolled in this coach's classes
  List<Student> getStudentsVisibleToCoach(String coachId, List<String> enrolledStudentIds) {
    return _children.where((student) {
      // Student was created by this coach
      if (student.createdByCoachId == coachId) {
        return true;
      }
      // Student is enrolled in one of this coach's classes
      if (enrolledStudentIds.contains(student.userId)) {
        return true;
      }
      return false;
    }).toList();
  }
  
  // Clear all children (for testing/reset purposes)
  void clearAllChildren() {
    _children.clear();
    notifyListeners();
  }

  Future<void> addChild(Student child) async {
    try {
      // Save to Firebase first
      await _firestoreService.addChild(child);
      
      // Then add to local list
      _children.add(child);
      notifyListeners();
      
      print('✓ Child added to Firebase and local state');
    } catch (e) {
      print('Error adding child: $e');
      throw e;
    }
  }

  Future<void> updateChild(Student updatedChild) async {
    try {
      // Update in Firebase first
      await _firestoreService.updateChild(updatedChild);
      
      // Then update local
      final index = _children.indexWhere((child) => child.id == updatedChild.id);
      if (index != -1) {
        _children[index] = updatedChild;
        notifyListeners();
      }
      
      print('✓ Child updated in Firebase and local state');
    } catch (e) {
      print('Error updating child: $e');
      throw e;
    }
  }

  Future<void> deleteChild(String childId) async {
    try {
      // Delete from Firebase first
      await _firestoreService.deleteChild(childId);
      
      // Then remove from local
      _children.removeWhere((child) => child.id == childId);
      notifyListeners();
      
      print('✓ Child deleted from Firebase and local state');
    } catch (e) {
      print('Error deleting child: $e');
      throw e;
    }
  }

  Student? getChildById(String id) {
    try {
      return _children.firstWhere((child) => child.id == id);
    } catch (e) {
      return null;
    }
  }
}


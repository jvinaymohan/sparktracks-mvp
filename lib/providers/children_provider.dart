import 'package:flutter/material.dart';
import '../models/student_model.dart';

class ChildrenProvider extends ChangeNotifier {
  final List<Student> _children = [];

  List<Student> get children => _children;
  
  // Get children for specific parent
  List<Student> getChildrenForParent(String parentId) {
    return _children.where((child) => child.parentId == parentId).toList();
  }
  
  // Clear all children (for testing/reset purposes)
  void clearAllChildren() {
    _children.clear();
    notifyListeners();
  }

  void addChild(Student child) {
    _children.add(child);
    notifyListeners();
  }

  void updateChild(Student updatedChild) {
    final index = _children.indexWhere((child) => child.id == updatedChild.id);
    if (index != -1) {
      _children[index] = updatedChild;
      notifyListeners();
    }
  }

  void deleteChild(String childId) {
    _children.removeWhere((child) => child.id == childId);
    notifyListeners();
  }

  Student? getChildById(String id) {
    try {
      return _children.firstWhere((child) => child.id == id);
    } catch (e) {
      return null;
    }
  }
}


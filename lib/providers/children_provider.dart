import 'package:flutter/material.dart';
import '../models/student_model.dart';

class ChildrenProvider extends ChangeNotifier {
  List<Student> _children = [
    // Default mock children
    Student(
      id: '1',
      userId: 'child1',
      parentId: 'parent1',
      name: 'Emma Johnson',
      email: 'emma@example.com',
      dateOfBirth: DateTime(2015, 3, 15),
      enrolledAt: DateTime.now().subtract(const Duration(days: 30)),
      colorCode: '#FF6B6B',
    ),
    Student(
      id: '2',
      userId: 'child2',
      parentId: 'parent1',
      name: 'Liam Johnson',
      email: 'liam@example.com',
      dateOfBirth: DateTime(2013, 7, 22),
      enrolledAt: DateTime.now().subtract(const Duration(days: 45)),
      colorCode: '#4ECDC4',
    ),
  ];

  List<Student> get children => _children;

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


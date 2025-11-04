import 'package:flutter/material.dart';
import '../models/class_model.dart';

class ClassesProvider with ChangeNotifier {
  final List<Class> _classes = [];

  List<Class> get classes => _classes;
  
  // Get classes for a specific coach
  List<Class> getClassesForCoach(String coachId) {
    return _classes.where((cls) => cls.coachId == coachId).toList();
  }
  
  // Get public classes (for browsing)
  List<Class> getPublicClasses() {
    return _classes.where((cls) => cls.isPublic == true).toList();
  }
  
  // Get classes a child is enrolled in
  List<Class> getClassesForStudent(String studentId) {
    return _classes.where((cls) => cls.enrolledStudentIds.contains(studentId)).toList();
  }
  
  // Clear all classes (for testing)
  void clearAllClasses() {
    _classes.clear();
    notifyListeners();
  }

  void addClass(Class classItem) {
    _classes.add(classItem);
    notifyListeners();
  }

  void updateClass(Class updatedClass) {
    final index = _classes.indexWhere((cls) => cls.id == updatedClass.id);
    if (index != -1) {
      _classes[index] = updatedClass;
      notifyListeners();
    }
  }

  void deleteClass(String classId) {
    _classes.removeWhere((cls) => cls.id == classId);
    notifyListeners();
  }

  Class? getClassById(String id) {
    try {
      return _classes.firstWhere((cls) => cls.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Enroll a student in a class
  void enrollStudent(String classId, String studentId) {
    final index = _classes.indexWhere((cls) => cls.id == classId);
    if (index != -1) {
      if (!_classes[index].enrolledStudentIds.contains(studentId)) {
        final updatedIds = [..._classes[index].enrolledStudentIds, studentId];
        _classes[index] = Class(
          id: _classes[index].id,
          title: _classes[index].title,
          description: _classes[index].description,
          coachId: _classes[index].coachId,
          type: _classes[index].type,
          locationType: _classes[index].locationType,
          location: _classes[index].location,
          startTime: _classes[index].startTime,
          endTime: _classes[index].endTime,
          durationMinutes: _classes[index].durationMinutes,
          price: _classes[index].price,
          currency: _classes[index].currency,
          maxStudents: _classes[index].maxStudents,
          enrolledStudentIds: updatedIds,
          createdAt: _classes[index].createdAt,
          updatedAt: DateTime.now(),
          isPublic: _classes[index].isPublic,
          isGroupClass: _classes[index].isGroupClass,
          paymentSchedule: _classes[index].paymentSchedule,
          makeUpClassesAllowed: _classes[index].makeUpClassesAllowed,
          shareableLink: _classes[index].shareableLink,
        );
        notifyListeners();
      }
    }
  }
  
  // Unenroll a student from a class
  void unenrollStudent(String classId, String studentId) {
    final index = _classes.indexWhere((cls) => cls.id == classId);
    if (index != -1) {
      final updatedIds = _classes[index].enrolledStudentIds.where((id) => id != studentId).toList();
      _classes[index] = Class(
        id: _classes[index].id,
        title: _classes[index].title,
        description: _classes[index].description,
        coachId: _classes[index].coachId,
        type: _classes[index].type,
        locationType: _classes[index].locationType,
        location: _classes[index].location,
        startTime: _classes[index].startTime,
        endTime: _classes[index].endTime,
        durationMinutes: _classes[index].durationMinutes,
        price: _classes[index].price,
        currency: _classes[index].currency,
        maxStudents: _classes[index].maxStudents,
        enrolledStudentIds: updatedIds,
        createdAt: _classes[index].createdAt,
        updatedAt: DateTime.now(),
        isPublic: _classes[index].isPublic,
        isGroupClass: _classes[index].isGroupClass,
        paymentSchedule: _classes[index].paymentSchedule,
        makeUpClassesAllowed: _classes[index].makeUpClassesAllowed,
        shareableLink: _classes[index].shareableLink,
      );
      notifyListeners();
    }
  }
}


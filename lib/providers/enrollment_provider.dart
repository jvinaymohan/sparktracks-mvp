import 'package:flutter/material.dart';
import '../models/enrollment_model.dart';

class EnrollmentProvider with ChangeNotifier {
  final List<Enrollment> _enrollments = [];

  List<Enrollment> get enrollments => _enrollments;
  
  // Get enrollments for a specific parent
  List<Enrollment> getEnrollmentsForParent(String parentId) {
    return _enrollments.where((e) => e.parentId == parentId).toList();
  }
  
  // Get enrollments for a specific class
  List<Enrollment> getEnrollmentsForClass(String classId) {
    return _enrollments.where((e) => e.classId == classId).toList();
  }
  
  // Get enrollments for a specific student
  List<Enrollment> getEnrollmentsForStudent(String studentId) {
    return _enrollments.where((e) => e.studentId == studentId).toList();
  }
  
  // Check if student is enrolled in class
  bool isEnrolled(String studentId, String classId) {
    return _enrollments.any((e) => 
      e.studentId == studentId && 
      e.classId == classId && 
      e.status == EnrollmentStatus.active
    );
  }
  
  // Add enrollment
  void addEnrollment(Enrollment enrollment) {
    _enrollments.add(enrollment);
    notifyListeners();
  }

  // Update enrollment
  void updateEnrollment(Enrollment updatedEnrollment) {
    final index = _enrollments.indexWhere((e) => e.id == updatedEnrollment.id);
    if (index != -1) {
      _enrollments[index] = updatedEnrollment;
      notifyListeners();
    }
  }

  // Cancel enrollment
  void cancelEnrollment(String enrollmentId, String reason) {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index != -1) {
      _enrollments[index] = _enrollments[index].copyWith(
        status: EnrollmentStatus.cancelled,
        cancelledAt: DateTime.now(),
        cancellationReason: reason,
      );
      notifyListeners();
    }
  }
  
  // Record attendance
  void recordAttendance(String enrollmentId, bool present) {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index != -1) {
      _enrollments[index] = _enrollments[index].copyWith(
        attendanceCount: present 
            ? _enrollments[index].attendanceCount + 1 
            : _enrollments[index].attendanceCount,
        absenceCount: !present 
            ? _enrollments[index].absenceCount + 1 
            : _enrollments[index].absenceCount,
      );
      notifyListeners();
    }
  }
  
  // Record payment
  void recordPayment(String enrollmentId, double amount) {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index != -1) {
      final current = _enrollments[index];
      _enrollments[index] = current.copyWith(
        amountPaid: current.amountPaid + amount,
        amountDue: current.amountDue > amount ? current.amountDue - amount : 0,
        lastPaymentDate: DateTime.now(),
      );
      notifyListeners();
    }
  }
}


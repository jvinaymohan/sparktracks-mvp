import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class AttendanceProvider with ChangeNotifier {
  final List<Attendance> _attendanceRecords = [];

  List<Attendance> get attendanceRecords => _attendanceRecords;
  
  // Get attendance for a specific class
  List<Attendance> getAttendanceForClass(String classId) {
    return _attendanceRecords.where((a) => a.classId == classId).toList();
  }
  
  // Get attendance for a specific student
  List<Attendance> getAttendanceForStudent(String studentId) {
    return _attendanceRecords.where((a) => a.studentId == studentId).toList();
  }
  
  // Get attendance for a specific date
  List<Attendance> getAttendanceForDate(String classId, DateTime date) {
    return _attendanceRecords.where((a) => 
      a.classId == classId &&
      a.classDate.year == date.year &&
      a.classDate.month == date.month &&
      a.classDate.day == date.day
    ).toList();
  }
  
  // Mark attendance
  void markAttendance(Attendance attendance) {
    // Check if already marked
    final existing = _attendanceRecords.where((a) =>
      a.classId == attendance.classId &&
      a.studentId == attendance.studentId &&
      a.classDate.year == attendance.classDate.year &&
      a.classDate.month == attendance.classDate.month &&
      a.classDate.day == attendance.classDate.day
    ).toList();
    
    if (existing.isNotEmpty) {
      // Update existing
      final index = _attendanceRecords.indexOf(existing.first);
      _attendanceRecords[index] = attendance;
    } else {
      // Add new
      _attendanceRecords.add(attendance);
    }
    notifyListeners();
  }
  
  // Bulk mark attendance
  void markBulkAttendance(List<Attendance> records) {
    for (var record in records) {
      markAttendance(record);
    }
  }
  
  // Get attendance statistics for a student
  Map<String, int> getAttendanceStats(String studentId) {
    final records = getAttendanceForStudent(studentId);
    return {
      'total': records.length,
      'present': records.where((a) => a.status == AttendanceStatus.present).length,
      'absent': records.where((a) => a.status == AttendanceStatus.absent).length,
      'late': records.where((a) => a.status == AttendanceStatus.late).length,
      'excused': records.where((a) => a.status == AttendanceStatus.excused).length,
    };
  }
}


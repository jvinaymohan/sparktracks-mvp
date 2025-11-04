import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/classes_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/class_model.dart';
import '../../models/attendance_model.dart';
import '../../models/student_model.dart';
import '../../models/enrollment_model.dart';
import '../../utils/app_theme.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final Class classItem;
  final DateTime? date;
  
  const MarkAttendanceScreen({
    super.key,
    required this.classItem,
    this.date,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  late DateTime _selectedDate;
  final Map<String, AttendanceStatus> _attendanceMap = {};
  final Map<String, TextEditingController> _notesControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date ?? DateTime.now();
    _loadExistingAttendance();
  }

  void _loadExistingAttendance() {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final existingRecords = attendanceProvider.getAttendanceForDate(widget.classItem.id, _selectedDate);
    
    for (var record in existingRecords) {
      _attendanceMap[record.studentId] = record.status;
      if (record.notes != null) {
        _notesControllers[record.studentId] = TextEditingController(text: record.notes);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context);
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    
    // Get enrolled students for this class
    final enrollments = enrollmentProvider.getEnrollmentsForClass(widget.classItem.id)
        .where((e) => e.status == EnrollmentStatus.active)
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save All',
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Class info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingL),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.classItem.title,
                  style: AppTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppTheme.neutral600),
                    const SizedBox(width: 4),
                    Text(
                      '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 16, color: AppTheme.neutral600),
                    const SizedBox(width: 4),
                    Text(
                      '${enrollments.length} students',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Quick actions
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _markAllAs(AttendanceStatus.present, enrollments),
                    child: const Text('Mark All Present'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _markAllAs(AttendanceStatus.absent, enrollments),
                    child: const Text('Mark All Absent'),
                  ),
                ),
              ],
            ),
          ),
          
          // Student list
          Expanded(
            child: enrollments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: AppTheme.neutral400),
                        const SizedBox(height: AppTheme.spacingL),
                        Text('No students enrolled yet', style: AppTheme.headline6),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    itemCount: enrollments.length,
                    itemBuilder: (context, index) {
                      final enrollment = enrollments[index];
                      final student = childrenProvider.children.firstWhere(
                        (s) => s.userId == enrollment.studentId,
                        orElse: () => Student(
                          id: enrollment.studentId,
                          userId: enrollment.studentId,
                          parentId: enrollment.parentId,
                          name: 'Unknown Student',
                          email: '',
                          dateOfBirth: DateTime.now(),
                          enrolledAt: DateTime.now(),
                        ),
                      );
                      
                      return _buildStudentAttendanceCard(student, enrollment);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceCard(Student student, Enrollment enrollment) {
    final status = _attendanceMap[student.userId] ?? AttendanceStatus.unmarked;
    final notesController = _notesControllers.putIfAbsent(
      student.userId,
      () => TextEditingController(),
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Text(
            student.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.name),
        subtitle: Row(
          children: [
            Icon(_getStatusIcon(status), size: 14, color: _getStatusColor(status)),
            const SizedBox(width: 4),
            Text(status.toString().split('.').last.toUpperCase()),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attendance buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAttendanceButton(
                      'Present',
                      AttendanceStatus.present,
                      Icons.check_circle,
                      Colors.green,
                      student.userId,
                    ),
                    _buildAttendanceButton(
                      'Absent',
                      AttendanceStatus.absent,
                      Icons.cancel,
                      Colors.red,
                      student.userId,
                    ),
                    _buildAttendanceButton(
                      'Late',
                      AttendanceStatus.late,
                      Icons.schedule,
                      Colors.orange,
                      student.userId,
                    ),
                    _buildAttendanceButton(
                      'Excused',
                      AttendanceStatus.excused,
                      Icons.info,
                      Colors.blue,
                      student.userId,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingM),
                
                // Notes
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add notes about attendance...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton(
    String label,
    AttendanceStatus status,
    IconData icon,
    Color color,
    String studentId,
  ) {
    final isSelected = _attendanceMap[studentId] == status;
    
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        setState(() {
          _attendanceMap[studentId] = status;
        });
      },
    );
  }

  void _markAllAs(AttendanceStatus status, List enrollments) {
    setState(() {
      for (var enrollment in enrollments) {
        _attendanceMap[enrollment.studentId] = status;
      }
    });
  }

  void _saveAttendance() {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context, listen: false);
    
    final coachId = authProvider.currentUser?.id ?? '';
    final records = <Attendance>[];
    
    _attendanceMap.forEach((studentId, status) {
      final notes = _notesControllers[studentId]?.text;
      
      final attendance = Attendance(
        id: 'att_${widget.classItem.id}_${studentId}_${_selectedDate.millisecondsSinceEpoch}',
        classId: widget.classItem.id,
        studentId: studentId,
        classDate: _selectedDate,
        status: status,
        markedAt: DateTime.now(),
        markedBy: coachId,
        notes: notes?.isNotEmpty == true ? notes : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      records.add(attendance);
      
      // Update enrollment attendance count
      final enrollments = enrollmentProvider.getEnrollmentsForStudent(studentId);
      for (var enrollment in enrollments) {
        if (enrollment.classId == widget.classItem.id) {
          enrollmentProvider.recordAttendance(enrollment.id, status == AttendanceStatus.present);
        }
      }
    });
    
    attendanceProvider.markBulkAttendance(records);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Attendance saved for ${records.length} students'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
      case AttendanceStatus.unmarked:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.schedule;
      case AttendanceStatus.excused:
        return Icons.info;
      case AttendanceStatus.unmarked:
        return Icons.help_outline;
    }
  }
}


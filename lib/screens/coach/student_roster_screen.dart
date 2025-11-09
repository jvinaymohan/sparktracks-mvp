import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/student_model.dart';
import '../../models/enrollment_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'package:go_router/go_router.dart';

/// Screen showing all students enrolled in coach's classes
class StudentRosterScreen extends StatefulWidget {
  const StudentRosterScreen({super.key});

  @override
  State<StudentRosterScreen> createState() => _StudentRosterScreenState();
}

class _StudentRosterScreenState extends State<StudentRosterScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coachId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Student',
            onPressed: () {
              // TODO: Navigate to add student wizard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add student feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getStudentsWithDetails(coachId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final students = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.0,
            ),
            itemCount: students.length,
            itemBuilder: (context, index) => _buildStudentTile(students[index]),
          );
        },
      ),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> studentData) {
    final studentName = studentData['name'] as String;
    final studentId = studentData['id'] as String;
    final enrollmentCount = studentData['enrollmentCount'] as int;
    final totalDue = studentData['totalDue'] as double;
    final parentName = studentData['parentName'] as String;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showStudentDetails(studentData),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  studentName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Name
              Text(
                studentName,
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Parent
              Text(
                'Parent: $parentName',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        enrollmentCount.toString(),
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text('Classes', style: AppTheme.bodySmall),
                    ],
                  ),
                  Container(width: 1, height: 30, color: AppTheme.neutral300),
                  Column(
                    children: [
                      Text(
                        '\$${totalDue.toStringAsFixed(0)}',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: totalDue > 0 ? AppTheme.warningColor : AppTheme.successColor,
                        ),
                      ),
                      Text('Due', style: AppTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getStudentsWithDetails(String coachId) async {
    // Get all classes for this coach
    final classesSnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .where('coachId', isEqualTo: coachId)
        .get();

    final classIds = classesSnapshot.docs.map((doc) => doc.id).toList();

    if (classIds.isEmpty) return [];

    // Get all active enrollments for these classes
    final enrollmentsSnapshot = await FirebaseFirestore.instance
        .collection('enrollments')
        .where('classId', whereIn: classIds)
        .where('status', isEqualTo: 'active')
        .get();

    // Group by student
    final studentMap = <String, Map<String, dynamic>>{};

    for (final enrollDoc in enrollmentsSnapshot.docs) {
      final enrollment = Enrollment.fromJson(enrollDoc.data());
      
      if (!studentMap.containsKey(enrollment.studentId)) {
        // Get student details
        final studentDoc = await FirebaseFirestore.instance
            .collection('children')
            .doc(enrollment.studentId)
            .get();

        if (!studentDoc.exists) continue;

        final studentData = studentDoc.data()!;
        
        // Get parent details
        final parentDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(enrollment.parentId)
            .get();

        studentMap[enrollment.studentId] = {
          'id': enrollment.studentId,
          'name': studentData['name'] ?? 'Student',
          'parentId': enrollment.parentId,
          'parentName': parentDoc.data()?['name'] ?? 'Parent',
          'parentEmail': parentDoc.data()?['email'] ?? '',
          'enrollments': <Enrollment>[],
          'enrollmentCount': 0,
          'totalDue': 0.0,
        };
      }

      // Add enrollment to student
      studentMap[enrollment.studentId]!['enrollments'].add(enrollment);
      studentMap[enrollment.studentId]!['enrollmentCount'] = 
          (studentMap[enrollment.studentId]!['enrollmentCount'] as int) + 1;
      studentMap[enrollment.studentId]!['totalDue'] = 
          (studentMap[enrollment.studentId]!['totalDue'] as double) + enrollment.amountDue;
    }

    return studentMap.values.toList();
  }

  void _showStudentDetails(Map<String, dynamic> studentData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          (studentData['name'] as String)[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentData['name'] as String,
                              style: AppTheme.headline6,
                            ),
                            Text(
                              'Parent: ${studentData['parentName']}',
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                            ),
                            Text(
                              studentData['parentEmail'] as String,
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Enrolled Classes',
                              (studentData['enrollmentCount'] as int).toString(),
                              Icons.class_,
                              AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Amount Due',
                              '\$${(studentData['totalDue'] as double).toStringAsFixed(2)}',
                              Icons.attach_money,
                              AppTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Enrolled Classes
                      Text('Enrolled Classes', style: AppTheme.headline6),
                      const SizedBox(height: 12),
                      ...((studentData['enrollments'] as List<Enrollment>).map((enrollment) {
                        return FutureBuilder<String>(
                          future: _getClassName(enrollment.classId),
                          builder: (context, snapshot) {
                            final className = snapshot.data ?? 'Loading...';
                            return Card(
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.school, color: AppTheme.successColor),
                                ),
                                title: Text(className),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Enrolled: ${DateFormat('MMM d, y').format(enrollment.enrolledAt)}'),
                                    if (enrollment.amountDue > 0)
                                      Text(
                                        'Due: \$${enrollment.amountDue.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppTheme.warningColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'attendance',
                                      child: ListTile(
                                        leading: Icon(Icons.check_circle_outline),
                                        title: Text('Mark Attendance'),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'payment',
                                      child: ListTile(
                                        leading: Icon(Icons.payment),
                                        title: Text('Record Payment'),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: ListTile(
                                        leading: Icon(Icons.remove_circle_outline),
                                        title: Text('Remove from Class'),
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'remove') {
                                      _removeStudentFromClass(enrollment);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      })),
                      
                      const SizedBox(height: 24),
                      
                      // Actions
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Send message to parent
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Messaging feature coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Message Parent'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headline5.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<String> _getClassName(String classId) async {
    final doc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .get();
    return doc.data()?['title'] ?? 'Class';
  }

  Future<void> _removeStudentFromClass(Enrollment enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student?'),
        content: const Text(
          'This will remove the student from the class. '
          'The parent will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('enrollments')
          .doc(enrollment.id)
          .update({'status': 'cancelled'});

      // Remove from class enrolledStudentIds
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(enrollment.classId)
          .update({
        'enrolledStudentIds': FieldValue.arrayRemove([enrollment.studentId]),
      });

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        setState(() {}); // Refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student removed from class'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppTheme.neutral400),
          const SizedBox(height: 24),
          Text('No Students Yet', style: AppTheme.headline5),
          const SizedBox(height: 12),
          Text(
            'Students will appear here once they enroll in your classes',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/coach/class-wizard'),
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}


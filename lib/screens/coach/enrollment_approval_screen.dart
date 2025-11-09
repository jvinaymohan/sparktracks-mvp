import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/enrollment_model.dart';
import '../../models/class_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

/// Screen for coaches to review and approve class enrollments
class EnrollmentApprovalScreen extends StatefulWidget {
  const EnrollmentApprovalScreen({super.key});

  @override
  State<EnrollmentApprovalScreen> createState() => _EnrollmentApprovalScreenState();
}

class _EnrollmentApprovalScreenState extends State<EnrollmentApprovalScreen> {
  String _filter = 'pending'; // pending, approved, all

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coachId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment Requests'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('Pending', 'pending'),
                _buildFilterChip('Approved', 'approved'),
                _buildFilterChip('All', 'all'),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getEnrollmentsStream(coachId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final enrollments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: enrollments.length,
            itemBuilder: (context, index) {
              final enrollment = Enrollment.fromJson(
                enrollments[index].data() as Map<String, dynamic>,
              );
              return _buildEnrollmentCard(enrollment);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _filter = value);
          }
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Stream<QuerySnapshot> _getEnrollmentsStream(String coachId) async* {
    // Get all classes for this coach
    final classesSnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .where('coachId', isEqualTo: coachId)
        .get();

    final classIds = classesSnapshot.docs.map((doc) => doc.id).toList();

    if (classIds.isEmpty) {
      yield* const Stream.empty();
      return;
    }

    // Get enrollments for these classes
    var query = FirebaseFirestore.instance
        .collection('enrollments')
        .where('classId', whereIn: classIds);

    if (_filter == 'pending') {
      query = query.where('status', isEqualTo: 'pending');
    } else if (_filter == 'approved') {
      query = query.where('status', isEqualTo: 'active');
    }

    yield* query.orderBy('enrolledAt', descending: true).snapshots();
  }

  Widget _buildEnrollmentCard(Enrollment enrollment) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getEnrollmentDetails(enrollment),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final details = snapshot.data!;
        final studentName = details['studentName'] as String;
        final parentName = details['parentName'] as String;
        final parentEmail = details['parentEmail'] as String;
        final className = details['className'] as String;

        final isPending = enrollment.status == EnrollmentStatus.pending;
        final statusColor = isPending ? AppTheme.warningColor : AppTheme.successColor;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        studentName[0].toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Parent: $parentName',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        enrollment.status.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Class Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.class_, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              className,
                              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 16, color: AppTheme.neutral600),
                          const SizedBox(width: 8),
                          Text(parentEmail, style: AppTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: AppTheme.neutral600),
                          const SizedBox(width: 8),
                          Text(
                            'Enrolled: ${DateFormat('MMM d, y').format(enrollment.enrolledAt)}',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (enrollment.amountDue > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 16, color: AppTheme.warningColor),
                            const SizedBox(width: 8),
                            Text(
                              'Amount Due: \$${enrollment.amountDue.toStringAsFixed(2)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.warningColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions (only for pending)
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectEnrollment(enrollment),
                          icon: const Icon(Icons.close),
                          label: const Text('Decline'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: BorderSide(color: AppTheme.errorColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => _approveEnrollment(enrollment),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve Enrollment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppTheme.infoColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Approve after payment received',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.infoColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getEnrollmentDetails(Enrollment enrollment) async {
    final results = await Future.wait([
      FirebaseFirestore.instance.collection('children').doc(enrollment.studentId).get(),
      FirebaseFirestore.instance.collection('users').doc(enrollment.parentId).get(),
      FirebaseFirestore.instance.collection('classes').doc(enrollment.classId).get(),
    ]);

    return {
      'studentName': results[0].data()?['name'] ?? 'Student',
      'parentName': results[1].data()?['name'] ?? 'Parent',
      'parentEmail': results[1].data()?['email'] ?? '',
      'className': results[2].data()?['title'] ?? 'Class',
    };
  }

  Future<void> _approveEnrollment(Enrollment enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Enrollment?'),
        content: const Text(
          'Have you received payment from the parent? '
          'Approving will confirm the student\'s spot in the class.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('enrollments')
          .doc(enrollment.id)
          .update({
        'status': 'active',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Enrollment approved!'),
            backgroundColor: Color(0xFF10B981),
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

  Future<void> _rejectEnrollment(Enrollment enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Enrollment?'),
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
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('enrollments')
          .doc(enrollment.id)
          .update({'status': 'rejected'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enrollment declined'),
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
    final message = _filter == 'pending'
        ? 'No pending enrollments'
        : _filter == 'approved'
            ? 'No approved enrollments yet'
            : 'No enrollments yet';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTheme.neutral400),
          const SizedBox(height: 16),
          Text(message, style: AppTheme.headline6),
          const SizedBox(height: 8),
          Text(
            'Enrollment requests will appear here',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
        ],
      ),
    );
  }
}


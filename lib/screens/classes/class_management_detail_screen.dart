import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/class_model.dart';
import '../../models/enrollment_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'package:go_router/go_router.dart';

/// Comprehensive class management detail screen for coaches
/// Shows: Attendance, Students, Payments, Enrollments
class ClassManagementDetailScreen extends StatefulWidget {
  final Class classItem;
  
  const ClassManagementDetailScreen({super.key, required this.classItem});

  @override
  State<ClassManagementDetailScreen> createState() => _ClassManagementDetailScreenState();
}

class _ClassManagementDetailScreenState extends State<ClassManagementDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spotsLeft = widget.classItem.maxStudents - widget.classItem.enrolledStudentIds.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classItem.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.info_outline, size: 20)),
            Tab(text: 'Students', icon: Icon(Icons.people, size: 20)),
            Tab(text: 'Attendance', icon: Icon(Icons.check_circle, size: 20)),
            Tab(text: 'Payments', icon: Icon(Icons.attach_money, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildStudentsTab(),
          _buildAttendanceTab(),
          _buildPaymentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(),
        icon: const Icon(Icons.more_horiz),
        label: const Text('Quick Actions'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildOverviewTab() {
    final spotsLeft = widget.classItem.maxStudents - widget.classItem.enrolledStudentIds.length;
    final enrollmentCount = widget.classItem.enrolledStudentIds.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class Information', style: AppTheme.headline6),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.category, 'Category', widget.classItem.category ?? 'General'),
                  _buildInfoRow(Icons.access_time, 'Duration', '${widget.classItem.durationMinutes} minutes'),
                  _buildInfoRow(Icons.event, 'Start Time', DateFormat('EEEE, MMM d, y • h:mm a').format(widget.classItem.startTime)),
                  _buildInfoRow(Icons.location_on, 'Location', 
                    widget.classItem.locationType == LocationType.online 
                      ? 'Online' 
                      : widget.classItem.location ?? 'TBD'),
                  _buildInfoRow(Icons.attach_money, 'Price', '\$${widget.classItem.price.toStringAsFixed(2)}'),
                  _buildInfoRow(Icons.repeat, 'Type', 
                    widget.classItem.type == ClassType.oneTime 
                      ? 'One-Time' 
                      : widget.classItem.type == ClassType.weekly 
                        ? 'Weekly' 
                        : 'Monthly'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Enrolled',
                  enrollmentCount.toString(),
                  Icons.people,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Spots Left',
                  spotsLeft.toString(),
                  Icons.event_seat,
                  spotsLeft > 0 ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Capacity',
                  '${widget.classItem.maxStudents}',
                  Icons.groups,
                  AppTheme.infoColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Revenue',
                  '\$${(widget.classItem.price * enrollmentCount).toStringAsFixed(0)}',
                  Icons.monetization_on,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description', style: AppTheme.headline6),
                  const SizedBox(height: 12),
                  Text(widget.classItem.description, style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('enrollments')
          .where('classId', isEqualTo: widget.classItem.id)
          .where('status', whereIn: ['pending', 'active'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            Icons.people_outline,
            'No Students Yet',
            'Enrollments will appear here',
          );
        }

        final enrollments = snapshot.data!.docs
            .map((doc) => Enrollment.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        // Separate pending and active
        final pending = enrollments.where((e) => e.status == EnrollmentStatus.pending).toList();
        final active = enrollments.where((e) => e.status == EnrollmentStatus.active).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (pending.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pending_actions, color: AppTheme.warningColor),
                    const SizedBox(width: 12),
                    Text(
                      '${pending.length} Enrollment${pending.length == 1 ? '' : 's'} Need Approval',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...pending.map((e) => _buildEnrollmentCard(e, isPending: true)),
              const SizedBox(height: 24),
            ],
            
            Text('Active Students (${active.length})', style: AppTheme.headline6),
            const SizedBox(height: 16),
            ...active.map((e) => _buildEnrollmentCard(e, isPending: false)),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .where('classId', isEqualTo: widget.classItem.id)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            Icons.event_available,
            'No Attendance Records',
            'Mark attendance to track student participation',
            action: ElevatedButton.icon(
              onPressed: () => _markAttendance(),
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark Today\'s Attendance'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            ),
          );
        }

        final attendance = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: attendance.length,
          itemBuilder: (context, index) {
            final record = attendance[index].data() as Map<String, dynamic>;
            final date = (record['date'] as Timestamp).toDate();
            final presentCount = (record['presentStudentIds'] as List?)?.length ?? 0;
            final totalStudents = widget.classItem.enrolledStudentIds.length;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.event_available, color: AppTheme.successColor),
                ),
                title: Text(DateFormat('EEEE, MMM d, y').format(date)),
                subtitle: Text('$presentCount/$totalStudents students present'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Edit attendance
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('enrollments')
          .where('classId', isEqualTo: widget.classItem.id)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            Icons.payments_outlined,
            'No Payment Records',
            'Payment information will appear here once students enroll',
          );
        }

        final enrollments = snapshot.data!.docs
            .map((doc) => Enrollment.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        final totalDue = enrollments.fold<double>(0, (sum, e) => sum + e.amountDue);
        final totalPaid = enrollments.fold<double>(0, (sum, e) => sum + e.amountPaid);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Payment Summary
            Row(
              children: [
                Expanded(
                  child: _buildPaymentStatCard(
                    'Total Paid',
                    '\$${totalPaid.toStringAsFixed(2)}',
                    AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentStatCard(
                    'Outstanding',
                    '\$${totalDue.toStringAsFixed(2)}',
                    totalDue > 0 ? AppTheme.warningColor : AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text('Payment Details by Student', style: AppTheme.headline6),
            const SizedBox(height: 16),
            ...enrollments.map((enrollment) => _buildPaymentCard(enrollment)),
          ],
        );
      },
    );
  }

  Widget _buildEnrollmentCard(Enrollment enrollment, {required bool isPending}) {
    return FutureBuilder<Map<String, String>>(
      future: _getStudentInfo(enrollment),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final info = snapshot.data!;
        final studentName = info['studentName']!;
        final parentName = info['parentName']!;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPending 
                  ? AppTheme.warningColor.withOpacity(0.2)
                  : AppTheme.successColor.withOpacity(0.2),
              child: Text(
                studentName[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPending ? AppTheme.warningColor : AppTheme.successColor,
                ),
              ),
            ),
            title: Text(studentName),
            subtitle: Text('Parent: $parentName'),
            trailing: isPending
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _declineEnrollment(enrollment),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _approveEnrollment(enrollment),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(Enrollment enrollment) {
    return FutureBuilder<Map<String, String>>(
      future: _getStudentInfo(enrollment),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final info = snapshot.data!;
        final studentName = info['studentName']!;
        final isPaid = enrollment.amountDue == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isPaid 
                      ? AppTheme.successColor.withOpacity(0.2)
                      : AppTheme.warningColor.withOpacity(0.2),
                  child: Icon(
                    isPaid ? Icons.check_circle : Icons.pending,
                    color: isPaid ? AppTheme.successColor : AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Paid: \$${enrollment.amountPaid.toStringAsFixed(2)}', 
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.successColor)),
                          const SizedBox(width: 16),
                          Text('Due: \$${enrollment.amountDue.toStringAsFixed(2)}', 
                            style: AppTheme.bodySmall.copyWith(
                              color: enrollment.amountDue > 0 ? AppTheme.warningColor : AppTheme.neutral600,
                              fontWeight: enrollment.amountDue > 0 ? FontWeight.w600 : FontWeight.normal,
                            )),
                        ],
                      ),
                    ],
                  ),
                ),
                if (enrollment.amountDue > 0)
                  OutlinedButton(
                    onPressed: () => _recordPayment(enrollment),
                    child: const Text('Record Payment'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.headline4.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            Text(label, style: AppTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.headline4.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle, {Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.neutral400),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.headline6),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _getStudentInfo(Enrollment enrollment) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('children')
        .doc(enrollment.studentId)
        .get();
    
    final parentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(enrollment.parentId)
        .get();

    return {
      'studentName': studentDoc.data()?['name'] ?? 'Student',
      'parentName': parentDoc.data()?['name'] ?? 'Parent',
    };
  }

  Future<void> _approveEnrollment(Enrollment enrollment) async {
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
          const SnackBar(content: Text('✅ Enrollment approved!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _declineEnrollment(Enrollment enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Enrollment?'),
        content: const Text('The student will be removed from this class.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          const SnackBar(content: Text('Enrollment declined'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _markAttendance() {
    // TODO: Navigate to mark attendance screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance marking feature coming soon!')),
    );
  }

  void _recordPayment(Enrollment enrollment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount Due: \$${enrollment.amountDue.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Mark this amount as paid?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('enrollments')
                    .doc(enrollment.id)
                    .update({
                  'amountPaid': enrollment.amountPaid + enrollment.amountDue,
                  'amountDue': 0,
                  'lastPaymentDate': FieldValue.serverTimestamp(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Payment recorded!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.primaryColor),
              title: const Text('Edit Class'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit class
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: AppTheme.successColor),
              title: const Text('Mark Attendance'),
              onTap: () {
                Navigator.pop(context);
                _markAttendance();
              },
            ),
            ListTile(
              leading: Icon(Icons.campaign, color: AppTheme.infoColor),
              title: const Text('Post Update to Class'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open post update dialog
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: AppTheme.errorColor),
              title: const Text('Cancel Class'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Cancel class
              },
            ),
          ],
        ),
      ),
    );
  }
}


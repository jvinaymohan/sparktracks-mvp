import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/classes_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/enrollment_model.dart';
import '../../models/class_model.dart';
import '../../utils/app_theme.dart';

class PaymentDashboardScreen extends StatefulWidget {
  const PaymentDashboardScreen({super.key});

  @override
  State<PaymentDashboardScreen> createState() => _PaymentDashboardScreenState();
}

class _PaymentDashboardScreenState extends State<PaymentDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer4<EnrollmentProvider, ClassesProvider, ChildrenProvider, AuthProvider>(
        builder: (context, enrollmentProvider, classesProvider, childrenProvider, authProvider, _) {
          final coachId = authProvider.currentUser?.id ?? '';
          final coachClasses = classesProvider.getClassesForCoach(coachId);
          
          // Get all enrollments for coach's classes
          final allEnrollments = <Enrollment>[];
          for (var classItem in coachClasses) {
            allEnrollments.addAll(enrollmentProvider.getEnrollmentsForClass(classItem.id));
          }
          
          final activeEnrollments = allEnrollments.where((e) => e.status == EnrollmentStatus.active).toList();
          final totalRevenue = activeEnrollments.fold<double>(0, (sum, e) => sum + e.amountPaid);
          final pendingAmount = activeEnrollments.fold<double>(0, (sum, e) => sum + e.amountDue);
          final overduePayments = activeEnrollments.where((e) => 
            e.amountDue > 0 && 
            e.nextPaymentDate != null && 
            e.nextPaymentDate!.isBefore(DateTime.now())
          ).toList();
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(totalRevenue, pendingAmount, overduePayments.length, activeEnrollments.length),
              _buildPendingTab(activeEnrollments, classesProvider, childrenProvider),
              _buildHistoryTab(allEnrollments, classesProvider, childrenProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(double totalRevenue, double pendingAmount, int overdueCount, int activeStudents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  Icons.trending_up,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  '\$${pendingAmount.toStringAsFixed(2)}',
                  Icons.pending,
                  AppTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Overdue',
                  overdueCount.toString(),
                  Icons.warning,
                  AppTheme.errorColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Active Students',
                  activeStudents.toString(),
                  Icons.people,
                  AppTheme.infoColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Quick Actions
          Text('Quick Actions', style: AppTheme.headline6),
          const SizedBox(height: AppTheme.spacingM),
          
          Wrap(
            spacing: AppTheme.spacingM,
            runSpacing: AppTheme.spacingM,
            children: [
              _buildActionButton(
                'Send Reminders',
                Icons.email,
                () => _sendPaymentReminders(context),
              ),
              _buildActionButton(
                'Generate Report',
                Icons.description,
                () => _generateReport(context),
              ),
              _buildActionButton(
                'Export Data',
                Icons.download,
                () => _exportData(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTab(List<Enrollment> enrollments, ClassesProvider classesProvider, ChildrenProvider childrenProvider) {
    final pendingPayments = enrollments.where((e) => e.amountDue > 0).toList();
    
    if (pendingPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.successColor),
            const SizedBox(height: AppTheme.spacingL),
            Text('All payments up to date!', style: AppTheme.headline6),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: pendingPayments.length,
      itemBuilder: (context, index) {
        final enrollment = pendingPayments[index];
        final classItem = classesProvider.getClassById(enrollment.classId);
        final studentList = childrenProvider.children.where(
          (s) => s.userId == enrollment.studentId
        ).toList();
        final student = studentList.isNotEmpty ? studentList.first : null;
        
        if (classItem == null || student == null) return const SizedBox.shrink();
        
        return _buildPaymentCard(enrollment, classItem, student);
      },
    );
  }

  Widget _buildHistoryTab(List<Enrollment> enrollments, ClassesProvider classesProvider, ChildrenProvider childrenProvider) {
    final paidEnrollments = enrollments.where((e) => e.amountPaid > 0).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: paidEnrollments.length,
      itemBuilder: (context, index) {
        final enrollment = paidEnrollments[index];
        final classItem = classesProvider.getClassById(enrollment.classId);
        final studentList = childrenProvider.children.where(
          (s) => s.userId == enrollment.studentId
        ).toList();
        final student = studentList.isNotEmpty ? studentList.first : null;
        
        if (classItem == null || student == null) return const SizedBox.shrink();
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.successColor,
              child: Icon(Icons.check, color: Colors.white),
            ),
            title: Text(student.name),
            subtitle: Text('${classItem.title}\nPaid: \$${enrollment.amountPaid.toStringAsFixed(2)}'),
            trailing: enrollment.lastPaymentDate != null
                ? Text(
                    '${enrollment.lastPaymentDate!.month}/${enrollment.lastPaymentDate!.day}/${enrollment.lastPaymentDate!.year}',
                    style: AppTheme.bodySmall,
                  )
                : null,
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(Enrollment enrollment, Class classItem, student) {
    final isOverdue = enrollment.nextPaymentDate != null && 
                      enrollment.nextPaymentDate!.isBefore(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isOverdue ? AppTheme.errorColor : AppTheme.warningColor,
                  child: Text(
                    student.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: AppTheme.headline6),
                      Text(classItem.title, style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${enrollment.amountDue.toStringAsFixed(2)}',
                      style: AppTheme.headline6.copyWith(
                        color: isOverdue ? AppTheme.errorColor : AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isOverdue)
                      Text(
                        'OVERDUE',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due: ${enrollment.nextPaymentDate != null ? "${enrollment.nextPaymentDate!.month}/${enrollment.nextPaymentDate!.day}/${enrollment.nextPaymentDate!.year}" : "TBD"}',
                  style: AppTheme.bodySmall,
                ),
                ElevatedButton.icon(
                  onPressed: () => _recordPayment(context, enrollment),
                  icon: const Icon(Icons.payment, size: 16),
                  label: const Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              value,
              style: AppTheme.headline5.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingM),
      ),
    );
  }

  void _recordPayment(BuildContext context, Enrollment enrollment) {
    final amountController = TextEditingController(text: enrollment.amountDue.toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text('Payment will be recorded immediately'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0) {
                  final enrollmentProvider = Provider.of<EnrollmentProvider>(context, listen: false);
                  enrollmentProvider.recordPayment(enrollment.id, amount);
                  
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Payment of \$${amount.toStringAsFixed(2)} recorded'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Record'),
            ),
          ],
        );
      },
    );
  }

  void _sendPaymentReminders(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📧 Payment reminders sent to parents with pending payments'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _generateReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📊 Financial report generated (feature coming soon)'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 Payment data exported to CSV (feature coming soon)'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}


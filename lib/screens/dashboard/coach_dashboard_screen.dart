import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/classes_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';
import '../../models/attendance_model.dart';
import '../../models/payment_model.dart';
import '../../models/enrollment_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Student> _myStudents = [];
  final List<Attendance> _todayAttendance = [];
  final List<Payment> _recentPayments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Check if profile is complete, if not, redirect to profile setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      // Check if this is first login (profile not completed)
      final profileCompleted = user?.preferences['profileCompleted'] ?? false;
      
      if (!profileCompleted && mounted) {
        // Show welcome dialog then redirect to profile
        _showWelcomeDialog();
      }
    });
  }
  
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: AppTheme.primaryColor, size: 32),
            const SizedBox(width: 12),
            Text('Welcome, Coach!', style: AppTheme.headline5),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We\'re excited to have you on Sparktracks! 🎉',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text('Let\'s set up your coaching profile so students and parents can learn more about you.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Share your experience & background')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Add certifications & specialties')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Build trust with families')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // They can skip for now
            },
            child: const Text('I\'ll do this later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/coach-profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Set Up My Profile'),
          ),
        ],
      ),
    );
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
        title: const Text('Coach Dashboard'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'My Dashboard',
            onPressed: () {
              setState(() {
                _tabController.index = 0; // Go to Overview tab
              });
            },
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.school), text: 'Classes'),
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Finance'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Manage Students',
            onPressed: () => context.push('/manage-students'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Coach Profile',
            onPressed: () => context.push('/coach-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => context.go('/coach-calendar'),
            tooltip: 'My Classes Calendar',
          ),
          IconButton(
            icon: const Icon(Icons.feedback),
            tooltip: 'Feedback',
            onPressed: () => context.go('/feedback'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go('/notification-settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildClassesTab(),
          _buildStudentsTab(),
          _buildFinanceTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create-class'),
        icon: const Icon(Icons.add),
        label: const Text('Create Class'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<ClassesProvider, AuthProvider>(
      builder: (context, classesProvider, authProvider, _) {
        final currentCoachId = authProvider.currentUser?.id ?? '';
        final myClasses = classesProvider.classes.where((c) => c.coachId == currentCoachId).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final coachName = authProvider.currentUser?.name ?? 'Coach';
                    return Text(
                      'Welcome back, $coachName!',
                      style: AppTheme.headline4.copyWith(color: Colors.white),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Ready to inspire your athletes today? 🏆',
                  style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Students',
                  _myStudents.length.toString(),
                  Icons.people,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Active Classes',
                  myClasses.length.toString(),
                  Icons.school,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today\'s Attendance',
                  '${_todayAttendance.where((a) => a.status == AttendanceStatus.present).length}/${_todayAttendance.length}',
                  Icons.check_circle,
                  AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Pending Payments',
                  _recentPayments.where((p) => p.status == PaymentStatus.pending).length.toString(),
                  Icons.payment,
                  AppTheme.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Today's Classes
          Text(
            'Today\'s Classes',
            style: AppTheme.headline6,
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...myClasses.where((c) => _isToday(c.startTime)).map((classItem) => _buildClassCard(classItem)),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Attendance Overview
          Text(
            'Attendance Overview',
            style: AppTheme.headline6,
          ),
          const SizedBox(height: AppTheme.spacingM),
          ..._todayAttendance.map((attendance) => _buildAttendanceCard(attendance)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassesTab() {
    return Consumer2<ClassesProvider, AuthProvider>(
      builder: (context, classesProvider, authProvider, _) {
        final currentCoachId = authProvider.currentUser?.id ?? '';
        final myClasses = classesProvider.classes.where((c) => c.coachId == currentCoachId).toList();
        
        if (myClasses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: AppTheme.neutral400),
                const SizedBox(height: AppTheme.spacingL),
                Text('No classes yet', style: AppTheme.headline6),
                const SizedBox(height: AppTheme.spacingS),
                Text('Create your first class!', style: AppTheme.bodyMedium),
                const SizedBox(height: AppTheme.spacingL),
                ElevatedButton.icon(
                  onPressed: () => context.go('/create-class'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Class'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          itemCount: myClasses.length,
          itemBuilder: (context, index) {
            final classItem = myClasses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.school, color: Colors.white),
            ),
            title: Text(classItem.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(classItem.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppTheme.neutral600),
                    Text(classItem.location ?? 'Online'),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: AppTheme.neutral600),
                    Text(_formatTime(classItem.startTime)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: AppTheme.successColor),
                    Text('\$${classItem.price.toStringAsFixed(2)}'),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 16, color: AppTheme.neutral600),
                    Text('${classItem.enrolledStudentIds.length}/${classItem.maxStudents} students'),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Class'),
                ),
                const PopupMenuItem(
                  value: 'attendance',
                  child: Text('Mark Attendance'),
                ),
                const PopupMenuItem(
                  value: 'students',
                  child: Text('View Students'),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancel Class'),
                ),
              ],
              onSelected: (value) {
                _handleClassAction(value, classItem);
              },
            ),
          ),
        );
          },
        );
      },
    );
  }

  Widget _buildStudentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _myStudents.length,
      itemBuilder: (context, index) {
        final student = _myStudents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(int.parse(student.colorCode!.replaceFirst('#', '0xFF'))),
              child: Text(
                student.name[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(student.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.email),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.cake, size: 16, color: AppTheme.neutral600),
                    Text('Age: ${_calculateAge(student.dateOfBirth)}'),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: AppTheme.neutral600),
                    Text('Enrolled: ${_formatDate(student.enrolledAt)}'),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Text('View Profile'),
                ),
                const PopupMenuItem(
                  value: 'attendance',
                  child: Text('Attendance History'),
                ),
                const PopupMenuItem(
                  value: 'payments',
                  child: Text('Payment History'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove from Class'),
                ),
              ],
              onSelected: (value) {
                _handleStudentAction(value, student);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinanceTab() {
    final totalRevenue = _recentPayments
        .where((p) => p.status == PaymentStatus.completed && p.type == PaymentType.classFee)
        .fold(0.0, (sum, p) => sum + p.amount);
    final pendingPayments = _recentPayments
        .where((p) => p.status == PaymentStatus.pending)
        .fold(0.0, (sum, p) => sum + p.amount);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Overview',
                    style: AppTheme.headline6,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                          'Total Revenue',
                          '\$${totalRevenue.toStringAsFixed(2)}',
                          Icons.trending_up,
                          AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: _buildAnalyticsCard(
                          'Pending',
                          '\$${pendingPayments.toStringAsFixed(2)}',
                          Icons.pending,
                          AppTheme.warningColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // View Full Ledger Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/financial-ledger?userType=coach'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('View Full Financial Ledger'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Recent Payments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: AppTheme.headline6,
              ),
              TextButton(
                onPressed: () => context.push('/financial-ledger?userType=coach'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Payment List
          ..._recentPayments.take(5).map((payment) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: payment.status == PaymentStatus.completed
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  child: Icon(
                    payment.status == PaymentStatus.completed
                        ? Icons.check_circle
                        : Icons.pending,
                    color: Colors.white,
                  ),
                ),
                title: Text(payment.notes ?? 'Payment'),
                subtitle: Text(
                  '${_getPaymentStatusLabel(payment.status)} • ${_formatDate(payment.createdAt)}',
                ),
                trailing: Text(
                  '\$${payment.amount.toStringAsFixed(2)}',
                  style: AppTheme.headline6.copyWith(
                    color: payment.status == PaymentStatus.completed
                        ? AppTheme.successColor
                        : AppTheme.neutral800,
                  ),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Payment Management Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Actions',
                    style: AppTheme.headline6,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showRecordPaymentDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Record Payment'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showPaymentReminderDialog();
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text('Send Payment Reminder'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select student and enter payment details'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Student',
                border: OutlineInputBorder(),
              ),
              items: _myStudents.map((student) {
                return DropdownMenuItem(
                  value: student.id,
                  child: Text(student.name),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment recorded successfully!')),
              );
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  void _showPaymentReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Payment Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send payment reminder to students with outstanding balances'),
            const SizedBox(height: 16),
            Text(
              '${_recentPayments.where((p) => p.status == PaymentStatus.pending).length} pending payments',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminders sent successfully!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  String _getPaymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              value,
              style: AppTheme.headline4.copyWith(color: color),
            ),
            Text(
              title,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(Class classItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.school, color: Colors.white),
        ),
        title: Text(classItem.title),
        subtitle: Text('${classItem.enrolledStudentIds.length} students enrolled'),
        trailing: Text(_formatTime(classItem.startTime)),
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    final student = _myStudents.firstWhere((s) => s.id == attendance.studentId);
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAttendanceColor(attendance.status),
          child: Icon(
            _getAttendanceIcon(attendance.status),
            color: Colors.white,
          ),
        ),
        title: Text(student.name),
        subtitle: Text('${attendance.status.name} - ${_formatTime(attendance.markedAt ?? DateTime.now())}'),
        trailing: attendance.status == AttendanceStatus.unmarked
            ? ElevatedButton(
                onPressed: () => _markAttendance(attendance),
                child: const Text('Mark'),
              )
            : null,
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: AppTheme.headline6.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppTheme.successColor;
      case AttendanceStatus.absent:
        return AppTheme.errorColor;
      case AttendanceStatus.late:
        return AppTheme.warningColor;
      case AttendanceStatus.excused:
        return AppTheme.infoColor;
      case AttendanceStatus.unmarked:
        return AppTheme.neutral400;
    }
  }

  IconData _getAttendanceIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check;
      case AttendanceStatus.absent:
        return Icons.close;
      case AttendanceStatus.late:
        return Icons.schedule;
      case AttendanceStatus.excused:
        return Icons.info;
      case AttendanceStatus.unmarked:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _handleClassAction(String action, Class classItem) {
    switch (action) {
      case 'edit':
        context.push('/create-class?classId=${classItem.id}');
        break;
      case 'attendance':
        // TODO: Navigate to attendance marking
        break;
      case 'students':
        _showAssignStudentsDialog(classItem);
        break;
      case 'cancel':
        _showCancelClassDialog(classItem);
        break;
    }
  }

  void _showAssignStudentsDialog(Class classItem) {
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context, listen: false);
    
    // Get all children from all parents
    final allChildren = childrenProvider.children;
    
    if (allChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students available. Students need to be created by parents first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        Set<String> selectedStudents = {};
        String searchQuery = '';
        
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter students based on search
            final filteredChildren = allChildren.where((child) {
              final matchesSearch = searchQuery.isEmpty || 
                  child.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  child.email.toLowerCase().contains(searchQuery.toLowerCase());
              return matchesSearch;
            }).toList();
            
            return AlertDialog(
              title: Text('Assign Students to "${classItem.title}"'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search Students',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Students list
                    Expanded(
                      child: filteredChildren.isEmpty
                          ? const Center(child: Text('No students found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredChildren.length,
                              itemBuilder: (context, index) {
                                final child = filteredChildren[index];
                                final isEnrolled = enrollmentProvider.isEnrolled(child.userId, classItem.id);
                                final isSelected = selectedStudents.contains(child.userId);
                                
                                return CheckboxListTile(
                                  value: isEnrolled || isSelected,
                                  enabled: !isEnrolled,
                                  onChanged: isEnrolled ? null : (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedStudents.add(child.userId);
                                      } else {
                                        selectedStudents.remove(child.userId);
                                      }
                                    });
                                  },
                                  title: Text(child.name),
                                  subtitle: Text(
                                    isEnrolled 
                                        ? '${child.email} (Already enrolled)' 
                                        : child.email,
                                  ),
                                  secondary: CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor,
                                    child: Text(
                                      child.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedStudents.isEmpty
                      ? null
                      : () {
                          _assignStudentsToClass(classItem, selectedStudents.toList(), enrollmentProvider);
                          Navigator.pop(dialogContext);
                        },
                  child: Text('Assign ${selectedStudents.length} Student(s)'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _assignStudentsToClass(Class classItem, List<String> studentIds, EnrollmentProvider enrollmentProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coachId = authProvider.currentUser?.id ?? '';
    
    for (final studentId in studentIds) {
      final enrollment = Enrollment(
        id: 'enroll_${DateTime.now().millisecondsSinceEpoch}_$studentId',
        classId: classItem.id,
        studentId: studentId,
        parentId: '', // Coach-assigned enrollments don't have a parent
        status: EnrollmentStatus.active,
        enrolledAt: DateTime.now(),
        amountDue: classItem.price,
        amountPaid: 0.0,
      );
      
      enrollmentProvider.addEnrollment(enrollment);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Successfully assigned ${studentIds.length} student(s) to ${classItem.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleStudentAction(String action, Student student) {
    switch (action) {
      case 'profile':
        // TODO: Navigate to student profile
        break;
      case 'attendance':
        // TODO: Navigate to attendance history
        break;
      case 'payments':
        // TODO: Navigate to payment history
        break;
      case 'remove':
        _showRemoveStudentDialog(student);
        break;
    }
  }

  void _markAttendance(Attendance attendance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mark attendance for ${_myStudents.firstWhere((s) => s.id == attendance.studentId).name}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      final index = _todayAttendance.indexWhere((a) => a.id == attendance.id);
                      if (index != -1) {
                        _todayAttendance[index] = attendance.copyWith(
                          status: AttendanceStatus.present,
                          markedAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                  child: const Text('Present'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      final index = _todayAttendance.indexWhere((a) => a.id == attendance.id);
                      if (index != -1) {
                        _todayAttendance[index] = attendance.copyWith(
                          status: AttendanceStatus.absent,
                          markedAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                  child: const Text('Absent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateClassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Class'),
        content: const Text('Class creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Create class
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCancelClassDialog(Class classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Class'),
        content: Text('Are you sure you want to cancel "${classItem.title}"? Students will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Cancel class and notify students
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRemoveStudentDialog(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove ${student.name} from the class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Remove student from class
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Yes, Remove'),
          ),
        ],
      ),
    );
  }
}

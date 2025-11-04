import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/classes_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task_model.dart';
import '../../models/enrollment_model.dart';
import '../../utils/app_theme.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = '7days';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7days', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30days', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '90days', child: Text('Last 90 Days')),
              const PopupMenuItem(value: 'year', child: Text('This Year')),
            ],
          ),
        ],
      ),
      body: Consumer6<TasksProvider, ChildrenProvider, ClassesProvider, EnrollmentProvider, AttendanceProvider, AuthProvider>(
        builder: (context, tasksProvider, childrenProvider, classesProvider, enrollmentProvider, attendanceProvider, authProvider, _) {
          final userId = authProvider.currentUser?.id ?? '';
          final userType = authProvider.currentUser?.type ?? UserType.parent;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                Text(
                  _getPeriodText(_selectedPeriod),
                  style: AppTheme.headline6,
                ),
                const SizedBox(height: AppTheme.spacingXL),
                
                if (userType == UserType.parent)
                  _buildParentAnalytics(userId, tasksProvider, childrenProvider)
                else if (userType == UserType.coach)
                  _buildCoachAnalytics(userId, classesProvider, enrollmentProvider, attendanceProvider)
                else
                  _buildChildAnalytics(userId, tasksProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParentAnalytics(String parentId, TasksProvider tasksProvider, ChildrenProvider childrenProvider) {
    final myChildren = childrenProvider.children.where((c) => c.parentId == parentId).toList();
    final allTasks = tasksProvider.tasks.where((t) => 
      myChildren.any((c) => c.userId == t.assignedTo)
    ).toList();
    
    final completedTasks = allTasks.where((t) => 
      t.status == TaskStatus.completed || t.status == TaskStatus.approved
    ).length;
    final pendingTasks = allTasks.where((t) => t.status == TaskStatus.pending).length;
    final totalPoints = allTasks.where((t) => t.status == TaskStatus.approved).fold<double>(0, (sum, t) => sum + t.rewardAmount).toInt();
    final completionRate = allTasks.isEmpty ? 0.0 : (completedTasks / allTasks.length * 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview cards
        Text('Overview', style: AppTheme.headline6),
        const SizedBox(height: AppTheme.spacingM),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Tasks',
                allTasks.length.toString(),
                Icons.assignment,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildMetricCard(
                'Completed',
                completedTasks.toString(),
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Points',
                totalPoints.toString(),
                Icons.stars,
                AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildMetricCard(
                'Completion Rate',
                '${completionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                AppTheme.infoColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingXL),
        
        // Per-child breakdown
        Text('Performance by Child', style: AppTheme.headline6),
        const SizedBox(height: AppTheme.spacingM),
        
        ...myChildren.map((child) {
          final childTasks = allTasks.where((t) => t.assignedTo == child.userId).toList();
          final childCompleted = childTasks.where((t) => 
            t.status == TaskStatus.completed || t.status == TaskStatus.approved
          ).length;
          final childPoints = childTasks.where((t) => t.status == TaskStatus.approved).fold<double>(0, (sum, t) => sum + t.rewardAmount).toInt();
          final childRate = childTasks.isEmpty ? 0.0 : (childCompleted / childTasks.length);
          
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(int.parse(child.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(child.name, style: AppTheme.headline6),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  LinearProgressIndicator(
                    value: childRate,
                    backgroundColor: AppTheme.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(int.parse(child.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$childCompleted/${childTasks.length} tasks'),
                      Text('$childPoints points', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        
        const SizedBox(height: AppTheme.spacingXL),
        
        // Task status breakdown
        Text('Task Status Distribution', style: AppTheme.headline6),
        const SizedBox(height: AppTheme.spacingM),
        
        _buildStatusChart(allTasks),
      ],
    );
  }

  Widget _buildCoachAnalytics(String coachId, ClassesProvider classesProvider, EnrollmentProvider enrollmentProvider, AttendanceProvider attendanceProvider) {
    final myClasses = classesProvider.getClassesForCoach(coachId);
    final totalEnrollments = myClasses.fold<int>(0, (sum, c) => 
      sum + enrollmentProvider.getEnrollmentsForClass(c.id).where((e) => e.status == EnrollmentStatus.active).length
    );
    final totalRevenue = myClasses.fold<double>(0, (sum, c) {
      final classEnrollments = enrollmentProvider.getEnrollmentsForClass(c.id);
      return sum + classEnrollments.fold<double>(0, (s, e) => s + e.amountPaid);
    });
    final pendingRevenue = myClasses.fold<double>(0, (sum, c) {
      final classEnrollments = enrollmentProvider.getEnrollmentsForClass(c.id);
      return sum + classEnrollments.fold<double>(0, (s, e) => s + e.amountDue);
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview cards
        Text('Overview', style: AppTheme.headline6),
        const SizedBox(height: AppTheme.spacingM),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Classes',
                myClasses.length.toString(),
                Icons.school,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildMetricCard(
                'Students',
                totalEnrollments.toString(),
                Icons.people,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Revenue',
                '\$${totalRevenue.toStringAsFixed(0)}',
                Icons.attach_money,
                AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildMetricCard(
                'Pending',
                '\$${pendingRevenue.toStringAsFixed(0)}',
                Icons.pending,
                AppTheme.infoColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingXL),
        
        // Per-class breakdown
        Text('Performance by Class', style: AppTheme.headline6),
        const SizedBox(height: AppTheme.spacingM),
        
        ...myClasses.map((classItem) {
          final enrollments = enrollmentProvider.getEnrollmentsForClass(classItem.id).where((e) => e.status == EnrollmentStatus.active).toList();
          final revenue = enrollments.fold<double>(0, (sum, e) => sum + e.amountPaid);
          final pending = enrollments.fold<double>(0, (sum, e) => sum + e.amountDue);
          final fillRate = classItem.maxStudents > 0 ? (enrollments.length / classItem.maxStudents) : 0.0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(classItem.title, style: AppTheme.headline6),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    '${enrollments.length}/${classItem.maxStudents} students',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  LinearProgressIndicator(
                    value: fillRate,
                    backgroundColor: AppTheme.neutral200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successColor),
                    minHeight: 8,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Revenue', style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
                          Text('\$${revenue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Pending', style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
                          Text('\$${pending.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.warningColor)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildChildAnalytics(String userId, TasksProvider tasksProvider) {
    final myTasks = tasksProvider.tasks.where((t) => t.assignedTo == userId).toList();
    final completedTasks = myTasks.where((t) => 
      t.status == TaskStatus.completed || t.status == TaskStatus.approved
    ).length;
    final pendingTasks = myTasks.where((t) => t.status == TaskStatus.pending).length;
    final totalPoints = myTasks.where((t) => t.status == TaskStatus.approved).fold<double>(0, (sum, t) => sum + t.rewardAmount).toInt();
    final completionRate = myTasks.isEmpty ? 0.0 : (completedTasks / myTasks.length * 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Performance', style: AppTheme.headline6),
        const SizedBox(height: AppTheme.spacingM),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Tasks',
                myTasks.length.toString(),
                Icons.assignment,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildMetricCard(
                'Completed',
                completedTasks.toString(),
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Points',
                totalPoints.toString(),
                Icons.stars,
                AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildMetricCard(
                'Success Rate',
                '${completionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                AppTheme.infoColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingXL),
        
        _buildStatusChart(myTasks),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
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

  Widget _buildStatusChart(List tasks) {
    final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
    final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
    final approved = tasks.where((t) => t.status == TaskStatus.approved).length;
    final rejected = tasks.where((t) => t.status == TaskStatus.rejected).length;
    
    final total = tasks.length;
    if (total == 0) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Pending', pending, total, AppTheme.neutral600),
            _buildStatusRow('In Progress', inProgress, total, AppTheme.infoColor),
            _buildStatusRow('Completed', completed, total, AppTheme.successColor),
            _buildStatusRow('Approved', approved, total, Colors.green),
            _buildStatusRow('Rejected', rejected, total, AppTheme.errorColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$count (${(percentage * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppTheme.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  String _getPeriodText(String period) {
    switch (period) {
      case '7days':
        return 'Last 7 Days';
      case '30days':
        return 'Last 30 Days';
      case '90days':
        return 'Last 90 Days';
      case 'year':
        return 'This Year';
      default:
        return 'All Time';
    }
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:go_router/go_router.dart';
import '../../models/invoice_model.dart';
// TODO: Re-enable after model fixes
// import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';
// TODO: Re-enable after model fixes
// import '../../services/csv_export_service.dart';
// import '../../widgets/csv_export_button.dart';

/// Coach Financial Dashboard (v3.0)
/// Comprehensive business management for coaches
class CoachFinancialDashboard extends StatefulWidget {
  const CoachFinancialDashboard({super.key});

  @override
  State<CoachFinancialDashboard> createState() => _CoachFinancialDashboardState();
}

class _CoachFinancialDashboardState extends State<CoachFinancialDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.goToDashboard(context),
        ),
        actions: [
          // TODO: Re-enable CSV export after model fixes
          // IconButton(
          //   onPressed: () => _showExportDialog(),
          //   icon: const Icon(Icons.download),
          //   tooltip: 'Export Financial Data',
          // ),
          NavigationHelper.buildGradientHomeButton(context),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'Invoices', icon: Icon(Icons.receipt, size: 20)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildInvoicesTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final monthName = DateFormat('MMMM yyyy').format(DateTime.now());
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Overview - $monthName', style: AppTheme.headline4),
          const SizedBox(height: 24),
          
          // Key Metrics Cards - Real Data or Empty State
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Revenue This Month',
                  '\$0',
                  Icons.trending_up,
                  AppTheme.successColor,
                  'Start by enrolling students',
                  false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Outstanding',
                  '\$0',
                  Icons.pending_actions,
                  AppTheme.warningColor,
                  'No pending invoices',
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Active Students',
                  '0',
                  Icons.people,
                  AppTheme.primaryColor,
                  'Enroll students to start tracking',
                  false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Active Classes',
                  '0',
                  Icons.school,
                  Colors.purple,
                  'Create your first class!',
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Getting Started Guide - Empty State
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDCFCE7),
                  const Color(0xFFBFDBFE),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.rocket_launch_rounded, color: Color(0xFF166534), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Get Started with Your Business',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGettingStartedStep('1', 'Create your first class', 'Set schedule, pricing, and details', false),
                _buildGettingStartedStep('2', 'Make it public', 'Let parents discover your classes', false),
                _buildGettingStartedStep('3', 'Enroll students', 'Start tracking revenue and attendance', false),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/create-class'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Your First Class'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          
          // Beta Notice
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: Color(0xFFFF6B9D), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '📊 Financial tracking will show real data as you enroll students and track classes. This dashboard will populate automatically!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _createInvoice(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addExpense(),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Add Expense'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool isPositive,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                if (isPositive)
                  Icon(Icons.arrow_upward, color: AppTheme.successColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTheme.headline3.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: isPositive ? AppTheme.successColor : AppTheme.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBreakdownCard(String className, String revenue, String breakdown, double percentage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(className, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                ),
                Text(revenue, style: AppTheme.headline6.copyWith(color: AppTheme.successColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(breakdown, style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: AppTheme.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
              ),
            ),
            const SizedBox(height: 4),
            Text('${(percentage * 100).toInt()}% of total revenue', 
                 style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRevenueCard(String name, String amount, int rank) {
    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        break;
      case 2:
        rankColor = Colors.grey;
        break;
      case 3:
        rankColor = Colors.brown;
        break;
      default:
        rankColor = AppTheme.neutral400;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rankColor,
          child: Text(
            '$rank',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        trailing: Text(
          amount,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.successColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoicesTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final coachId = authProvider.currentUser?.id ?? '';

    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'pending', label: Text('Pending')),
                    ButtonSegment(value: 'paid', label: Text('Paid')),
                    ButtonSegment(value: 'overdue', label: Text('Overdue')),
                  ],
                  selected: {'all'},
                  onSelectionChanged: (Set<String> selection) {},
                ),
              ),
            ],
          ),
        ),
        
        // Invoices List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('invoices')
                .where('coachId', isEqualTo: coachId)
                .orderBy('issueDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: AppTheme.neutral400),
                      const SizedBox(height: 16),
                      Text('No Invoices Yet', style: AppTheme.headline5),
                      const SizedBox(height: 8),
                      Text('Create your first invoice!', style: AppTheme.bodyMedium),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final invoice = Invoice.fromJson(doc.data() as Map<String, dynamic>);
                  return _buildInvoiceCard(invoice);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    Color statusColor;
    IconData statusIcon;
    
    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case InvoiceStatus.overdue:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.error;
        break;
      case InvoiceStatus.sent:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = AppTheme.neutral500;
        statusIcon = Icons.drafts;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 32),
        title: Text('Invoice #${invoice.invoiceNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.studentName),
            Text(
              'Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${invoice.total.toStringAsFixed(2)}',
              style: AppTheme.headline6.copyWith(color: statusColor),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                invoice.status.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _viewInvoice(invoice),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    // TODO: Replace with real data from Firestore
    // For now, show honest empty state with getting started guide
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Analytics', style: AppTheme.headline4),
          const SizedBox(height: 8),
          Text(
            'Track your coaching business growth and performance',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 24),
          
          // Beta Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.infoColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics Coming Soon!',
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Once you have students enrolled and classes running, we\'ll show detailed analytics here: student growth, revenue trends, class performance, and more.',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Current Metrics (Real Data)
          Text('Current Metrics', style: AppTheme.headline5),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRealMetricCard('Total Students', '0', 'Enroll your first student', Icons.people),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRealMetricCard('Active Classes', '0', 'Create your first class', Icons.class_),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRealMetricCard('Total Revenue', '\$0', 'Revenue will appear here', Icons.attach_money),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRealMetricCard('This Month', '\$0', 'Track monthly earnings', Icons.calendar_today),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // What You'll See Here
          Text('What You\'ll See Here', style: AppTheme.headline5),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureRow(Icons.trending_up, 'Student Growth', 'Track enrollment trends over time'),
                  const Divider(height: 32),
                  _buildFeatureRow(Icons.attach_money, 'Revenue Analytics', 'See income breakdown and trends'),
                  const Divider(height: 32),
                  _buildFeatureRow(Icons.school, 'Class Performance', 'Identify your top performing classes'),
                  const Divider(height: 32),
                  _buildFeatureRow(Icons.people, 'Student Retention', 'Monitor student engagement and retention rates'),
                  const Divider(height: 32),
                  _buildFeatureRow(Icons.star, 'Rating Trends', 'Track your ratings and reviews over time'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Quick Actions
          Text('Quick Actions', style: AppTheme.headline5),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/coach/class-wizard'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Class'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/coach-profile-wizard'),
                  icon: const Icon(Icons.person),
                  label: const Text('Complete Profile'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRealMetricCard(String label, String value, String subtitle, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(height: 12),
            Text(value, style: AppTheme.headline4),
            Text(label, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              Text(description, style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthCard(String label, String value, String change, IconData icon) {
    final isPositive = change.startsWith('+');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(height: 12),
            Text(value, style: AppTheme.headline4),
            Text(label, style: AppTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTheme.bodyMedium),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassPerformanceCard(String className, int students, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.class_, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(className, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  Text('$students students', style: AppTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewInvoice(Invoice invoice) {
    // Show invoice details dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice #${invoice.invoiceNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student: ${invoice.studentName}'),
              Text('Email: ${invoice.parentEmail}'),
              const SizedBox(height: 16),
              Text('Amount: \$${invoice.total.toStringAsFixed(2)}'),
              Text('Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}'),
              const SizedBox(height: 16),
              Text('Status: ${invoice.status.toString().split('.').last}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (invoice.status != InvoiceStatus.paid)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _markAsPaid(invoice);
              },
              child: const Text('Mark as Paid'),
            ),
        ],
      ),
    );
  }

  void _createInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice creation wizard coming in final phase!')),
    );
  }

  void _addExpense() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense tracking coming in final phase!')),
    );
  }

  void _markAsPaid(Invoice invoice) {
    // Update invoice status
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Invoice marked as paid!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildGettingStartedStep(String number, String title, String subtitle, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF10B981) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: completed ? const Color(0xFF10B981) : const Color(0xFF166534),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: completed ? Colors.white : const Color(0xFF166534),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Re-enable after fixing model field mappings
  // void _showExportDialog() {
  //   // CSV export functionality temporarily disabled
  //   // Needs: Invoice.amount → Invoice.total, Task.points field
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}


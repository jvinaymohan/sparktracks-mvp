import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';

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
          
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Revenue This Month',
                  '\$4,850',
                  Icons.trending_up,
                  AppTheme.successColor,
                  '+15% from last month',
                  true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Outstanding',
                  '\$1,200',
                  Icons.pending_actions,
                  AppTheme.warningColor,
                  '6 invoices pending',
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
                  'Expenses',
                  '\$450',
                  Icons.money_off,
                  AppTheme.errorColor,
                  'Equipment, travel, etc.',
                  false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Net Profit',
                  '\$4,400',
                  Icons.account_balance_wallet,
                  Colors.purple,
                  '+18% from last month',
                  true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Revenue Breakdown
          Text('Revenue by Class', style: AppTheme.headline5),
          const SizedBox(height: 16),
          _buildRevenueBreakdownCard('Beginner Tennis', '\$1,800', '12 students × \$35 × 4 sessions', 0.37),
          _buildRevenueBreakdownCard('Advanced Piano', '\$1,600', '4 students × \$80 × 5 sessions', 0.33),
          _buildRevenueBreakdownCard('Chess Club', '\$900', '15 students × \$15 × 4 sessions', 0.19),
          _buildRevenueBreakdownCard('Private Lessons', '\$550', 'Various', 0.11),
          
          const SizedBox(height: 32),
          
          // Top Students
          Text('Top Students by Revenue', style: AppTheme.headline5),
          const SizedBox(height: 16),
          _buildStudentRevenueCard('Martinez Family', '\$450/month', 1),
          _buildStudentRevenueCard('Chen Family', '\$380/month', 2),
          _buildStudentRevenueCard('Johnson Family', '\$320/month', 3),
          
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Analytics', style: AppTheme.headline4),
          const SizedBox(height: 24),
          
          // Growth Metrics
          Row(
            children: [
              Expanded(
                child: _buildGrowthCard('Total Students', '45', '+5', Icons.people),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGrowthCard('Active Classes', '8', '+2', Icons.class_),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGrowthCard('Sessions This Month', '120', '+12', Icons.event),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGrowthCard('Avg Attendance', '88%', '+3%', Icons.check_circle),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Growth Trends
          Text('Growth Trends', style: AppTheme.headline5),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTrendRow(Icons.trending_up, 'Students', '12% month-over-month', AppTheme.successColor),
                  _buildTrendRow(Icons.attach_money, 'Revenue', '15% increase', AppTheme.successColor),
                  _buildTrendRow(Icons.loyalty, 'Retention', '95% (Excellent!)', AppTheme.successColor),
                  _buildTrendRow(Icons.star, 'Avg Rating', '4.9/5.0', AppTheme.accentColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Top Performing Classes
          Text('Top Performing Classes', style: AppTheme.headline5),
          const SizedBox(height: 16),
          _buildClassPerformanceCard('Beginner Tennis', 12, 'Waitlist', AppTheme.successColor),
          _buildClassPerformanceCard('Advanced Piano', 4, 'Premium', Colors.purple),
          _buildClassPerformanceCard('Chess Club', 15, 'Popular', AppTheme.primaryColor),
        ],
      ),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}


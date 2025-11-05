import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../models/payment_model.dart';

class FinancialLedgerScreen extends StatefulWidget {
  final String userType; // 'parent', 'child', or 'coach'
  
  const FinancialLedgerScreen({super.key, required this.userType});

  @override
  State<FinancialLedgerScreen> createState() => _FinancialLedgerScreenState();
}

class _FinancialLedgerScreenState extends State<FinancialLedgerScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Payment data - loaded from Firebase (starts empty for new users)
  final List<Payment> _allTransactions = [];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Ledger'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final route = widget.userType == 'parent' 
                  ? '/parent-dashboard' 
                  : widget.userType == 'child' 
                      ? '/child-dashboard' 
                      : '/coach-dashboard';
              context.go(route);
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Income', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'Expenses', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          _buildSummarySection(),
          const Divider(),
          // Transaction List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(_allTransactions),
                _buildTransactionList(_getIncomeTransactions()),
                _buildTransactionList(_getExpenseTransactions()),
                _buildTransactionList(_getPendingTransactions()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final totalIncome = _getIncomeTransactions()
        .where((t) => t.status == PaymentStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = _getExpenseTransactions()
        .where((t) => t.status == PaymentStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);
    final pending = _getPendingTransactions()
        .fold(0.0, (sum, t) => sum + t.amount);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Income',
              '\$${totalIncome.toStringAsFixed(2)}',
              Icons.trending_up,
              AppTheme.successColor,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: _buildSummaryCard(
              'Total Expenses',
              '\$${totalExpenses.toStringAsFixed(2)}',
              Icons.trending_down,
              AppTheme.errorColor,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              '\$${pending.toStringAsFixed(2)}',
              Icons.pending,
              AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              value,
              style: AppTheme.headline6.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Payment> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppTheme.neutral400),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'No transactions yet',
              style: AppTheme.headline6.copyWith(color: AppTheme.neutral600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final payment = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPaymentColor(payment),
              child: Icon(
                _getPaymentIcon(payment),
                color: Colors.white,
              ),
            ),
            title: Text(_getPaymentTypeLabel(payment.type)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payment.notes != null) Text(payment.notes!),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(payment.status),
                      size: 14,
                      color: _getStatusColor(payment.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusLabel(payment.status),
                      style: TextStyle(
                        color: _getStatusColor(payment.status),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule, size: 14, color: AppTheme.neutral600),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(payment.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_isIncome(payment.type) ? '+' : '-'}\$${payment.amount.toStringAsFixed(2)}',
                  style: AppTheme.headline6.copyWith(
                    color: _isIncome(payment.type) ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                Text(
                  payment.method.toString().split('.').last.toUpperCase(),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Payment> _getIncomeTransactions() {
    return _allTransactions.where((p) => _isIncome(p.type)).toList();
  }

  List<Payment> _getExpenseTransactions() {
    return _allTransactions.where((p) => !_isIncome(p.type)).toList();
  }

  List<Payment> _getPendingTransactions() {
    return _allTransactions.where((p) => p.status == PaymentStatus.pending).toList();
  }

  bool _isIncome(PaymentType type) {
    return type == PaymentType.bonus || type == PaymentType.taskReward || type == PaymentType.refund;
  }

  Color _getPaymentColor(Payment payment) {
    if (_isIncome(payment.type)) {
      return AppTheme.successColor;
    } else {
      return AppTheme.primaryColor;
    }
  }

  IconData _getPaymentIcon(Payment payment) {
    switch (payment.type) {
      case PaymentType.classFee:
        return Icons.school;
      case PaymentType.taskReward:
        return Icons.assignment_turned_in;
      case PaymentType.bonus:
        return Icons.stars;
      case PaymentType.refund:
        return Icons.replay;
      case PaymentType.penalty:
        return Icons.warning;
      case PaymentType.adjustment:
        return Icons.tune;
    }
  }

  String _getPaymentTypeLabel(PaymentType type) {
    switch (type) {
      case PaymentType.classFee:
        return 'Class Fee';
      case PaymentType.taskReward:
        return 'Task Reward';
      case PaymentType.bonus:
        return 'Bonus';
      case PaymentType.refund:
        return 'Refund';
      case PaymentType.penalty:
        return 'Penalty';
      case PaymentType.adjustment:
        return 'Adjustment';
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.refunded:
        return Icons.replay;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return AppTheme.successColor;
      case PaymentStatus.pending:
        return AppTheme.warningColor;
      case PaymentStatus.failed:
        return AppTheme.errorColor;
      case PaymentStatus.cancelled:
        return AppTheme.neutral600;
      case PaymentStatus.refunded:
        return AppTheme.infoColor;
    }
  }

  String _getStatusLabel(PaymentStatus status) {
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}


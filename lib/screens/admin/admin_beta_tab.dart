import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_user_model.dart';
import '../../utils/app_theme.dart';

class AdminBetaSignupsTab extends StatefulWidget {
  const AdminBetaSignupsTab({super.key});

  @override
  State<AdminBetaSignupsTab> createState() => _AdminBetaSignupsTabState();
}

class _AdminBetaSignupsTabState extends State<AdminBetaSignupsTab> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        var signups = adminProvider.betaSignups;
        
        // Apply status filter
        if (_filterStatus != 'all') {
          signups = signups.where((s) => s.status == _filterStatus).toList();
        }
        
        // Sort by date (newest first)
        signups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          children: [
            // Header with filters
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.neutral50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Beta Signup Requests', style: AppTheme.headline6),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('All')),
                          ButtonSegment(value: 'pending', label: Text('Pending')),
                          ButtonSegment(value: 'approved', label: Text('Approved')),
                          ButtonSegment(value: 'rejected', label: Text('Rejected')),
                        ],
                        selected: {_filterStatus},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _filterStatus = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${signups.length} ${_filterStatus == 'all' ? 'total' : _filterStatus} requests',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                  ),
                ],
              ),
            ),
            
            // Signups list
            Expanded(
              child: signups.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: AppTheme.neutral400),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_filterStatus == 'all' ? '' : _filterStatus} signups',
                            style: AppTheme.headline6,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: signups.length,
                      itemBuilder: (context, index) {
                        final signup = signups[index];
                        return _buildSignupCard(signup, adminProvider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignupCard(BetaSignupRequest signup, AdminProvider adminProvider) {
    final isPending = signup.status == 'pending';
    final isApproved = signup.status == 'approved';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(signup.status),
                  child: Text(
                    signup.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(signup.name, style: AppTheme.headline6),
                      Text(signup.email, style: AppTheme.bodySmall),
                    ],
                  ),
                ),
                Chip(
                  label: Text(signup.status.toUpperCase()),
                  backgroundColor: _getStatusColor(signup.status).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: _getStatusColor(signup.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Details
            _buildDetailRow('Role', signup.role.toUpperCase()),
            _buildDetailRow('Requested', _formatDate(signup.createdAt)),
            if (signup.message != null && signup.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neutral50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message:',
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(signup.message!, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
            ],
            
            if (signup.processedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Processed on ${_formatDate(signup.processedAt!)}',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
              ),
            ],
            
            if (signup.notes != null) ...[
              const SizedBox(height: 8),
              Text('Admin notes: ${signup.notes}', style: AppTheme.bodySmall),
            ],
            
            // Actions (only for pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveSignup(signup, adminProvider),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve & Send Access'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectSignup(signup, adminProvider),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          ),
          Text(value, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.neutral600;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _approveSignup(BetaSignupRequest signup, AdminProvider adminProvider) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Beta Signup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approve ${signup.name} for beta access?'),
            const SizedBox(height: 16),
            const Text('This will:'),
            const Text('• Send welcome email with access instructions'),
            const Text('• Create their account'),
            const Text('• Grant beta access'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              adminProvider.approveBetaSignup(
                signup.id,
                adminProvider.currentAdmin!.id,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Approved! Welcome email sent to ${signup.email}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectSignup(BetaSignupRequest signup, AdminProvider adminProvider) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Beta Signup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${signup.name}\'s beta request?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              adminProvider.rejectBetaSignup(
                signup.id,
                adminProvider.currentAdmin!.id,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signup rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _searchQuery = '';
  UserType? _filterType;

  Future<List<User>> _getAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs
          .map((doc) => User.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allUsers = snapshot.data ?? [];
        
        // Apply filters
        var filteredUsers = allUsers.where((user) {
          final matchesSearch = _searchQuery.isEmpty ||
              user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase());
          
          final matchesType = _filterType == null || user.type == _filterType;
          
          return matchesSearch && matchesType;
        }).toList();

        return Column(
          children: [
            // Header with search and filters
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.neutral50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search users by name or email...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<UserType?>(
                        value: _filterType,
                        hint: const Text('All Roles'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Roles')),
                          const DropdownMenuItem(value: UserType.parent, child: Text('Parents')),
                          const DropdownMenuItem(value: UserType.child, child: Text('Children')),
                          const DropdownMenuItem(value: UserType.coach, child: Text('Coaches')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterType = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredUsers.length} users found',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _exportUsers(filteredUsers),
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Export'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {});
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Users table
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: AppTheme.neutral400),
                          SizedBox(height: 16),
                          Text('No users found'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Consumer<AdminProvider>(
                          builder: (context, adminProvider, _) {
                            return _buildUserCard(user, adminProvider);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(User user, AdminProvider adminProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.type),
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.name),
        subtitle: Text('${user.email} • ${_getRoleLabel(user.type)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(user.isActive ? 'Active' : 'Inactive'),
              backgroundColor: user.isActive ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
              labelStyle: TextStyle(
                color: user.isActive ? AppTheme.successColor : AppTheme.errorColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User details
                _buildDetailRow('User ID', user.id),
                _buildDetailRow('Phone', user.phone ?? 'Not provided'),
                _buildDetailRow('Created', _formatDate(user.createdAt)),
                _buildDetailRow('Last Updated', _formatDate(user.updatedAt)),
                
                const Divider(height: 24),
                
                // Actions
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _editUser(user),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.infoColor,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _toggleUserStatus(user, adminProvider),
                      icon: Icon(user.isActive ? Icons.block : Icons.check_circle, size: 16),
                      label: Text(user.isActive ? 'Suspend' : 'Activate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user.isActive ? AppTheme.warningColor : AppTheme.successColor,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _viewUserActivity(user),
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text('Activity'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteUser(user, adminProvider),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserType type) {
    switch (type) {
      case UserType.parent:
        return AppTheme.primaryColor;
      case UserType.child:
        return AppTheme.warningColor;
      case UserType.coach:
        return AppTheme.successColor;
      case UserType.admin:
        return AppTheme.errorColor;
    }
  }

  String _getRoleLabel(UserType type) {
    return type.toString().split('.').last.toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editUser(User user) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(user: user),
    );
  }

  void _toggleUserStatus(User user, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Suspend User?' : 'Activate User?'),
        content: Text(
          user.isActive
              ? 'This will prevent ${user.name} from logging in.'
              : 'This will allow ${user.name} to log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedUser = user.copyWith(isActive: !user.isActive);
              adminProvider.updateUser(updatedUser);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User ${user.isActive ? 'suspended' : 'activated'} successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(user.isActive ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _viewUserActivity(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.name} Activity'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Activity:'),
              SizedBox(height: 16),
              Text('• Logged in 2 hours ago'),
              Text('• Created 3 tasks yesterday'),
              Text('• Completed 5 tasks this week'),
              SizedBox(height: 16),
              Text('(Full activity tracking coming soon)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(User user, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text(
          'Are you sure you want to delete ${user.name}?\n\nThis action cannot be undone and will delete:\n• User account\n• All associated data\n• Tasks and progress',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              adminProvider.deleteUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportUsers(List users) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${users.length} users to CSV...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
    // In production, generate CSV and download
  }
}

// Edit User Dialog
class _EditUserDialog extends StatefulWidget {
  final User user;
  
  const _EditUserDialog({required this.user});

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final adminProvider = Provider.of<AdminProvider>(context, listen: false);
            final updatedUser = widget.user.copyWith(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text.isEmpty ? null : _phoneController.text,
              updatedAt: DateTime.now(),
            );
            
            adminProvider.updateUser(updatedUser);
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}


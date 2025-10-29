import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../models/student_model.dart';
import '../../utils/app_theme.dart';

class AddEditChildScreen extends StatefulWidget {
  final Student? child; // If null, we're adding; if not null, we're editing

  const AddEditChildScreen({super.key, this.child});

  @override
  State<AddEditChildScreen> createState() => _AddEditChildScreenState();
}

class _AddEditChildScreenState extends State<AddEditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  DateTime? _selectedDateOfBirth;
  String _selectedColorCode = '#4CAF50';
  bool _isSubmitting = false;
  String? _generatedPassword; // Auto-generated password for the child

  final List<String> _availableColors = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#FF9800', // Orange
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#FFEB3B', // Yellow
    '#E91E63', // Pink
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    if (widget.child != null) {
      // Editing mode - populate fields
      _nameController.text = widget.child!.name;
      _selectedDateOfBirth = widget.child!.dateOfBirth;
      _selectedColorCode = widget.child!.colorCode ?? '#4CAF50';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  // Generate a simple, memorable password for the child
  String _generateChildPassword(String name, DateTime birthDate) {
    // Format: FirstName + MMDD (e.g., "Emma0315" for Emma born March 15)
    final firstName = name.split(' ').first;
    final month = birthDate.month.toString().padLeft(2, '0');
    final day = birthDate.day.toString().padLeft(2, '0');
    return '$firstName$month$day';
  }

  bool get isEditing => widget.child != null;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Child' : 'Add Child'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/parent-dashboard');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                    Text(
                      isEditing ? 'Edit Child Profile' : 'Add New Child',
                      style: AppTheme.headline4.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      isEditing 
                          ? 'Update your child\'s information'
                          : 'Add a child to manage their tasks and activities',
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Child Name
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Child Name',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Emma Johnson',
                          prefixIcon: Icon(Icons.child_care),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter child\'s name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Email (Optional)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email (Optional)',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'An email and password will be auto-generated for child login',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.infoColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Date of Birth
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date of Birth',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      InkWell(
                        onTap: () => _selectDateOfBirth(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake),
                            hintText: 'Select date of birth',
                          ),
                          child: Text(
                            _selectedDateOfBirth != null
                                ? '${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.year}'
                                : 'Tap to select date',
                            style: _selectedDateOfBirth != null
                                ? null
                                : TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                      if (_selectedDateOfBirth == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            'Please select date of birth',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Color Code Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Identification Color',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Select a color to easily identify this child',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.neutral600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableColors.map((color) {
                          final isSelected = color == _selectedColorCode;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorCode = color;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Color(int.parse(color.replaceFirst('#', '0xFF'))).withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveChild,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: AppTheme.spacingM),
                            Text('Saving...'),
                          ],
                        )
                      : Text(isEditing ? 'Update Child' : 'Add Child'),
                ),
              ),
              
              // Reset Password Button (only in edit mode)
              if (isEditing) ...[
                const SizedBox(height: AppTheme.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _showResetPasswordDialog,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                    icon: Icon(Icons.lock_reset, color: AppTheme.primaryColor),
                    label: Text(
                      'Reset Child Password',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
              
              // Delete Button (only in edit mode)
              if (isEditing) ...[
                const SizedBox(height: AppTheme.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : _showDeleteConfirmation,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    child: const Text(
                      'Delete Child',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _saveChild() async {
    if (_formKey.currentState!.validate() && _selectedDateOfBirth != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Get current parent ID from auth
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final parentId = authProvider.currentUser?.id ?? 'parent1';
        
        // Generate auto-email and password for child
        final childId = widget.child?.id ?? 'child_${DateTime.now().millisecondsSinceEpoch}';
        final firstName = _nameController.text.split(' ').first.toLowerCase();
        final autoEmail = '$firstName.${childId.substring(6, 12)}@sparktracks.child';
        
        // Generate password
        _generatedPassword = _generateChildPassword(_nameController.text, _selectedDateOfBirth!);
        
        // Create or update student object
        final student = Student(
          id: childId,
          userId: widget.child?.userId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          parentId: parentId,
          name: _nameController.text,
          email: widget.child?.email ?? autoEmail, // Keep existing email if editing
          dateOfBirth: _selectedDateOfBirth!,
          enrolledAt: widget.child?.enrolledAt ?? DateTime.now(),
          colorCode: _selectedColorCode,
        );

        // Save to provider
        final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
        if (isEditing) {
          childrenProvider.updateChild(student);
        } else {
          childrenProvider.addChild(student);
        }

        // Simulate API call (in real app, create Firebase account here)
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // Show success with login credentials for new children
          if (!isEditing) {
            _showCredentialsDialog(autoEmail, _generatedPassword!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Child updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/parent-dashboard');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error ${isEditing ? 'updating' : 'adding'} child: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } else if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Child'),
        content: Text('Are you sure you want to remove ${_nameController.text} from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChild();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCredentialsDialog(String email, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Child Added!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save these login credentials:',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.neutral300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email:', style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
                  const SizedBox(height: 4),
                  SelectableText(
                    email,
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Password:', style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
                  const SizedBox(height: 4),
                  SelectableText(
                    password,
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.warningColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please write this down! Your child will need these to log in.',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.warningColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/parent-dashboard');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog() {
    final newPassword = _generateChildPassword(widget.child!.name, widget.child!.dateOfBirth);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Child Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new password will be generated for ${widget.child!.name}:',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.neutral300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Password:', style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
                  const SizedBox(height: 4),
                  SelectableText(
                    newPassword,
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please write this down and share it with your child.',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.infoColor),
                    ),
                  ),
                ],
              ),
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
              _resetChildPassword(newPassword);
            },
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  void _resetChildPassword(String newPassword) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: In real app, update password in Firebase Auth
      // For now, just show success message
      
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset for ${widget.child!.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _deleteChild() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Delete from provider
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      childrenProvider.deleteChild(widget.child!.id);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Child removed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to parent dashboard
        context.go('/parent-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting child: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}



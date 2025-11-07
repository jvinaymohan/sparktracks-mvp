import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../models/student_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';

/// Quick single-screen child creation dialog - no scrolling needed!
class QuickAddChildDialog extends StatefulWidget {
  const QuickAddChildDialog({super.key});

  @override
  State<QuickAddChildDialog> createState() => _QuickAddChildDialogState();
}

class _QuickAddChildDialogState extends State<QuickAddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedColorCode = '#4CAF50';
  bool _isSubmitting = false;
  bool _useCustomCredentials = false;

  final List<Map<String, dynamic>> _quickColors = [
    {'color': '#4CAF50', 'name': 'Green', 'emoji': '💚'},
    {'color': '#2196F3', 'name': 'Blue', 'emoji': '💙'},
    {'color': '#FF9800', 'name': 'Orange', 'emoji': '🧡'},
    {'color': '#9C27B0', 'name': 'Purple', 'emoji': '💜'},
    {'color': '#F44336', 'name': 'Red', 'emoji': '❤️'},
    {'color': '#FF69B4', 'name': 'Pink', 'emoji': '💗'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      final authService = AuthService();
      final parentId = authProvider.currentUser?.id ?? '';
      
      final now = DateTime.now();
      final age = int.tryParse(_ageController.text) ?? 10;
      final birthDate = DateTime(now.year - age, now.month, now.day);
      
      // Use custom credentials or auto-generate
      final childName = _nameController.text.trim();
      String childEmail;
      String childPassword;
      
      if (_useCustomCredentials) {
        childEmail = _emailController.text.trim();
        childPassword = _passwordController.text.trim();
      } else {
        // Auto-generate simple credentials
        final firstName = childName.split(' ').first.toLowerCase();
        final randomNum = DateTime.now().millisecondsSinceEpoch % 100000;
        childEmail = '$firstName$randomNum@sparktracks.child';
        childPassword = '${firstName.substring(0, 1).toUpperCase()}${firstName.substring(1)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      }

      // Create Firebase user first
      final firebaseUser = await authService.register(
        childEmail,
        childPassword,
        childName,
        '',
        UserType.child,
      );

      if (firebaseUser != null) {
        // Create child profile
        final newChild = Student(
          id: 'child_${DateTime.now().millisecondsSinceEpoch}',
          userId: firebaseUser.id,
          parentId: parentId,
          name: childName,
          email: childEmail,
          dateOfBirth: birthDate,
          colorCode: _selectedColorCode,
          enrolledAt: DateTime.now(),
        );

        await childrenProvider.addChild(newChild);

        if (mounted) {
          // Show success with credentials
          await _showCredentialsDialog(childName, childEmail, childPassword);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showCredentialsDialog(String childName, String email, String password) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Child Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$childName can now login with:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text('Email:', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    email,
                    style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text('Password:', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    password,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 18, color: AppTheme.accentColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Save these credentials! They cannot be recovered.',
                      style: TextStyle(fontSize: 13, color: AppTheme.accentColor),
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
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.child_care, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Child',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Quick setup - just name & age!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Child\'s Name',
                      hintText: 'e.g., Emma Johnson',
                      prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppTheme.neutral100,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter child\'s name';
                      }
                      // Check for special characters (allow only letters, spaces, hyphens, apostrophes)
                      final specialCharRegex = RegExp(r"^[a-zA-Z\s\-']+$");
                      if (!specialCharRegex.hasMatch(value.trim())) {
                        return 'Name can only contain letters, spaces, hyphens, and apostrophes';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  
                  // Age Field
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      hintText: 'e.g., 10',
                      prefixIcon: const Icon(Icons.cake, color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppTheme.neutral100,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter age';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 3 || age > 18) {
                        return 'Age must be between 3 and 18';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Custom Credentials Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Set custom login credentials',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _useCustomCredentials 
                                    ? 'Choose email & password' 
                                    : 'Auto-generate (recommended)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _useCustomCredentials,
                          onChanged: (value) => setState(() => _useCustomCredentials = value),
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Custom Credentials Fields (if enabled)
                  if (_useCustomCredentials) ...[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppTheme.neutral100,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (_useCustomCredentials && (value == null || value.trim().isEmpty)) {
                          return 'Please enter an email';
                        }
                        if (_useCustomCredentials && !value!.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppTheme.neutral100,
                        helperText: 'At least 6 characters',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (_useCustomCredentials && (value == null || value.trim().isEmpty)) {
                          return 'Please enter a password';
                        }
                        if (_useCustomCredentials && value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Color Selection
                  const Text(
                    'Choose a color:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _quickColors.map((colorData) {
                      final color = colorData['color'] as String;
                      final emoji = colorData['emoji'] as String;
                      final isSelected = _selectedColorCode == color;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColorCode = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(int.parse('FF${color.substring(1)}', radix: 16)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(
                                    color: Color(int.parse('FF${color.substring(1)}', radix: 16)).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Info Box (only show if auto-generating)
                  if (!_useCustomCredentials)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.accentColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Login credentials will be auto-generated and shown after creation.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.accentColor.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _saveChild,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check, size: 20),
                                    SizedBox(width: 8),
                                    Text('Create Child', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


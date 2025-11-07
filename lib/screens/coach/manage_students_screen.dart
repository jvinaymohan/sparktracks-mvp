import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/classes_provider.dart';
import '../../models/student_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import 'dart:math';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  
  List<Student> _searchResults = [];
  bool _isSearching = false;
  bool _showCreateForm = false;
  
  // Create student form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _searchStudent(String email) async {
    if (email.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      final enrollmentProvider = Provider.of<EnrollmentProvider>(context, listen: false);
      final classesProvider = Provider.of<ClassesProvider>(context, listen: false);
      final currentCoachId = authProvider.currentUser?.id ?? '';
      
      // Get enrolled student IDs from this coach's classes (PRIVACY FILTER)
      final coachClassIds = classesProvider.classes
          .where((c) => c.coachId == currentCoachId)
          .map((c) => c.id)
          .toSet();
      final enrolledStudentIds = enrollmentProvider.enrollments
          .where((e) => coachClassIds.contains(e.classId))
          .map((e) => e.studentId)
          .toList();
      
      // PRIVACY: Only search students visible to this coach
      final visibleStudents = childrenProvider.getStudentsVisibleToCoach(
        currentCoachId,
        enrolledStudentIds,
      );
      
      final results = visibleStudents
          .where((child) => child.email.toLowerCase().contains(email.toLowerCase()))
          .toList();
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  Future<void> _createStudentAccount() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      final coachId = authProvider.currentUser?.id ?? '';

      // Generate unique student email if not provided
      final studentEmail = _emailController.text.trim();
      final studentPassword = _passwordController.text.trim();

      // Register user with Firebase
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : _nameController.text.trim();
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      final user = await _authService.register(
        studentEmail,
        studentPassword,
        firstName,
        lastName,
        UserType.child,
      );

      if (user == null) {
        throw Exception('Failed to create user account');
      }

      // Create student profile
      final student = Student(
        id: 'student_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        parentId: coachId, // Coach acts as temporary parent
        createdByCoachId: coachId, // PRIVACY: Track which coach created this student
        name: _nameController.text.trim(),
        email: studentEmail,
        dateOfBirth: DateTime.now().subtract(Duration(days: 365 * (int.tryParse(_ageController.text) ?? 10))),
        enrolledAt: DateTime.now(),
        colorCode: _generateRandomColor(),
      );

      childrenProvider.addChild(student);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Show credentials dialog
        _showCredentialsDialog(studentEmail, studentPassword);
        
        // Clear form
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _ageController.clear();
        setState(() {
          _showCreateForm = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating student: $e')),
        );
      }
    }
  }

  String _generateRandomColor() {
    final colors = ['#4CAF50', '#2196F3', '#FF9800', '#E91E63', '#9C27B0', '#00BCD4'];
    return colors[Random().nextInt(colors.length)];
  }

  Future<void> _showCredentialsDialog(String email, String password) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Student Account Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share these credentials with the student:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SelectableText(
              'Email: $email',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            SelectableText(
              'Password: $password',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Save these credentials! The student will need them to log in.',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Email: $email\nPassword: $password'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Credentials copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword(Student student) async {
    final newPassword = _generateRandomPassword();
    
    try {
      // In production, this would call Firebase Auth password reset
      // For now, show the new password
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Password Reset'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New password for ${student.name}:'),
              const SizedBox(height: 16),
              SelectableText(
                newPassword,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '⚠️ Share this with the student. They can change it after logging in.',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: newPassword));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied!')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset for ${student.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting password: $e')),
        );
      }
    }
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%';
    final random = Random.secure();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final coachId = authProvider.currentUser?.id ?? '';
    
    // Get students managed by this coach
    final myStudents = childrenProvider.children
        .where((child) => child.parentId == coachId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        actions: [
          IconButton(
            icon: Icon(_showCreateForm ? Icons.close : Icons.person_add),
            onPressed: () {
              setState(() {
                _showCreateForm = !_showCreateForm;
              });
            },
            tooltip: _showCreateForm ? 'Cancel' : 'Create Student',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Existing Student',
                      style: AppTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by email',
                        hintText: 'student@example.com',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                      });
                                    },
                                  )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppTheme.neutral100,
                      ),
                      onChanged: (value) {
                        if (value.length > 2) {
                          _searchStudent(value);
                        } else {
                          setState(() {
                            _searchResults = [];
                          });
                        }
                      },
                    ),
                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      const Divider(),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Found ${_searchResults.length} student(s):',
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      ..._searchResults.map((student) => _buildStudentSearchResultCard(student)),
                    ],
                    if (!_isSearching && _searchController.text.length > 2 && _searchResults.isEmpty) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Card(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.warningColor),
                              const SizedBox(width: AppTheme.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'No student found',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text('Create a new student account below'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Create Student Form
            if (_showCreateForm) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create New Student Account',
                            style: AppTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _showCreateForm = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Student Name *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.neutral100,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          hintText: 'student@example.com',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.neutral100,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          hintText: 'Minimum 8 characters',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                _passwordController.text = _generateRandomPassword();
                              });
                            },
                            tooltip: 'Generate Random Password',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.neutral100,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      
                      TextField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: 'Age',
                          prefixIcon: const Icon(Icons.cake),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.neutral100,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _createStudentAccount,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Student Account'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
            ],
            
            // My Students List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Students (${myStudents.length})',
                  style: AppTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                ),
                if (!_showCreateForm)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showCreateForm = true;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            if (myStudents.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: AppTheme.neutral400),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'No students yet',
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Search for existing students or create new accounts',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...myStudents.map((student) => _buildStudentCard(student)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSearchResultCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(int.parse(student.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
          child: Text(
            student.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.name),
        subtitle: Text(student.email),
        trailing: ElevatedButton(
          onPressed: () {
            // Add to my students / enroll in class
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added ${student.name} to your students')),
            );
          },
          child: const Text('Add'),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(int.parse(student.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
          child: Text(
            student.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.name),
        subtitle: Text(student.email),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reset_password',
              child: Row(
                children: [
                  Icon(Icons.lock_reset, size: 20),
                  SizedBox(width: 8),
                  Text('Reset Password'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'view_progress',
              child: Row(
                children: [
                  Icon(Icons.analytics, size: 20),
                  SizedBox(width: 8),
                  Text('View Progress'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assign_homework',
              child: Row(
                children: [
                  Icon(Icons.assignment, size: 20),
                  SizedBox(width: 8),
                  Text('Assign Homework'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'reset_password':
                _resetPassword(student);
                break;
              case 'view_progress':
                // Navigate to student progress view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View Progress feature coming soon!')),
                );
                break;
              case 'assign_homework':
                // Navigate to assign homework
                context.push('/create-task');
                break;
            }
          },
        ),
      ),
    );
  }
}


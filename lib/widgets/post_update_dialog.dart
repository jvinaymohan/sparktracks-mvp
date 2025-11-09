import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/update_model.dart';
import '../models/class_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

/// Dialog for coaches to post updates to specific class or all classes
class PostUpdateDialog extends StatefulWidget {
  const PostUpdateDialog({super.key});

  @override
  State<PostUpdateDialog> createState() => _PostUpdateDialogState();
}

class _PostUpdateDialogState extends State<PostUpdateDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  UpdateScope _scope = UpdateScope.allClasses;
  String? _selectedClassId;
  List<Class> _classes = [];
  bool _isUrgent = false;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coachId = authProvider.currentUser?.id ?? '';

    try {
      final classes = await FirestoreService().getClasses(coachId, userType: UserType.coach);
      if (mounted) {
        setState(() {
          _classes = classes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _postUpdate() async {
    if (_titleController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_scope == UpdateScope.specificClass && _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coachId = authProvider.currentUser?.id ?? '';
    final coachName = authProvider.currentUser?.name ?? 'Coach';

    try {
      // Get recipients (all enrolled students in class or all classes)
      List<String> recipientIds = [];
      String? className;

      if (_scope == UpdateScope.specificClass && _selectedClassId != null) {
        final classItem = _classes.firstWhere((c) => c.id == _selectedClassId);
        recipientIds = classItem.enrolledStudentIds;
        className = classItem.title;
      } else {
        // Get all enrolled students across all classes
        for (final classItem in _classes) {
          recipientIds.addAll(classItem.enrolledStudentIds);
        }
        recipientIds = recipientIds.toSet().toList(); // Remove duplicates
      }

      final updateId = FirebaseFirestore.instance.collection('updates').doc().id;
      
      final update = Update(
        id: updateId,
        coachId: coachId,
        coachName: coachName,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
        scope: _scope,
        classId: _scope == UpdateScope.specificClass ? _selectedClassId : null,
        className: className,
        recipientIds: recipientIds,
        isUrgent: _isUrgent,
      );

      await FirebaseFirestore.instance
          .collection('updates')
          .doc(updateId)
          .set(update.toJson());

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _scope == UpdateScope.allClasses
                        ? '✅ Update sent to all ${recipientIds.length} students!'
                        : '✅ Update sent to ${recipientIds.length} students in $className!',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Post Update'),
        ],
      ),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scope Selection
                    Text('Send To', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    SegmentedButton<UpdateScope>(
                      segments: const [
                        ButtonSegment(
                          value: UpdateScope.allClasses,
                          label: Text('All Classes'),
                          icon: Icon(Icons.groups),
                        ),
                        ButtonSegment(
                          value: UpdateScope.specificClass,
                          label: Text('Specific Class'),
                          icon: Icon(Icons.class_),
                        ),
                      ],
                      selected: {_scope},
                      onSelectionChanged: (Set<UpdateScope> newSelection) {
                        setState(() => _scope = newSelection.first);
                      },
                    ),
                    
                    // Class Selector (if specific class)
                    if (_scope == UpdateScope.specificClass) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        decoration: const InputDecoration(
                          labelText: 'Select Class',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.class_),
                        ),
                        items: _classes.map((classItem) {
                          return DropdownMenuItem(
                            value: classItem.id,
                            child: Text(classItem.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedClassId = value);
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Title
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Update Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      maxLength: 100,
                    ),
                    const SizedBox(height: 16),
                    
                    // Message
                    TextField(
                      controller: _messageController,
                      maxLines: 6,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        hintText: 'Write your update here...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Urgent Toggle
                    SwitchListTile(
                      value: _isUrgent,
                      onChanged: (value) => setState(() => _isUrgent = value),
                      title: const Text('Mark as Urgent'),
                      subtitle: const Text('Highlighted with red badge'),
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTheme.errorColor,
                    ),
                    
                    // Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _scope == UpdateScope.allClasses
                                  ? 'This update will be sent to all students enrolled in your classes'
                                  : 'This update will only be sent to students in the selected class',
                              style: AppTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _postUpdate,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send),
          label: Text(_isSubmitting ? 'Posting...' : 'Post Update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}


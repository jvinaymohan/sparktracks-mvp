import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

/// Quick booking dialog for fast class enrollment
/// Target: Complete booking in < 60 seconds
class QuickBookingDialog extends StatefulWidget {
  final Class classItem;
  final String coachName;

  const QuickBookingDialog({
    Key? key,
    required this.classItem,
    required this.coachName,
  }) : super(key: key);

  @override
  State<QuickBookingDialog> createState() => _QuickBookingDialogState();
}

class _QuickBookingDialogState extends State<QuickBookingDialog> {
  final _notesController = TextEditingController();
  
  String? _selectedChildId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isBooking = false;
  bool _showQuickAddChild = false;

  // Quick add child fields
  final _childNameController = TextEditingController();
  int _childAge = 8;

  @override
  void dispose() {
    _notesController.dispose();
    _childNameController.dispose();
    super.dispose();
  }

  Future<void> _quickAddChild() async {
    if (_childNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter child name'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final parentId = authProvider.currentUser?.id ?? '';

    final newChild = Student(
      id: 'student_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _childNameController.text.trim(),
      email: '${_childNameController.text.trim().toLowerCase().replaceAll(' ', '.')}@temp.com',
      dateOfBirth: DateTime.now().subtract(Duration(days: 365 * _childAge)),
      parentId: parentId,
      enrolledAt: DateTime.now(),
      colorCode: '#${(DateTime.now().millisecondsSinceEpoch % 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
    );

    try {
      await FirestoreService().addChild(newChild);
      
      // Refresh children list
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      await childrenProvider.loadChildren(parentId);

      setState(() {
        _selectedChildId = newChild.id;
        _showQuickAddChild = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${newChild.name} added!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding child: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a child'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      
      final child = childrenProvider.children.firstWhere((c) => c.id == _selectedChildId);
      
      // Create enrollment record (required for student roster)
      final enrollmentData = {
        'id': 'enrollment_${DateTime.now().millisecondsSinceEpoch}',
        'classId': widget.classItem.id,
        'studentId': child.id,
        'parentId': authProvider.currentUser?.id ?? '',
        'status': 'pending', // Coach needs to approve
        'amountPaid': 0.0,
        'amountDue': widget.classItem.price,
        'enrolledAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'notes': _notesController.text.trim(),
      };

      // Save enrollment to Firestore
      await FirestoreService().addDocument('enrollments', enrollmentData);

      // Also update the class's enrolledStudentIds (for roster)
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classItem.id)
          .update({
        'enrolledStudentIds': FieldValue.arrayUnion([child.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
        
        // Show success dialog
        _showBookingConfirmation(child.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking class: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  void _showBookingConfirmation(String childName) {
    final dateStr = _selectedDate != null
        ? DateFormat('EEEE, MMM d').format(_selectedDate!)
        : 'Next available session';
    
    final timeStr = _selectedTime != null
        ? _selectedTime!.format(context)
        : 'TBD';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Booking Confirmed!'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.classItem.title}',
              style: AppTheme.headline6,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.person, 'Student', childName),
            _buildDetailRow(Icons.school, 'Coach', widget.coachName),
            _buildDetailRow(Icons.calendar_today, 'Date', dateStr),
            _buildDetailRow(Icons.access_time, 'Time', timeStr),
            if (widget.classItem.location != null)
              _buildDetailRow(Icons.location_on, 'Location', widget.classItem.location!),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.successColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The coach will confirm your booking shortly!',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.successColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Add to calendar functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📅 Calendar feature coming soon!')),
              );
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('Add to Calendar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.neutral600),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    final children = childrenProvider.children;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Book Class'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.classItem.title,
                      style: AppTheme.headline6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'with ${widget.coachName}',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Select Child
              if (!_showQuickAddChild) ...[
                Text('Select Student', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                
                if (children.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.neutral300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.child_care, size: 40, color: AppTheme.neutral400),
                        const SizedBox(height: 8),
                        Text(
                          'No children added yet',
                          style: AppTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _showQuickAddChild = true);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Child'),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedChildId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.child_care),
                      border: OutlineInputBorder(),
                      hintText: 'Select a child',
                    ),
                    items: children.map((child) {
                      return DropdownMenuItem(
                        value: child.id,
                        child: Text(child.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedChildId = value);
                    },
                  ),
                
                if (children.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showQuickAddChild = true);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add another child'),
                  ),
                ],
              ],

              // Quick Add Child Form
              if (_showQuickAddChild) ...[
                Text('Quick Add Child', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: _childNameController,
                  decoration: const InputDecoration(
                    labelText: 'Child Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    hintText: 'Enter name',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Age:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _childAge.toDouble(),
                        min: 3,
                        max: 18,
                        divisions: 15,
                        label: '$_childAge years',
                        onChanged: (value) {
                          setState(() => _childAge = value.toInt());
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_childAge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showQuickAddChild = false;
                            _childNameController.clear();
                          });
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _quickAddChild,
                        icon: const Icon(Icons.check),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Preferred Date (Optional)
              Text('Preferred Date (optional)', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                    hintText: 'Select a date',
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('EEEE, MMMM d, y').format(_selectedDate!)
                        : 'Next available session',
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.black : AppTheme.neutral600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preferred Time (Optional)
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 15, minute: 0),
                  );
                  if (time != null) {
                    setState(() => _selectedTime = time);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                    hintText: 'Select a time',
                  ),
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Coach will suggest time',
                    style: TextStyle(
                      color: _selectedTime != null ? Colors.black : AppTheme.neutral600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Special Requests (optional)',
                  hintText: 'Any questions or special requirements?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isBooking ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isBooking ? null : _confirmBooking,
          icon: _isBooking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle),
          label: Text(_isBooking ? 'Booking...' : 'Confirm Booking'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}


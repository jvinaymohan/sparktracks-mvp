import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/children_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/class_model.dart';
import '../../models/enrollment_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/quick_booking_dialog.dart';
import '../../services/firestore_service.dart';

class ClassDetailScreen extends StatelessWidget {
  final Class classItem;
  
  const ClassDetailScreen({super.key, required this.classItem});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isParent = authProvider.currentUser?.type == UserType.parent;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Details'),
        actions: [
          if (classItem.shareableLink != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareClass(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Banner
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      classItem.locationType == LocationType.online
                          ? Icons.computer
                          : Icons.location_on,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                      child: Text(
                        classItem.title,
                        style: AppTheme.headline4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          classItem.isGroupClass ? Icons.groups : Icons.person,
                          size: 18,
                        ),
                        label: Text(classItem.isGroupClass ? 'Group Class' : '1-on-1'),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                      Chip(
                        avatar: const Icon(Icons.public, size: 18),
                        label: const Text('Public'),
                        backgroundColor: AppTheme.successColor.withOpacity(0.1),
                      ),
                      if (classItem.makeUpClassesAllowed)
                        Chip(
                          avatar: const Icon(Icons.event_repeat, size: 18),
                          label: const Text('Make-ups Allowed'),
                          backgroundColor: AppTheme.infoColor.withOpacity(0.1),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Description
                  Text('About this class', style: AppTheme.headline6),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    classItem.description,
                    style: AppTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Details
                  Text('Class Details', style: AppTheme.headline6),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  _buildDetailRow(
                    Icons.event,
                    'Schedule',
                    classItem.type.toString().split('.').last.toUpperCase(),
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    'Duration',
                    '${classItem.durationMinutes} minutes',
                  ),
                  _buildDetailRow(
                    classItem.locationType == LocationType.online ? Icons.computer : Icons.location_on,
                    'Location',
                    classItem.locationType == LocationType.online
                        ? 'Online (Link provided after enrollment)'
                        : (classItem.location ?? 'TBD'),
                  ),
                  _buildDetailRow(
                    Icons.people,
                    'Class Size',
                    classItem.isGroupClass
                        ? 'Up to ${classItem.maxStudents} students'
                        : 'One-on-one instruction',
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Pricing
                  Text('Pricing', style: AppTheme.headline6),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  Card(
                    color: AppTheme.successColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price',
                                style: AppTheme.bodyLarge,
                              ),
                              Text(
                                '${_getCurrencySymbol(classItem.currency)}${classItem.price.toStringAsFixed(2)}',
                                style: AppTheme.headline5.copyWith(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Schedule',
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                              ),
                              Text(
                                classItem.paymentSchedule.replaceAll('_', ' ').toUpperCase(),
                                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Enrollment status
                  Consumer<EnrollmentProvider>(
                    builder: (context, enrollmentProvider, _) {
                      final currentUserId = authProvider.currentUser?.id ?? '';
                      final childrenProvider = Provider.of<ChildrenProvider>(context);
                      final myChildren = childrenProvider.children.where((c) => c.parentId == currentUserId).toList();
                      
                      // Check if any children are enrolled
                      final enrolledChildren = myChildren.where((child) =>
                        enrollmentProvider.isEnrolled(child.userId, classItem.id)
                      ).toList();
                      
                      return Card(
                        color: enrolledChildren.isNotEmpty
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.infoColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          child: enrolledChildren.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: AppTheme.successColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Enrolled',
                                          style: AppTheme.headline6.copyWith(color: AppTheme.successColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.spacingS),
                                    ...enrolledChildren.map((child) => Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('• ${child.name}'),
                                    )),
                                  ],
                                )
                              : Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: AppTheme.infoColor),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text('Not enrolled yet'),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Enrollment buttons (for parents)
                  if (isParent) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showQuickBooking(context),
                            icon: const Icon(Icons.flash_on),
                            label: const Text('Quick Book'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                              backgroundColor: AppTheme.successColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showEnrollDialog(context),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Full Enroll'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '💡 Use "Quick Book" for fastest enrollment (60 seconds!)',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.neutral600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // For non-logged-in users
                  if (!authProvider.isLoggedIn)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Please sign in to enroll in classes'),
                                  action: SnackBarAction(
                                    label: 'Sign In',
                                    textColor: Colors.white,
                                    onPressed: () => context.go('/login'),
                                  ),
                                ),
                              );
                              context.go('/login');
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Sign In to Enroll'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a free account in 30 seconds!',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                ),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareClass(BuildContext context) {
    if (classItem.shareableLink != null) {
      Clipboard.setData(ClipboardData(text: classItem.shareableLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Enrollment link copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showEnrollDialog(BuildContext context) {
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context, listen: false);
    
    final currentParentId = authProvider.currentUser?.id ?? '';
    final myChildren = childrenProvider.children.where((c) => c.parentId == currentParentId).toList();
    
    if (myChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a child first before enrolling in classes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedChildId;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enroll in Class'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a child to enroll in "${classItem.title}"',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Child',
                      border: OutlineInputBorder(),
                    ),
                    items: myChildren.map((child) {
                      final isAlreadyEnrolled = enrollmentProvider.isEnrolled(child.userId, classItem.id);
                      return DropdownMenuItem(
                        value: child.userId,
                        enabled: !isAlreadyEnrolled,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(int.parse(child.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(child.name),
                            if (isAlreadyEnrolled) ...[
                              const SizedBox(width: 8),
                              const Text('(Already enrolled)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedChildId = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Pricing summary
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Price:'),
                            Text(
                              '${_getCurrencySymbol(classItem.currency)}${classItem.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Schedule:'),
                            Text(
                              classItem.paymentSchedule.replaceAll('_', ' '),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedChildId != null
                      ? () {
                          _enrollChild(context, selectedChildId!, enrollmentProvider, currentParentId);
                          Navigator.pop(dialogContext);
                        }
                      : null,
                  child: const Text('Enroll'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showQuickBooking(BuildContext context) async {
    // Get coach name
    String coachName = 'Coach';
    try {
      final coach = await FirestoreService().getUser(classItem.coachId);
      if (coach != null) {
        coachName = coach.name;
      }
    } catch (e) {
      // Use default if can't fetch
    }

    // Load children if not loaded
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final parentId = authProvider.currentUser?.id ?? '';
    
    if (childrenProvider.children.isEmpty) {
      await childrenProvider.loadChildren(parentId);
    }

    // Show quick booking dialog
    if (context.mounted) {
      final booked = await showDialog<bool>(
        context: context,
        builder: (context) => QuickBookingDialog(
          classItem: classItem,
          coachName: coachName,
        ),
      );

      if (booked == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Booking request sent to coach!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _enrollChild(BuildContext context, String childId, EnrollmentProvider enrollmentProvider, String parentId) {
    final enrollment = Enrollment(
      id: 'enroll_${DateTime.now().millisecondsSinceEpoch}',
      classId: classItem.id,
      studentId: childId,
      parentId: parentId,
      status: EnrollmentStatus.active,
      enrolledAt: DateTime.now(),
      amountDue: classItem.price,
      nextPaymentDate: _calculateNextPaymentDate(classItem.paymentSchedule),
    );
    
    enrollmentProvider.addEnrollment(enrollment);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Successfully enrolled in class!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  DateTime _calculateNextPaymentDate(String schedule) {
    final now = DateTime.now();
    switch (schedule) {
      case 'per_class':
        return now;
      case 'monthly':
        return DateTime(now.year, now.month + 1, now.day);
      case 'term':
        return DateTime(now.year, now.month + 3, now.day);
      default:
        return now;
    }
  }

  String _getCurrencySymbol(Currency currency) {
    switch (currency) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.gbp:
        return '£';
      case Currency.cad:
        return 'C\$';
      case Currency.aud:
        return 'A\$';
      case Currency.inr:
        return '₹';
    }
  }
}


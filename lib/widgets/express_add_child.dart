import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_model.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

/// Express child addition - just name and age!
/// Target: 20 seconds to add a child
class ExpressAddChild extends StatefulWidget {
  final bool autoNavigate;

  const ExpressAddChild({
    Key? key,
    this.autoNavigate = false,
  }) : super(key: key);

  @override
  State<ExpressAddChild> createState() => _ExpressAddChildState();
}

class _ExpressAddChildState extends State<ExpressAddChild> {
  final _nameController = TextEditingController();
  int _age = 8;
  bool _isAdding = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addChild() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final parentId = authProvider.currentUser?.id ?? '';

      final newChild = Student(
        id: 'student_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        email: '${_nameController.text.trim().toLowerCase().replaceAll(' ', '.')}@placeholder.com',
        dateOfBirth: DateTime.now().subtract(Duration(days: 365 * _age)),
        parentId: parentId,
        enrolledAt: DateTime.now(),
        colorCode: '#${(DateTime.now().millisecondsSinceEpoch % 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      );

      await FirestoreService().addChild(newChild);

      // Refresh children list
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      await childrenProvider.loadChildren(parentId);

      if (mounted) {
        Navigator.of(context).pop(newChild); // Return the created child
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('✅ ${newChild.name} added!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
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
            child: const Icon(Icons.child_care, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Add Child'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, size: 20, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quick Add! Just name and age. Add details later.',
                    style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Child Name',
              hintText: 'Enter name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _addChild(),
          ),
          const SizedBox(height: 20),
          
          // Age Slider
          Text('Age', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _age.toDouble(),
                  min: 3,
                  max: 18,
                  divisions: 15,
                  label: '$_age years',
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() => _age = value.toInt());
                  },
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_age',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            '💡 You can add more details (email, date of birth) later in settings.',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isAdding ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isAdding ? null : _addChild,
          icon: _isAdding
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.add),
          label: Text(_isAdding ? 'Adding...' : 'Add Child'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}


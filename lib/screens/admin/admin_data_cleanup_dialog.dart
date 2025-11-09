import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

/// Admin utility to clean test data and reset platform
class AdminDataCleanupDialog extends StatefulWidget {
  const AdminDataCleanupDialog({Key? key}) : super(key: key);

  @override
  State<AdminDataCleanupDialog> createState() => _AdminDataCleanupDialogState();
}

class _AdminDataCleanupDialogState extends State<AdminDataCleanupDialog> {
  bool _isDeleting = false;
  final Map<String, bool> _selections = {
    'users': false,
    'children': false,
    'tasks': false,
    'classes': false,
    'enrollments': false,
    'reviews': false,
    'updates': false,
    'attendance': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.delete_sweep, color: AppTheme.errorColor, size: 28),
          const SizedBox(width: 12),
          const Text('Clean Platform Data'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppTheme.errorColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This will PERMANENTLY delete selected data. This action cannot be undone!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select collections to clean:'),
            const SizedBox(height: 16),
            ..._selections.keys.map((key) => CheckboxListTile(
              title: Text(key.toUpperCase()),
              value: _selections[key],
              onChanged: (value) {
                setState(() {
                  _selections[key] = value ?? false;
                });
              },
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isDeleting || !_selections.values.contains(true)
              ? null
              : _cleanData,
          icon: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.delete_forever),
          label: Text(_isDeleting ? 'Deleting...' : 'Delete Selected'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Future<void> _cleanData() async {
    // Final confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ FINAL CONFIRMATION'),
        content: const Text(
          'Are you ABSOLUTELY SURE you want to delete this data?\n\n'
          'This will remove all selected information permanently and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('YES, DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final firestore = FirebaseFirestore.instance;
      int totalDeleted = 0;

      for (final collection in _selections.keys) {
        if (_selections[collection] == true) {
          print('🗑️ Cleaning collection: $collection');
          
          // Get all documents in collection
          final snapshot = await firestore.collection(collection).get();
          
          // Delete in batches
          final batch = firestore.batch();
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
            totalDeleted++;
          }
          
          await batch.commit();
          print('✅ Deleted ${snapshot.docs.length} documents from $collection');
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Deleted $totalDeleted items from ${_selections.values.where((v) => v).length} collections'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}


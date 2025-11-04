import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/children_provider.dart';

/// Development utilities for testing and debugging
class DevUtils {
  /// Clear all tasks from the app (for testing purposes)
  static void clearAllTasks(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    tasksProvider.clearAllTasks();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ All tasks cleared'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// Clear all children from the app (for testing purposes)
  static void clearAllChildren(BuildContext context) {
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    childrenProvider.clearAllChildren();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ All children cleared'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// Clear all data (tasks + children)
  static void clearAllData(BuildContext context) {
    clearAllTasks(context);
    clearAllChildren(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ All data cleared (tasks & children)'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  /// Show debug menu dialog
  static void showDebugMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔧 Development Tools'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Clear All Tasks'),
              onTap: () {
                Navigator.pop(context);
                clearAllTasks(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.orange),
              title: const Text('Clear All Children'),
              onTap: () {
                Navigator.pop(context);
                clearAllChildren(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Clear Everything'),
              subtitle: const Text('Tasks + Children'),
              onTap: () {
                Navigator.pop(context);
                clearAllData(context);
              },
            ),
          ],
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
}


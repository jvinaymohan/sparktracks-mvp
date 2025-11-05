import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TasksProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  
  // Load tasks from Firebase for a parent
  Future<void> loadTasksForParent(String parentId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final loadedTasks = await _firestoreService.getTasksForParent(parentId);
      _tasks.clear();
      _tasks.addAll(loadedTasks);
      
      print('✓ Loaded ${loadedTasks.length} tasks for parent $parentId');
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load tasks from Firebase for a child
  Future<void> loadTasksForChild(String childId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final loadedTasks = await _firestoreService.getTasksForChild(childId);
      _tasks.clear();
      _tasks.addAll(loadedTasks);
      
      print('✓ Loaded ${loadedTasks.length} tasks for child $childId');
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Clear all tasks (for testing/reset purposes)
  void clearAllTasks() {
    _tasks.clear();
    notifyListeners();
  }

  List<Task> getTasksForChild(String childId) {
    return _tasks.where((task) => task.childId == childId).toList();
  }

  List<Task> getTasksForParent(String parentId) {
    return _tasks.where((task) => task.parentId == parentId).toList();
  }

  Future<void> addTask(Task task) async {
    try {
      // Save to Firebase first
      await _firestoreService.addTask(task);
      
      // Then add to local
      _tasks.add(task);
      notifyListeners();
      
      print('✓ Task added to Firebase and local state');
    } catch (e) {
      print('Error adding task: $e');
      throw e;
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    try {
      // Update in Firebase first
      await _firestoreService.updateTask(updatedTask);
      
      // Then update local
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
      
      print('✓ Task updated in Firebase and local state');
    } catch (e) {
      print('Error updating task: $e');
      throw e;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      // Delete from Firebase first
      await _firestoreService.deleteTask(taskId);
      
      // Then remove from local
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      
      print('✓ Task deleted from Firebase and local state');
    } catch (e) {
      print('Error deleting task: $e');
      throw e;
    }
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> completeTask(String taskId, {String? notes, List<String>? imageUrls}) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final updatedTask = _tasks[index].copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        completionNotes: notes,
        imageUrls: imageUrls ?? _tasks[index].imageUrls,
        updatedAt: DateTime.now(),
      );
      
      // Save to Firebase
      await updateTask(updatedTask);
    }
  }

  Future<void> approveTask(String taskId, {String? notes}) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final updatedTask = _tasks[index].copyWith(
        status: TaskStatus.approved,
        approvedAt: DateTime.now(),
        approvalNotes: notes,
        updatedAt: DateTime.now(),
      );
      
      // Save to Firebase
      await updateTask(updatedTask);
    }
  }

  Future<void> rejectTask(String taskId, {String? notes}) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final updatedTask = _tasks[index].copyWith(
        status: TaskStatus.rejected,
        approvalNotes: notes,
        updatedAt: DateTime.now(),
      );
      
      // Save to Firebase
      await updateTask(updatedTask);
    }
  }
}


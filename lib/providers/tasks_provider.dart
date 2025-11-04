import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TasksProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;
  
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

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  void completeTask(String taskId, {String? notes, List<String>? imageUrls}) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        completionNotes: notes,
        imageUrls: imageUrls ?? _tasks[index].imageUrls,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void approveTask(String taskId, {String? notes}) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: TaskStatus.approved,
        approvedAt: DateTime.now(),
        approvalNotes: notes,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void rejectTask(String taskId, {String? notes}) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: TaskStatus.rejected,
        approvalNotes: notes,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}


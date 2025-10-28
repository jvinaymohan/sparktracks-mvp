import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TasksProvider with ChangeNotifier {
  final List<Task> _tasks = [
    // Mock initial tasks
    Task(
      id: 'task1',
      title: 'Complete Math Homework',
      description: 'Finish pages 45-47 in the workbook',
      parentId: 'parent1',
      childId: 'child1',
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 1)),
      rewardAmount: 500,
      category: 'Education',
      tags: ['homework', 'math'],
    ),
    Task(
      id: 'task2',
      title: 'Clean Your Room',
      description: 'Make bed, organize toys, vacuum floor',
      parentId: 'parent1',
      childId: 'child1',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      dueDate: DateTime.now(),
      rewardAmount: 300,
      category: 'Chores',
      tags: ['cleaning'],
    ),
    Task(
      id: 'task3',
      title: 'Practice Piano',
      description: 'Practice scales and the new song for 30 minutes',
      parentId: 'parent1',
      childId: 'child2',
      status: TaskStatus.completed,
      priority: TaskPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      rewardAmount: 400,
      category: 'Music',
      tags: ['practice', 'piano'],
    ),
  ];

  List<Task> get tasks => _tasks;

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


import 'package:flutter_test/flutter_test.dart';
import 'package:sparktracks_mvp/models/task_model.dart';

void main() {
  group('Task Model Tests', () {
    test('Task should be created with required fields', () {
      final task = Task(
        id: 'task123',
        title: 'Complete homework',
        description: 'Math worksheet pages 10-12',
        assignedTo: 'child123',
        assignedBy: 'parent123',
        dueDate: DateTime(2025, 12, 31),
        status: TaskStatus.pending,
        points: 10,
        createdAt: DateTime.now(),
      );

      expect(task.id, 'task123');
      expect(task.title, 'Complete homework');
      expect(task.status, TaskStatus.pending);
      expect(task.points, 10);
    });

    test('Task status transitions should work correctly', () {
      final task = Task(
        id: 'task123',
        title: 'Test Task',
        description: 'Description',
        assignedTo: 'child123',
        assignedBy: 'parent123',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.pending,
        points: 5,
        createdAt: DateTime.now(),
      );

      expect(task.status, TaskStatus.pending);

      final inProgressTask = task.copyWith(status: TaskStatus.inProgress);
      expect(inProgressTask.status, TaskStatus.inProgress);

      final completedTask = inProgressTask.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      expect(completedTask.status, TaskStatus.completed);
      expect(completedTask.completedAt, isNotNull);
    });

    test('Task should track approval status', () {
      final task = Task(
        id: 'task123',
        title: 'Test Task',
        description: 'Description',
        assignedTo: 'child123',
        assignedBy: 'parent123',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.completed,
        points: 5,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        approvedBy: 'parent123',
        approvedAt: DateTime.now(),
      );

      expect(task.status, TaskStatus.completed);
      expect(task.approvedBy, 'parent123');
      expect(task.approvedAt, isNotNull);
    });

    test('Task recurrence should be tracked', () {
      final task = Task(
        id: 'task123',
        title: 'Daily Task',
        description: 'Repeat every day',
        assignedTo: 'child123',
        assignedBy: 'parent123',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.pending,
        points: 5,
        createdAt: DateTime.now(),
        isRecurring: true,
        recurrencePattern: 'daily',
      );

      expect(task.isRecurring, true);
      expect(task.recurrencePattern, 'daily');
    });

    test('Task category should be set correctly', () {
      final task = Task(
        id: 'task123',
        title: 'Homework',
        description: 'Math homework',
        assignedTo: 'child123',
        assignedBy: 'parent123',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.pending,
        points: 10,
        createdAt: DateTime.now(),
        category: 'homework',
      );

      expect(task.category, 'homework');
    });

    test('Task toJson and fromJson should work correctly', () {
      final task = Task(
        id: 'task123',
        title: 'Test Task',
        description: 'Description',
        assignedTo: 'child123',
        assignedBy: 'parent123',
        dueDate: DateTime(2025, 12, 31),
        status: TaskStatus.pending,
        points: 10,
        createdAt: DateTime.now(),
      );

      final json = task.toJson();
      final taskFromJson = Task.fromJson(json);

      expect(taskFromJson.id, task.id);
      expect(taskFromJson.title, task.title);
      expect(taskFromJson.status, task.status);
      expect(taskFromJson.points, task.points);
    });

    test('Task should handle null optional fields', () {
      final task = Task(
        id: 'task123',
        title: 'Simple Task',
        description: 'No extras',
        assignedTo: 'child123',
        assignedBy: 'parent123',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.pending,
        points: 5,
        createdAt: DateTime.now(),
      );

      expect(task.completedAt, isNull);
      expect(task.approvedBy, isNull);
      expect(task.approvedAt, isNull);
      expect(task.category, isNull);
    });

    test('Task points should be positive', () {
      final task = Task(
        id: 'task123',
        title: 'Points Task',
        description: 'Should have positive points',
        assignedTo: 'child123',
        assignedBy: 'parent123',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.pending,
        points: 15,
        createdAt: DateTime.now(),
      );

      expect(task.points, greaterThan(0));
    });
  });
}


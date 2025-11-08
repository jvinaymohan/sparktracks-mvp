import 'package:flutter_test/flutter_test.dart';
import 'package:sparktracks_mvp/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    test('User model should be created with all required fields', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        type: UserType.parent,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        preferences: {},
      );

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.type, UserType.parent);
      expect(user.createdAt.year, 2025);
    });

    test('User toJson and fromJson should work correctly', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        type: UserType.parent,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        preferences: {'theme': 'dark'},
      );

      final json = user.toJson();
      final userFromJson = User.fromJson(json);

      expect(userFromJson.id, user.id);
      expect(userFromJson.email, user.email);
      expect(userFromJson.name, user.name);
      expect(userFromJson.type, user.type);
      expect(userFromJson.preferences['theme'], 'dark');
    });

    test('User type should be correctly identified', () {
      final parent = User(
        id: '1',
        email: 'parent@test.com',
        name: 'Parent',
        type: UserType.parent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: {},
      );

      final child = User(
        id: '2',
        email: 'child@test.com',
        name: 'Child',
        type: UserType.child,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: {},
      );

      final coach = User(
        id: '3',
        email: 'coach@test.com',
        name: 'Coach',
        type: UserType.coach,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: {},
      );

      expect(parent.type, UserType.parent);
      expect(child.type, UserType.child);
      expect(coach.type, UserType.coach);
    });

    test('User preferences should be mutable', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        type: UserType.parent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: {},
      );

      user.preferences['theme'] = 'dark';
      user.preferences['notifications'] = true;

      expect(user.preferences['theme'], 'dark');
      expect(user.preferences['notifications'], true);
    });

    test('User copyWith should create new instance with updated fields', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        type: UserType.parent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: {},
      );

      final updatedUser = user.copyWith(name: 'Updated Name');

      expect(updatedUser.id, user.id);
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.email, user.email);
    });

    test('Empty preferences should be valid', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        type: UserType.parent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: {},
      );

      expect(user.preferences, isEmpty);
    });
  });
}


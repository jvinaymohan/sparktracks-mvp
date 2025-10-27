import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'https://api.sparktracks.com'; // Replace with actual API URL
  
  // Mock authentication methods for now
  Future<User?> login(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Default credentials for testing
      if (email == 'parent@sparktracks.com' && password == 'parent123') {
        return User(
          id: 'parent1',
          email: email,
          name: 'John Parent',
          type: UserType.parent,
          emailVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          notificationPreferences: NotificationPreferences(),
          paymentProfile: PaymentProfile(),
        );
      } else if (email == 'child@sparktracks.com' && password == 'child123') {
        return User(
          id: 'child1',
          email: email,
          name: 'Emma Johnson',
          type: UserType.child,
          emailVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          notificationPreferences: NotificationPreferences(),
          paymentProfile: PaymentProfile(),
        );
      } else if (email == 'coach@sparktracks.com' && password == 'coach123') {
        return User(
          id: 'coach1',
          email: email,
          name: 'Coach Smith',
          type: UserType.coach,
          emailVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          notificationPreferences: NotificationPreferences(),
          paymentProfile: PaymentProfile(),
        );
      }
      
      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  Future<User?> register(String email, String password, String firstName, String lastName, UserType userType) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock successful registration
      return User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: '$firstName $lastName',
        type: userType,
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notificationPreferences: NotificationPreferences(),
        paymentProfile: PaymentProfile(),
      );
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  Future<void> logout() async {
    // Clear any stored tokens or user data
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  Future<User?> getCurrentUser() async {
    // Check if user is logged in (mock implementation)
    await Future.delayed(const Duration(milliseconds: 500));
    return null; // Return null to simulate no logged-in user
  }
  
  Future<void> sendEmailVerification(String email) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }
  
  Future<bool> verifyEmail(String token) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return true; // Mock successful verification
    } catch (e) {
      throw Exception('Email verification failed: $e');
    }
  }
  
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
}

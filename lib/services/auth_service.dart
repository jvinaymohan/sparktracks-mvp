import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Register a new user with email and password
  Future<User?> register(String email, String password, String firstName, String lastName, UserType userType) async {
    try {
      // Create Firebase user
      final firebase_auth.UserCredential userCredential = 
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user');
      }
      
      // Send email verification
      await firebaseUser.sendEmailVerification();
      
      // Create user document in Firestore
      final user = User(
        id: firebaseUser.uid,
        email: email,
        name: '$firstName $lastName',
        type: userType,
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notificationPreferences: NotificationPreferences(),
        paymentProfile: PaymentProfile(),
      );
      
      // Convert to JSON and ensure nested objects are properly serialized
      final userData = user.toJson();
      await _firestore.collection('users').doc(user.id).set(userData);
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak.');
        case 'email-already-in-use':
          throw Exception('An account already exists for this email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  /// Login with email and password
  Future<User?> login(String email, String password) async {
    try {
      final firebase_auth.UserCredential userCredential = 
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed');
      }
      
      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (!userDoc.exists) {
        // User exists in Firebase Auth but not in Firestore
        // This can happen if registration was partially completed
        throw Exception('User profile not found. Please contact support.');
      }
      
      final userData = userDoc.data()!;
      
      // Ensure dates are properly parsed - handle both Timestamp and String formats
      String parseDate(dynamic dateValue) {
        if (dateValue == null) return DateTime.now().toIso8601String();
        if (dateValue is Timestamp) return dateValue.toDate().toIso8601String();
        if (dateValue is String) return dateValue;
        return DateTime.now().toIso8601String();
      }
      
      final user = User.fromJson({
        ...userData,
        'emailVerified': firebaseUser.emailVerified,
        'createdAt': parseDate(userData['createdAt']),
        'updatedAt': parseDate(userData['updatedAt']),
      });
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Incorrect password.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many login attempts. Please try again later.');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  /// Logout current user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
  
  /// Get current logged-in user
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser == null) {
        return null;
      }
      
      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (!userDoc.exists) {
        return null;
      }
      
      final userData = userDoc.data()!;
      
      // Ensure dates are properly parsed - handle both Timestamp and String formats
      String parseDate(dynamic dateValue) {
        if (dateValue == null) return DateTime.now().toIso8601String();
        if (dateValue is Timestamp) return dateValue.toDate().toIso8601String();
        if (dateValue is String) return dateValue;
        return DateTime.now().toIso8601String();
      }
      
      final user = User.fromJson({
        ...userData,
        'emailVerified': firebaseUser.emailVerified,
        'createdAt': parseDate(userData['createdAt']),
        'updatedAt': parseDate(userData['updatedAt']),
      });
      
      return user;
    } catch (e) {
      return null;
    }
  }
  
  /// Send email verification to current user
  Future<void> sendEmailVerification(String email) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser == null) {
        throw Exception('No user is currently logged in');
      }
      
      await firebaseUser.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'too-many-requests':
          throw Exception('Too many requests. Please try again later.');
        default:
          throw Exception('Failed to send verification email: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }
  
  /// Verify email (reload user to check verification status)
  Future<bool> verifyEmail(String token) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser == null) {
        return false;
      }
      
      // Reload user to get latest email verification status
      await firebaseUser.reload();
      final updatedUser = _firebaseAuth.currentUser;
      
      if (updatedUser != null && updatedUser.emailVerified) {
        // Update Firestore
        await _firestore.collection('users').doc(updatedUser.uid).update({
          'emailVerified': true,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        return true;
      }
      
      return false;
    } catch (e) {
      throw Exception('Email verification check failed: $e');
    }
  }
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'too-many-requests':
          throw Exception('Too many requests. Please try again later.');
        default:
          throw Exception('Failed to send password reset email: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
  
  /// Check if user email is verified
  Future<bool> isEmailVerified() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return false;
      }
      
      await firebaseUser.reload();
      return _firebaseAuth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Create a child account (called by parent)
  /// Note: This will create the child in Firebase but won't sign them in
  Future<Map<String, String>> createChildAccount({
    required String email,
    required String password,
    required String childName,
    required String parentId,
    required DateTime dateOfBirth,
  }) async {
    try {
      print('Creating child account: $email');
      
      // Create Firebase account for child
      final firebase_auth.UserCredential userCredential = 
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create child account');
      }
      
      print('Child Firebase user created: ${firebaseUser.uid}');
      
      // Create user document in Firestore
      final childUser = User(
        id: firebaseUser.uid,
        email: email,
        name: childName,
        type: UserType.child,
        parentId: parentId,
        emailVerified: true, // Children don't need to verify email
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notificationPreferences: NotificationPreferences(),
        paymentProfile: PaymentProfile(),
      );
      
      // Save to Firestore users collection
      final userData = childUser.toJson();
      await _firestore.collection('users').doc(childUser.id).set(userData);
      
      print('Child user document created in Firestore');
      
      // CRITICAL FIX: DO NOT SIGN OUT YET!
      // The calling code needs to create the children collection document
      // while still authenticated. We'll return the auth context as-is.
      print('⚠️ Child still signed in - caller must handle signout and parent re-auth');
      
      return {
        'userId': firebaseUser.uid,
        'email': email,
        'password': password,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase error creating child: ${e.code} - ${e.message}');
      await _firebaseAuth.signOut(); // Make sure we're signed out
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak.');
        case 'email-already-in-use':
          throw Exception('This email is already in use.');
        default:
          throw Exception('Failed to create child account: ${e.message}');
      }
    } catch (e) {
      print('Error creating child: $e');
      await _firebaseAuth.signOut();
      throw Exception('Failed to create child account: $e');
    }
  }
}

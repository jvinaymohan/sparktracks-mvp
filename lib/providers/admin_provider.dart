import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firebase_firestore;
import '../models/admin_user_model.dart';
import '../models/user_model.dart';

class AdminProvider with ChangeNotifier {
  AdminUser? _currentAdmin;
  final List<BetaSignupRequest> _betaSignups = [];
  final List<User> _allUsers = [];
  SystemSettings? _systemSettings;
  
  AdminUser? get currentAdmin => _currentAdmin;
  List<BetaSignupRequest> get betaSignups => _betaSignups;
  List<User> get allUsers => _allUsers;
  SystemSettings? get systemSettings => _systemSettings;

  // Initialize with mock data
  AdminProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _systemSettings = SystemSettings(
      id: 'settings_1',
      maintenanceMode: false,
      allowNewRegistrations: true,
      requireEmailVerification: false,
      maxChildrenPerParent: 10,
      maxClassesPerCoach: 50,
      featureFlags: {
        'messaging_enabled': true,
        'achievements_enabled': true,
        'analytics_enabled': true,
        'video_classes_enabled': true,
      },
      updatedAt: DateTime.now(),
      updatedBy: 'admin',
    );
  }

  // Admin authentication
  Future<bool> loginAdmin(String email, String password) async {
    // Check hardcoded admin credentials
    if (email == 'admin@sparktracks.com' && password == 'ChangeThisPassword2024!') {
      try {
        // Try to authenticate with Firebase
        final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✓ Admin authenticated with Firebase');
        
        // Check if user document exists, if not create it
        final firestore = firebase_firestore.FirebaseFirestore.instance;
        final userDoc = await firestore.collection('users').doc(userCredential.user!.uid).get();
        
        if (!userDoc.exists) {
          // Create admin user document
          await firestore.collection('users').doc(userCredential.user!.uid).set({
            'id': userCredential.user!.uid,
            'email': email,
            'name': 'Super Admin',
            'type': 'admin',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'preferences': {},
          });
          print('✓ Admin user document created');
        }
      } catch (e) {
        print('⚠️ Firebase auth failed: $e');
        // If user doesn't exist, provide helpful error
        if (e.toString().contains('user-not-found')) {
          print('ℹ️ Admin user not found. Creating via registration...');
          try {
            final userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            
            // Create admin user document
            final firestore = firebase_firestore.FirebaseFirestore.instance;
            await firestore.collection('users').doc(userCredential.user!.uid).set({
              'id': userCredential.user!.uid,
              'email': email,
              'name': 'Super Admin',
              'type': 'admin',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
              'preferences': {},
            });
            print('✓ Admin user created and authenticated');
          } catch (createError) {
            print('⚠️ Failed to create admin user: $createError');
            return false;
          }
        } else {
          return false;
        }
      }
      
      _currentAdmin = AdminUser(
        id: 'admin_1',
        email: email,
        name: 'Super Admin',
        role: AdminRole.superAdmin,
        permissions: ['all'],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void logoutAdmin() {
    _currentAdmin = null;
    notifyListeners();
  }

  // Beta signup management
  void addBetaSignup(BetaSignupRequest request) {
    _betaSignups.add(request);
    notifyListeners();
  }

  List<BetaSignupRequest> getPendingSignups() {
    return _betaSignups.where((s) => s.status == 'pending').toList();
  }

  void approveBetaSignup(String id, String adminId, {String? notes}) {
    final index = _betaSignups.indexWhere((s) => s.id == id);
    if (index != -1) {
      _betaSignups[index] = _betaSignups[index].copyWith(
        status: 'approved',
        processedAt: DateTime.now(),
        processedBy: adminId,
        notes: notes,
      );
      notifyListeners();
    }
  }

  void rejectBetaSignup(String id, String adminId, {String? notes}) {
    final index = _betaSignups.indexWhere((s) => s.id == id);
    if (index != -1) {
      _betaSignups[index] = _betaSignups[index].copyWith(
        status: 'rejected',
        processedAt: DateTime.now(),
        processedBy: adminId,
        notes: notes,
      );
      notifyListeners();
    }
  }

  // User management
  void loadAllUsers(List<User> users) {
    _allUsers.clear();
    _allUsers.addAll(users);
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    final index = _allUsers.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _allUsers[index] = updatedUser;
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _allUsers.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  List<User> getUsersByType(UserType type) {
    return _allUsers.where((u) => u.type == type).toList();
  }

  // System settings
  void updateSystemSettings(SystemSettings settings) {
    _systemSettings = settings;
    notifyListeners();
  }

  void toggleMaintenanceMode(bool enabled, String? message) {
    if (_systemSettings != null) {
      _systemSettings = SystemSettings(
        id: _systemSettings!.id,
        maintenanceMode: enabled,
        maintenanceMessage: message,
        allowNewRegistrations: _systemSettings!.allowNewRegistrations,
        requireEmailVerification: _systemSettings!.requireEmailVerification,
        maxChildrenPerParent: _systemSettings!.maxChildrenPerParent,
        maxClassesPerCoach: _systemSettings!.maxClassesPerCoach,
        featureFlags: _systemSettings!.featureFlags,
        updatedAt: DateTime.now(),
        updatedBy: _currentAdmin?.id ?? 'system',
      );
      notifyListeners();
    }
  }

  void updateFeatureFlag(String feature, bool enabled) {
    if (_systemSettings != null) {
      final newFlags = Map<String, bool>.from(_systemSettings!.featureFlags);
      newFlags[feature] = enabled;
      
      _systemSettings = SystemSettings(
        id: _systemSettings!.id,
        maintenanceMode: _systemSettings!.maintenanceMode,
        maintenanceMessage: _systemSettings!.maintenanceMessage,
        allowNewRegistrations: _systemSettings!.allowNewRegistrations,
        requireEmailVerification: _systemSettings!.requireEmailVerification,
        maxChildrenPerParent: _systemSettings!.maxChildrenPerParent,
        maxClassesPerCoach: _systemSettings!.maxClassesPerCoach,
        featureFlags: newFlags,
        updatedAt: DateTime.now(),
        updatedBy: _currentAdmin?.id ?? 'system',
      );
      notifyListeners();
    }
  }

  // Statistics
  Map<String, int> getUserStatistics() {
    return {
      'total': _allUsers.length,
      'parents': getUsersByType(UserType.parent).length,
      'children': getUsersByType(UserType.child).length,
      'coaches': getUsersByType(UserType.coach).length,
      'beta_pending': getPendingSignups().length,
      'beta_approved': _betaSignups.where((s) => s.status == 'approved').length,
    };
  }
}


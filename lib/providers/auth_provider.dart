import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnboarding => _currentUser != null && !_currentUser!.emailVerified;
  
  void completeOnboarding() {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(emailVerified: true);
      notifyListeners();
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  Future<void> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      } else {
        _setError('Invalid email or password');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> register(String email, String password, String firstName, String lastName, UserType userType) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final user = await _authService.register(email, password, firstName, lastName, userType);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      } else {
        _setError('Registration failed');
      }
    } catch (e) {
      // Clean up the error message for better display
      String errorMessage = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('firebase_auth/', '');
      _setError(errorMessage);
      print('Registration error: $e'); // Debug log
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
      _currentUser = null;
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> sendEmailVerification() async {
    if (_currentUser == null) return;
    
    try {
      _setLoading(true);
      await _authService.sendEmailVerification(_currentUser!.email);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> verifyEmail(String token) async {
    try {
      _setLoading(true);
      final success = await _authService.verifyEmail(token);
      if (success && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(emailVerified: true);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}

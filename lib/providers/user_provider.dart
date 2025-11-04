import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  final List<User> _usersCache = [];
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
  
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
  
  Future<void> updateUser(User updatedUser) async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    if (_currentUser == null) return;
    
    try {
      _setLoading(true);
      _setError(null);
      
      final updatedUser = _currentUser!.copyWith(
        name: firstName != null && lastName != null 
            ? '$firstName $lastName' 
            : _currentUser!.name,
        email: email ?? _currentUser!.email,
        phone: phone ?? _currentUser!.phone,
        updatedAt: DateTime.now(),
      );
      
      await updateUser(updatedUser);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateNotificationPreferences(NotificationPreferences preferences) async {
    if (_currentUser == null) return;
    
    try {
      _setLoading(true);
      _setError(null);
      
      final updatedUser = _currentUser!.copyWith(
        notificationPreferences: preferences,
        updatedAt: DateTime.now(),
      );
      
      await updateUser(updatedUser);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Get user by ID
  User? getUserById(String userId) {
    try {
      return _usersCache.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../services/supermemory_service.dart';

/// Provider for managing Supermemory AI integration
/// 
/// Usage:
/// ```dart
/// final supermemoryProvider = Provider.of<SupermemoryProvider>(context);
/// await supermemoryProvider.search('What do you know about me?');
/// ```
class SupermemoryProvider with ChangeNotifier {
  final SupermemoryService _service;
  
  List<SupermemoryItem> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  SupermemoryProvider({
    required String apiKey,
    String baseUrl = 'https://api.supermemory.ai',
  }) : _service = SupermemoryService(
          apiKey: apiKey,
          baseUrl: baseUrl,
        );

  List<SupermemoryItem> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Search the memory
  Future<List<SupermemoryItem>> search(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.search(query);
      _searchResults = result.results;
      _isLoading = false;
      notifyListeners();
      return result.results;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  /// Add memory about user activity
  Future<void> addMemory({
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _service.addMemory(
        content: content,
        metadata: metadata,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get AI insights
  Future<String?> getInsights(String prompt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final insight = await _service.getInsights(prompt);
      _isLoading = false;
      notifyListeners();
      return insight;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Clear search results
  void clearResults() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}


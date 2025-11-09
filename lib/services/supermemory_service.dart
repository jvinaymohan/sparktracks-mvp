import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for integrating with Supermemory AI
/// Supermemory provides AI-powered memory and knowledge management
class SupermemoryService {
  final String apiKey;
  final String baseUrl;

  SupermemoryService({
    required this.apiKey,
    this.baseUrl = 'https://api.supermemory.ai',
  });

  /// Search the memory for information
  /// 
  /// Example:
  /// ```dart
  /// final results = await supermemory.search('What do you know about me?');
  /// ```
  Future<SupermemorySearchResult> search(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'q': query,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SupermemorySearchResult.fromJson(data);
      } else {
        throw SupermemoryException(
          'Search failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw SupermemoryException('Search error: $e');
    }
  }

  /// Add information to memory
  /// 
  /// Example:
  /// ```dart
  /// await supermemory.addMemory(
  ///   content: 'User prefers chess classes on weekends',
  ///   metadata: {'user_id': 'user123', 'type': 'preference'},
  /// );
  /// ```
  Future<void> addMemory({
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/memory'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'content': content,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw SupermemoryException(
          'Add memory failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw SupermemoryException('Add memory error: $e');
    }
  }

  /// Get AI-generated insights based on the memory
  /// 
  /// Example:
  /// ```dart
  /// final insights = await supermemory.getInsights('What classes should I recommend?');
  /// ```
  Future<String> getInsights(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/insights'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['insight'] ?? '';
      } else {
        throw SupermemoryException(
          'Get insights failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw SupermemoryException('Get insights error: $e');
    }
  }

  /// Delete a memory by ID
  Future<void> deleteMemory(String memoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/memory/$memoryId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw SupermemoryException(
          'Delete memory failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw SupermemoryException('Delete memory error: $e');
    }
  }
}

/// Result from a Supermemory search
class SupermemorySearchResult {
  final List<SupermemoryItem> results;
  final int totalResults;

  SupermemorySearchResult({
    required this.results,
    required this.totalResults,
  });

  factory SupermemorySearchResult.fromJson(Map<String, dynamic> json) {
    final resultsJson = json['results'] as List<dynamic>? ?? [];
    return SupermemorySearchResult(
      results: resultsJson.map((item) => SupermemoryItem.fromJson(item)).toList(),
      totalResults: json['total'] ?? resultsJson.length,
    );
  }
}

/// Individual memory item
class SupermemoryItem {
  final String id;
  final String content;
  final double score;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  SupermemoryItem({
    required this.id,
    required this.content,
    required this.score,
    required this.metadata,
    this.createdAt,
  });

  factory SupermemoryItem.fromJson(Map<String, dynamic> json) {
    return SupermemoryItem(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      metadata: json['metadata'] ?? {},
      createdAt: json['created_at'] != null 
        ? DateTime.tryParse(json['created_at'])
        : null,
    );
  }
}

/// Exception thrown by Supermemory service
class SupermemoryException implements Exception {
  final String message;

  SupermemoryException(this.message);

  @override
  String toString() => 'SupermemoryException: $message';
}


import 'dart:collection';
import 'package:flutter/foundation.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Queue<String> _cacheKeys = Queue();

  static const int maxCacheSize = 1000;
  static const Duration defaultCacheDuration = Duration(minutes: 30);

  // Set cache with expiration
  void set(String key, dynamic value, {Duration? duration}) {
    // Remove oldest if cache is full
    if (_cache.length >= maxCacheSize) {
      final oldestKey = _cacheKeys.removeFirst();
      _cache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }

    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
    _cacheKeys.add(key);

    if (kDebugMode) {
      print('💾 Cached: $key');
    }
  }

  // Get from cache
  T? get<T>(String key, {Duration? maxAge}) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) {
      return null;
    }

    final age = DateTime.now().difference(timestamp);
    final maxAllowedAge = maxAge ?? defaultCacheDuration;

    if (age > maxAllowedAge) {
      // Cache expired
      remove(key);
      return null;
    }

    return _cache[key] as T?;
  }

  // Remove from cache
  void remove(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    _cacheKeys.remove(key);

    if (kDebugMode) {
      print('🗑️ Removed from cache: $key');
    }
  }

  // Clear all cache
  void clear() {
    _cache.clear();
    _cacheTimestamps.clear();
    _cacheKeys.clear();

    if (kDebugMode) {
      print('🗑️ Cache cleared');
    }
  }

  // Clear expired items
  void clearExpired({Duration? maxAge}) {
    final expiredKeys = <String>[];
    final maxAllowedAge = maxAge ?? defaultCacheDuration;

    _cacheTimestamps.forEach((key, timestamp) {
      final age = DateTime.now().difference(timestamp);
      if (age > maxAllowedAge) {
        expiredKeys.add(key);
      }
    });

    for (var key in expiredKeys) {
      remove(key);
    }

    if (kDebugMode && expiredKeys.isNotEmpty) {
      print('🗑️ Cleared ${expiredKeys.length} expired cache items');
    }
  }

  // Get cache size
  int get size => _cache.length;

  // Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'size': _cache.length,
      'maxSize': maxCacheSize,
      'utilizationPercent': (_cache.length / maxCacheSize * 100).toStringAsFixed(1),
      'oldestItemAge': _getOldestItemAge(),
    };
  }

  Duration? _getOldestItemAge() {
    if (_cacheTimestamps.isEmpty) return null;

    final oldestTimestamp = _cacheTimestamps.values.reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );

    return DateTime.now().difference(oldestTimestamp);
  }

  // Cache with function result
  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetchFunction, {
    Duration? maxAge,
  }) async {
    // Try to get from cache first
    final cached = get<T>(key, maxAge: maxAge);
    if (cached != null) {
      if (kDebugMode) {
        print('✓ Cache hit: $key');
      }
      return cached;
    }

    // Fetch and cache
    if (kDebugMode) {
      print('⚠️ Cache miss: $key - fetching...');
    }

    final result = await fetchFunction();
    set(key, result);
    return result;
  }

  // Prefetch and cache
  Future<void> prefetch(String key, Future<dynamic> Function() fetchFunction) async {
    final result = await fetchFunction();
    set(key, result);
  }
}


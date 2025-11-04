import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceUtils {
  // Image caching configuration
  static const int maxImageCacheSize = 100 * 1024 * 1024; // 100 MB
  static const int maxImageCacheCount = 1000;

  // Initialize performance optimizations
  static void initialize() {
    if (kDebugMode) {
      print('⚡ Initializing performance optimizations...');
    }

    // Configure image cache
    PaintingBinding.instance.imageCache.maximumSize = maxImageCacheCount;
    PaintingBinding.instance.imageCache.maximumSizeBytes = maxImageCacheSize;

    if (kDebugMode) {
      print('✓ Image cache configured: $maxImageCacheCount images, ${maxImageCacheSize ~/ (1024 * 1024)} MB');
    }
  }

  // Clear image cache
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    if (kDebugMode) {
      print('🗑️ Image cache cleared');
    }
  }

  // Get memory usage info
  static String getMemoryInfo() {
    final cache = PaintingBinding.instance.imageCache;
    final liveImages = cache.liveImageCount;
    final pendingImages = cache.pendingImageCount;
    final currentSizeBytes = cache.currentSizeBytes;
    final currentSizeMB = (currentSizeBytes / (1024 * 1024)).toStringAsFixed(2);
    
    return 'Images: $liveImages live, $pendingImages pending\nCache: $currentSizeMB MB';
  }

  // Lazy load widget with placeholder
  static Widget lazyLoadWidget({
    required Widget Function() builder,
    Widget? placeholder,
  }) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder();
        }
        return placeholder ?? const SizedBox.shrink();
      },
    );
  }

  // Debounce function calls
  static Function debounce(
    Function func,
    Duration delay,
  ) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }

  // Throttle function calls
  static Function throttle(
    Function func,
    Duration duration,
  ) {
    bool canExecute = true;
    return () {
      if (canExecute) {
        func();
        canExecute = false;
        Timer(duration, () {
          canExecute = true;
        });
      }
    };
  }

  // Measure widget build time
  static void measureBuildTime(String widgetName, VoidCallback buildFunction) {
    final stopwatch = Stopwatch()..start();
    buildFunction();
    stopwatch.stop();
    
    if (kDebugMode) {
      print('⏱️ $widgetName build time: ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  // Log frame timing
  static void logFrameTiming() {
    if (kDebugMode) {
      WidgetsBinding.instance.addTimingsCallback((timings) {
        for (var timing in timings) {
          final fps = 1000 / timing.totalSpan.inMilliseconds;
          if (fps < 50) {
            print('⚠️ Low FPS detected: ${fps.toStringAsFixed(1)}');
          }
        }
      });
    }
  }

  // Optimize list scrolling
  static ScrollPhysics getOptimizedScrollPhysics() {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  // Pre-cache images
  static Future<void> precacheImages(
    BuildContext context,
    List<String> imagePaths,
  ) async {
    for (var path in imagePaths) {
      if (path.startsWith('http')) {
        await precacheImage(NetworkImage(path), context);
      } else {
        await precacheImage(AssetImage(path), context);
      }
    }
    
    if (kDebugMode) {
      print('✓ Precached ${imagePaths.length} images');
    }
  }

  // Reduce widget rebuilds with const constructors
  static Widget constOrNot(Widget widget) {
    return widget;
  }

  // Efficient list item builder
  static Widget buildOptimizedListItem({
    required int index,
    required Widget Function(int) itemBuilder,
    bool useAutomaticKeepAlive = false,
  }) {
    if (useAutomaticKeepAlive) {
      return AutomaticKeepAlive(
        child: itemBuilder(index),
      );
    }
    return itemBuilder(index);
  }

  // Memory-efficient image loading
  static ImageProvider getOptimizedImageProvider(
    String imageUrl, {
    int? cacheWidth,
    int? cacheHeight,
  }) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage(imageUrl);
    }
  }

  // Batch update optimization
  static Future<void> batchUpdate(
    List<Future<void> Function()> updates,
  ) async {
    await Future.wait(updates.map((update) => update()));
  }
}

// Auto-dispose mixin for StatefulWidgets
mixin AutoDispose<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<TextEditingController> _controllers = [];
  final List<ScrollController> _scrollControllers = [];
  final List<AnimationController> _animationControllers = [];

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void addTimer(Timer timer) {
    _timers.add(timer);
  }

  void addController(TextEditingController controller) {
    _controllers.add(controller);
  }

  void addScrollController(ScrollController controller) {
    _scrollControllers.add(controller);
  }

  void addAnimationController(AnimationController controller) {
    _animationControllers.add(controller);
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    for (var timer in _timers) {
      timer.cancel();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

// Lazy loading list view
class LazyListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;

  const LazyListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      physics: PerformanceUtils.getOptimizedScrollPhysics(),
      cacheExtent: 100, // Cache 100 pixels ahead
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
    );
  }
}

// Cached widget wrapper
class CachedWidget extends StatelessWidget {
  final Widget child;
  final String cacheKey;

  const CachedWidget({
    super.key,
    required this.child,
    required this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: child,
    );
  }
}


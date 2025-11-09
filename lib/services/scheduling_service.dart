import '../models/class_model.dart';

/// Service for handling scheduling conflicts and buffer time
class SchedulingService {
  /// Check if a new class conflicts with existing classes
  /// Returns list of conflicting classes
  static List<Class> detectConflicts({
    required DateTime newClassStart,
    required DateTime newClassEnd,
    required List<Class> existingClasses,
    int bufferMinutes = 15, // Default 15 min buffer
  }) {
    final List<Class> conflicts = [];
    
    // Add buffer time to the new class
    final newStart = newClassStart.subtract(Duration(minutes: bufferMinutes));
    final newEnd = newClassEnd.add(Duration(minutes: bufferMinutes));
    
    for (final existing in existingClasses) {
      // Skip cancelled or completed classes
      if (existing.status == ClassStatus.cancelled || 
          existing.status == ClassStatus.completed) {
        continue;
      }
      
      // Add buffer to existing class
      final existingStart = existing.startTime.subtract(Duration(minutes: bufferMinutes));
      final existingEnd = existing.endTime.add(Duration(minutes: bufferMinutes));
      
      // Check for overlap
      final hasOverlap = _timeRangesOverlap(
        newStart,
        newEnd,
        existingStart,
        existingEnd,
      );
      
      if (hasOverlap) {
        conflicts.add(existing);
      }
    }
    
    return conflicts;
  }
  
  /// Check if two time ranges overlap
  static bool _timeRangesOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    // Check if ranges overlap
    // Range 1: [start1, end1]
    // Range 2: [start2, end2]
    // They overlap if: start1 < end2 AND start2 < end1
    return start1.isBefore(end2) && start2.isBefore(end1);
  }
  
  /// Get recommended buffer time based on class type and duration
  static int getRecommendedBufferMinutes({
    required int classDurationMinutes,
    required ClassType classType,
  }) {
    // Longer classes need more buffer time
    if (classDurationMinutes >= 120) {
      return 30; // 30 min buffer for 2+ hour classes
    } else if (classDurationMinutes >= 60) {
      return 20; // 20 min buffer for 1-2 hour classes
    } else {
      return 15; // 15 min buffer for < 1 hour classes
    }
  }
  
  /// Format conflict message for display
  static String formatConflictMessage(List<Class> conflicts, int bufferMinutes) {
    if (conflicts.isEmpty) return '';
    
    if (conflicts.length == 1) {
      final conflict = conflicts.first;
      return 'Conflicts with "${conflict.title}" (including $bufferMinutes min buffer time)';
    }
    
    return 'Conflicts with ${conflicts.length} classes (including $bufferMinutes min buffer time)';
  }
  
  /// Get available time slots for a specific day
  static List<TimeSlot> getAvailableSlots({
    required DateTime date,
    required List<Class> existingClasses,
    required int slotDurationMinutes,
    int bufferMinutes = 15,
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0),
    TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0),
  }) {
    final List<TimeSlot> availableSlots = [];
    
    // Create time slots throughout the day
    final dayStart = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    final dayEnd = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
    
    DateTime currentSlot = dayStart;
    
    while (currentSlot.isBefore(dayEnd)) {
      final slotEnd = currentSlot.add(Duration(minutes: slotDurationMinutes));
      
      // Check if this slot conflicts with any existing class
      final conflicts = detectConflicts(
        newClassStart: currentSlot,
        newClassEnd: slotEnd,
        existingClasses: existingClasses,
        bufferMinutes: bufferMinutes,
      );
      
      if (conflicts.isEmpty && slotEnd.isBefore(dayEnd.add(const Duration(minutes: 1)))) {
        availableSlots.add(TimeSlot(
          start: currentSlot,
          end: slotEnd,
        ));
      }
      
      // Move to next slot (30 min intervals)
      currentSlot = currentSlot.add(const Duration(minutes: 30));
    }
    
    return availableSlots;
  }
  
  /// Suggest alternative times if there's a conflict
  static List<DateTime> suggestAlternativeTimes({
    required DateTime desiredStart,
    required int durationMinutes,
    required List<Class> existingClasses,
    int bufferMinutes = 15,
  }) {
    final List<DateTime> alternatives = [];
    
    // Try times on the same day
    final sameDay = desiredStart;
    
    // Try 30 min before
    final before = desiredStart.subtract(const Duration(minutes: 30));
    if (_isSlotAvailable(before, durationMinutes, existingClasses, bufferMinutes)) {
      alternatives.add(before);
    }
    
    // Try 30 min after
    final after = desiredStart.add(const Duration(minutes: 30));
    if (_isSlotAvailable(after, durationMinutes, existingClasses, bufferMinutes)) {
      alternatives.add(after);
    }
    
    // Try 1 hour before
    final hourBefore = desiredStart.subtract(const Duration(hours: 1));
    if (_isSlotAvailable(hourBefore, durationMinutes, existingClasses, bufferMinutes)) {
      alternatives.add(hourBefore);
    }
    
    // Try 1 hour after
    final hourAfter = desiredStart.add(const Duration(hours: 1));
    if (_isSlotAvailable(hourAfter, durationMinutes, existingClasses, bufferMinutes)) {
      alternatives.add(hourAfter);
    }
    
    return alternatives.take(3).toList(); // Return top 3 alternatives
  }
  
  static bool _isSlotAvailable(
    DateTime start,
    int durationMinutes,
    List<Class> existingClasses,
    int bufferMinutes,
  ) {
    final end = start.add(Duration(minutes: durationMinutes));
    final conflicts = detectConflicts(
      newClassStart: start,
      newClassEnd: end,
      existingClasses: existingClasses,
      bufferMinutes: bufferMinutes,
    );
    return conflicts.isEmpty;
  }
}

/// Time slot model
class TimeSlot {
  final DateTime start;
  final DateTime end;
  
  TimeSlot({required this.start, required this.end});
  
  int get durationMinutes => end.difference(start).inMinutes;
  
  @override
  String toString() {
    final startTime = TimeOfDay.fromDateTime(start);
    final endTime = TimeOfDay.fromDateTime(end);
    return '${startTime.format(null as BuildContext)} - ${endTime.format(null as BuildContext)}';
  }
}


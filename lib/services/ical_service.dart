import 'package:intl/intl.dart';
import '../models/class_model.dart';

/// Service for generating iCal (.ics) files for calendar export
class ICalService {
  /// Generate iCal content for a single class
  static String generateICalForClass(Class classItem, {String? coachName}) {
    final buffer = StringBuffer();
    
    // iCal header
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//Sparktracks//Class Scheduler//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:${classItem.title}');
    buffer.writeln('X-WR-TIMEZONE:America/Los_Angeles');
    
    // Event
    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:${classItem.id}@sparktracks.com');
    buffer.writeln('DTSTAMP:${_formatDateTime(DateTime.now())}');
    buffer.writeln('DTSTART:${_formatDateTime(classItem.startTime)}');
    buffer.writeln('DTEND:${_formatDateTime(classItem.endTime)}');
    buffer.writeln('SUMMARY:${_escapeText(classItem.title)}');
    
    // Description
    final description = _buildDescription(classItem, coachName);
    buffer.writeln('DESCRIPTION:${_escapeText(description)}');
    
    // Location
    if (classItem.locationType == LocationType.online) {
      buffer.writeln('LOCATION:Online');
      if (classItem.meetingLink != null) {
        buffer.writeln('URL:${classItem.meetingLink}');
      }
    } else if (classItem.location != null) {
      buffer.writeln('LOCATION:${_escapeText(classItem.location!)}');
    }
    
    // Recurrence rule (if recurring)
    if (classItem.type == ClassType.weekly) {
      buffer.writeln('RRULE:FREQ=WEEKLY;BYDAY=${_getWeekDays(classItem.recurringWeekDays)}');
    } else if (classItem.type == ClassType.monthly) {
      buffer.writeln('RRULE:FREQ=MONTHLY');
    }
    
    // Alarm (reminder 24 hours before)
    buffer.writeln('BEGIN:VALARM');
    buffer.writeln('TRIGGER:-PT24H');
    buffer.writeln('DESCRIPTION:Class starts in 24 hours');
    buffer.writeln('ACTION:DISPLAY');
    buffer.writeln('END:VALARM');
    
    // Alarm (reminder 1 hour before)
    buffer.writeln('BEGIN:VALARM');
    buffer.writeln('TRIGGER:-PT1H');
    buffer.writeln('DESCRIPTION:Class starts in 1 hour');
    buffer.writeln('ACTION:DISPLAY');
    buffer.writeln('END:VALARM');
    
    buffer.writeln('STATUS:CONFIRMED');
    buffer.writeln('SEQUENCE:0');
    buffer.writeln('END:VEVENT');
    buffer.writeln('END:VCALENDAR');
    
    return buffer.toString();
  }
  
  /// Generate iCal content for multiple classes
  static String generateICalForClasses(List<Class> classes, {Map<String, String>? coachNames}) {
    final buffer = StringBuffer();
    
    // iCal header
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//Sparktracks//Class Scheduler//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:My Sparktracks Classes');
    buffer.writeln('X-WR-TIMEZONE:America/Los_Angeles');
    
    // Add each class as an event
    for (final classItem in classes) {
      final coachName = coachNames?[classItem.coachId];
      buffer.write(_generateEvent(classItem, coachName));
    }
    
    buffer.writeln('END:VCALENDAR');
    
    return buffer.toString();
  }
  
  static String _generateEvent(Class classItem, String? coachName) {
    final buffer = StringBuffer();
    
    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:${classItem.id}@sparktracks.com');
    buffer.writeln('DTSTAMP:${_formatDateTime(DateTime.now())}');
    buffer.writeln('DTSTART:${_formatDateTime(classItem.startTime)}');
    buffer.writeln('DTEND:${_formatDateTime(classItem.endTime)}');
    buffer.writeln('SUMMARY:${_escapeText(classItem.title)}');
    
    final description = _buildDescription(classItem, coachName);
    buffer.writeln('DESCRIPTION:${_escapeText(description)}');
    
    if (classItem.locationType == LocationType.online) {
      buffer.writeln('LOCATION:Online');
      if (classItem.meetingLink != null) {
        buffer.writeln('URL:${classItem.meetingLink}');
      }
    } else if (classItem.location != null) {
      buffer.writeln('LOCATION:${_escapeText(classItem.location!)}');
    }
    
    if (classItem.type == ClassType.weekly) {
      buffer.writeln('RRULE:FREQ=WEEKLY;BYDAY=${_getWeekDays(classItem.recurringWeekDays)}');
    } else if (classItem.type == ClassType.monthly) {
      buffer.writeln('RRULE:FREQ=MONTHLY');
    }
    
    buffer.writeln('BEGIN:VALARM');
    buffer.writeln('TRIGGER:-PT24H');
    buffer.writeln('ACTION:DISPLAY');
    buffer.writeln('END:VALARM');
    
    buffer.writeln('STATUS:CONFIRMED');
    buffer.writeln('SEQUENCE:0');
    buffer.writeln('END:VEVENT');
    
    return buffer.toString();
  }
  
  static String _buildDescription(Class classItem, String? coachName) {
    final parts = <String>[];
    
    if (coachName != null) {
      parts.add('Coach: $coachName');
    }
    
    parts.add(classItem.description);
    
    if (classItem.category != null) {
      parts.add('Category: ${classItem.category}');
    }
    
    if (classItem.price > 0) {
      parts.add('Price: \$${classItem.price.toStringAsFixed(2)}');
    }
    
    parts.add('\\nManage your classes at: https://sparktracks-mvp.web.app');
    
    return parts.join('\\n\\n');
  }
  
  /// Format DateTime for iCal (format: YYYYMMDDTHHMMSSZ)
  static String _formatDateTime(DateTime dateTime) {
    // Convert to UTC
    final utc = dateTime.toUtc();
    return DateFormat("yyyyMMdd'T'HHmmss'Z'").format(utc);
  }
  
  /// Get weekday abbreviations for RRULE (e.g., "MO,WE,FR")
  static String _getWeekDays(List<int>? weekDays) {
    if (weekDays == null || weekDays.isEmpty) {
      return 'MO'; // Default to Monday
    }
    
    const dayMap = {
      1: 'MO', // Monday
      2: 'TU', // Tuesday
      3: 'WE', // Wednesday
      4: 'TH', // Thursday
      5: 'FR', // Friday
      6: 'SA', // Saturday
      7: 'SU', // Sunday
    };
    
    return weekDays.map((day) => dayMap[day] ?? 'MO').join(',');
  }
  
  /// Escape special characters for iCal format
  static String _escapeText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }
  
  /// Get suggested filename for iCal download
  static String getFileName(Class classItem) {
    final sanitized = classItem.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    
    return '${sanitized}-class.ics';
  }
  
  /// Get suggested filename for multiple classes
  static String getFileNameForMultiple() {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return 'sparktracks-classes-$date.ics';
  }
}


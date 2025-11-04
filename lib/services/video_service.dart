import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoService {
  // Launch video meeting
  static Future<bool> launchMeeting(String meetingLink) async {
    try {
      final uri = Uri.parse(meetingLink);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        if (kDebugMode) {
          print('❌ Could not launch meeting: $meetingLink');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error launching meeting: $e');
      }
      return false;
    }
  }

  // Generate Zoom meeting link (placeholder - requires Zoom SDK/API)
  static String generateZoomLink({
    required String topic,
    required DateTime startTime,
    required int durationMinutes,
  }) {
    // In production, integrate with Zoom API:
    // 1. Add zoom_sdk package
    // 2. Use Zoom API to create meeting
    // 3. Return actual meeting link
    
    final mockMeetingId = DateTime.now().millisecondsSinceEpoch.toString().substring(4);
    return 'https://zoom.us/j/$mockMeetingId';
  }

  // Generate Google Meet link (placeholder - requires Google Meet API)
  static String generateGoogleMeetLink({
    required String topic,
    required DateTime startTime,
    required int durationMinutes,
  }) {
    // In production, integrate with Google Meet API:
    // 1. Use Google Calendar API to create event with Meet
    // 2. Return actual meeting link
    
    final mockCode = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return 'https://meet.google.com/$mockCode';
  }

  // Validate meeting link format
  static bool isValidMeetingLink(String link) {
    if (link.isEmpty) return false;
    
    try {
      final uri = Uri.parse(link);
      
      // Check if it's a valid URL
      if (!uri.hasScheme || !uri.hasAuthority) {
        return false;
      }
      
      // Check for common video conferencing domains
      final validDomains = [
        'zoom.us',
        'meet.google.com',
        'teams.microsoft.com',
        'whereby.com',
        'meet.jit.si',
        'webex.com',
      ];
      
      return validDomains.any((domain) => uri.host.contains(domain));
    } catch (e) {
      return false;
    }
  }

  // Get meeting platform from link
  static String getMeetingPlatform(String link) {
    if (link.contains('zoom.us')) return 'Zoom';
    if (link.contains('meet.google.com')) return 'Google Meet';
    if (link.contains('teams.microsoft.com')) return 'Microsoft Teams';
    if (link.contains('whereby.com')) return 'Whereby';
    if (link.contains('meet.jit.si')) return 'Jitsi Meet';
    if (link.contains('webex.com')) return 'Webex';
    return 'Video Call';
  }

  // Check if meeting time is now
  static bool isMeetingTimeNow(DateTime meetingTime, int durationMinutes) {
    final now = DateTime.now();
    final meetingEnd = meetingTime.add(Duration(minutes: durationMinutes));
    
    return now.isAfter(meetingTime) && now.isBefore(meetingEnd);
  }

  // Get meeting status
  static String getMeetingStatus(DateTime meetingTime, int durationMinutes) {
    final now = DateTime.now();
    final meetingEnd = meetingTime.add(Duration(minutes: durationMinutes));
    
    if (now.isBefore(meetingTime)) {
      final diff = meetingTime.difference(now);
      if (diff.inMinutes < 15) {
        return 'Starting soon';
      } else if (diff.inHours < 1) {
        return 'Starts in ${diff.inMinutes} min';
      } else if (diff.inDays < 1) {
        return 'Starts in ${diff.inHours} hours';
      } else {
        return 'Scheduled';
      }
    } else if (now.isAfter(meetingTime) && now.isBefore(meetingEnd)) {
      return 'In progress';
    } else {
      return 'Ended';
    }
  }

  // Create calendar reminder
  static Future<void> addToCalendar({
    required String title,
    required String description,
    required DateTime startTime,
    required int durationMinutes,
    required String meetingLink,
  }) async {
    if (kDebugMode) {
      print('📅 Adding to calendar: $title');
      print('Start: $startTime');
      print('Duration: $durationMinutes min');
      print('Link: $meetingLink');
    }
    
    // In production, use add_2_calendar package:
    // final event = Event(
    //   title: title,
    //   description: description,
    //   location: meetingLink,
    //   startDate: startTime,
    //   endDate: startTime.add(Duration(minutes: durationMinutes)),
    // );
    // await Add2Calendar.addEvent2Cal(event);
  }

  // Send meeting reminder
  static Future<void> sendMeetingReminder({
    required String recipientEmail,
    required String className,
    required DateTime meetingTime,
    required String meetingLink,
  }) async {
    if (kDebugMode) {
      print('📧 Sending meeting reminder to: $recipientEmail');
      print('Class: $className');
      print('Time: $meetingTime');
      print('Link: $meetingLink');
    }
    
    // In production, integrate with email service
    // to send reminder emails with meeting details
  }
}


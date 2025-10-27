import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:convert';

class NotificationService {
  static const String _baseUrl = 'https://api.sparktracks.com'; // Replace with actual API URL
  
  // Send push notification
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send push notification: ${response.body}');
      }
    } catch (e) {
      throw Exception('Push notification error: $e');
    }
  }

  // Send email notification
  Future<void> sendEmailNotification({
    required String to,
    required String subject,
    required String body,
    String? from,
  }) async {
    try {
      // Configure SMTP server (replace with actual SMTP settings)
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: 'noreply@sparktracks.com',
        password: 'your-app-password',
      );
      
      final message = Message()
        ..from = Address(from ?? 'noreply@sparktracks.com', 'SparkTracks')
        ..recipients.add(to)
        ..subject = subject
        ..html = body;
      
      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Email notification error: $e');
    }
  }
  
  // Send SMS notification
  Future<void> sendSmsNotification({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'message': message,
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send SMS: ${response.body}');
      }
    } catch (e) {
      throw Exception('SMS notification error: $e');
    }
  }
  
  // Class cancellation notification
  Future<void> notifyClassCancellation({
    required String classId,
    required String className,
    required List<String> studentIds,
    required String reason,
  }) async {
    try {
      // Send notifications to all enrolled students
      for (final studentId in studentIds) {
        await sendPushNotification(
          userId: studentId,
          title: 'Class Cancelled',
          body: '$className has been cancelled. Reason: $reason',
          data: {
            'type': 'class_cancellation',
            'classId': classId,
            'reason': reason,
          },
        );
      }
      
      // Send email notifications to parents
      await _notifyParentsOfClassCancellation(classId, className, reason, studentIds);
    } catch (e) {
      throw Exception('Class cancellation notification error: $e');
    }
  }
  
  // Task completion notification
  Future<void> notifyTaskCompletion({
    required String parentId,
    required String childName,
    required String taskTitle,
  }) async {
    try {
      await sendPushNotification(
        userId: parentId,
        title: 'Task Completed',
        body: '$childName has completed: $taskTitle',
        data: {
          'type': 'task_completion',
          'childName': childName,
          'taskTitle': taskTitle,
        },
      );
    } catch (e) {
      throw Exception('Task completion notification error: $e');
    }
  }
  
  // Task approval notification
  Future<void> notifyTaskApproval({
    required String childId,
    required String taskTitle,
    required bool approved,
    String? feedback,
  }) async {
    try {
      final title = approved ? 'Task Approved!' : 'Task Needs Revision';
      final body = approved 
          ? 'Great job! Your task "$taskTitle" has been approved.'
          : 'Your task "$taskTitle" needs some revision. ${feedback ?? ''}';
      
      await sendPushNotification(
        userId: childId,
        title: title,
        body: body,
        data: {
          'type': 'task_approval',
          'taskTitle': taskTitle,
          'approved': approved,
          'feedback': feedback,
        },
      );
    } catch (e) {
      throw Exception('Task approval notification error: $e');
    }
  }
  
  // Payment reminder notification
  Future<void> notifyPaymentReminder({
    required String parentId,
    required String childName,
    required double amount,
    required String className,
  }) async {
    try {
      await sendPushNotification(
        userId: parentId,
        title: 'Payment Reminder',
        body: 'Payment of \$${amount.toStringAsFixed(2)} is due for $childName\'s $className',
        data: {
          'type': 'payment_reminder',
          'childName': childName,
          'amount': amount,
          'className': className,
        },
      );
    } catch (e) {
      throw Exception('Payment reminder notification error: $e');
    }
  }
  
  // Achievement notification
  Future<void> notifyAchievement({
    required String childId,
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    try {
      await sendPushNotification(
        userId: childId,
        title: 'Achievement Unlocked! 🏆',
        body: 'Congratulations! You earned: $achievementTitle',
        data: {
          'type': 'achievement',
          'achievementTitle': achievementTitle,
          'achievementDescription': achievementDescription,
        },
      );
    } catch (e) {
      throw Exception('Achievement notification error: $e');
    }
  }
  
  // Attendance notification
  Future<void> notifyAttendance({
    required String parentId,
    required String childName,
    required String className,
    required bool present,
  }) async {
    try {
      final title = present ? 'Class Attended' : 'Class Missed';
      final body = present 
          ? '$childName attended $className today!'
          : '$childName missed $className today.';
      
      await sendPushNotification(
        userId: parentId,
        title: title,
        body: body,
        data: {
          'type': 'attendance',
          'childName': childName,
          'className': className,
          'present': present,
        },
      );
    } catch (e) {
      throw Exception('Attendance notification error: $e');
    }
  }
  
  // Helper method to notify parents of class cancellation
  Future<void> _notifyParentsOfClassCancellation(
    String classId,
    String className,
    String reason,
    List<String> studentIds,
  ) async {
    try {
      // Get parent emails for all students
      for (final studentId in studentIds) {
        // In a real app, you would fetch parent email from database
        final parentEmail = 'parent@example.com'; // Mock email
        
        await sendEmailNotification(
          to: parentEmail,
          subject: 'Class Cancellation Notice',
          body: '''
            <h2>Class Cancellation Notice</h2>
            <p>Dear Parent,</p>
            <p>We regret to inform you that the class <strong>$className</strong> has been cancelled.</p>
            <p><strong>Reason:</strong> $reason</p>
            <p>We apologize for any inconvenience this may cause.</p>
            <p>Best regards,<br>SparkTracks Team</p>
          ''',
        );
      }
    } catch (e) {
      throw Exception('Parent notification error: $e');
    }
  }
  
  // Show in-app notification
  static void showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case NotificationType.info:
      default:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

enum NotificationType {
  success,
  warning,
  error,
  info,
} 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../utils/app_config.dart';
import '../models/user_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // SendGrid Configuration
  static const String _sendGridApiKey = AppConfig.sendGridApiKey;
  static const String _sendGridUrl = 'https://api.sendgrid.com/v3/mail/send';
  static const String _fromEmail = AppConfig.sendGridFromEmail;
  static const String _fromName = AppConfig.sendGridFromName;

  // Twilio Configuration
  static const String _twilioAccountSid = AppConfig.twilioAccountSid;
  static const String _twilioAuthToken = AppConfig.twilioAuthToken;
  static const String _twilioFromNumber = AppConfig.twilioFromNumber;
  static const String _twilioUrl = 'https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json';

  // Rate Limiting
  static final Map<String, DateTime> _emailRateLimit = {};
  static final Map<String, DateTime> _smsRateLimit = {};

  /// Send email notification using SendGrid
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? htmlBody,
    List<String>? cc,
    List<String>? bcc,
    Map<String, String>? attachments,
  }) async {
    try {
      // Check rate limiting
      if (!_checkEmailRateLimit(to)) {
        throw Exception('Email rate limit exceeded for $to');
      }

      final headers = {
        'Authorization': 'Bearer $_sendGridApiKey',
        'Content-Type': 'application/json',
      };

      final emailData = {
        'personalizations': [
          {
            'to': [
              {'email': to}
            ],
            if (cc != null) 'cc': cc.map((email) => {'email': email}).toList(),
            if (bcc != null) 'bcc': bcc.map((email) => {'email': email}).toList(),
          }
        ],
        'from': {
          'email': _fromEmail,
          'name': _fromName,
        },
        'subject': subject,
        'content': [
          {
            'type': 'text/plain',
            'value': body,
          },
          if (htmlBody != null)
            {
              'type': 'text/html',
              'value': htmlBody,
            }
        ],
      };

      final response = await http.post(
        Uri.parse(_sendGridUrl),
        headers: headers,
        body: jsonEncode(emailData),
      );

      if (response.statusCode == 202) {
        _updateEmailRateLimit(to);
        return true;
      } else {
        throw Exception('SendGrid API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  /// Send SMS notification using Twilio
  Future<bool> sendSMS({
    required String to,
    required String message,
    String? from,
  }) async {
    try {
      // Check rate limiting
      if (!_checkSmsRateLimit(to)) {
        throw Exception('SMS rate limit exceeded for $to');
      }

      final headers = {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final body = {
        'To': to,
        'From': from ?? _twilioFromNumber,
        'Body': message,
      };

      final response = await http.post(
        Uri.parse(_twilioUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        _updateSmsRateLimit(to);
        return true;
      } else {
        throw Exception('Twilio API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  /// Send notification based on user preferences
  Future<bool> sendNotification({
    required User user,
    required String subject,
    required String message,
    NotificationType type = NotificationType.email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final preferences = user.notificationPreferences;
      
      switch (type) {
        case NotificationType.email:
          if (!preferences.emailEnabled) return false;
          return await sendEmail(
            to: user.email,
            subject: subject,
            body: message,
            htmlBody: _generateHtmlEmail(subject, message, data),
          );
          
        case NotificationType.sms:
          if (!preferences.smsEnabled || user.phone == null) return false;
          return await sendSMS(
            to: user.phone!,
            message: message,
          );
          
        case NotificationType.push:
          // TODO: Implement push notifications
          return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  /// Send weekly summary email
  Future<bool> sendWeeklySummary(User user, Map<String, dynamic> summary) async {
    final subject = 'Your Sparktracks Weekly Summary';
    final message = _generateWeeklySummaryText(summary);
    final htmlMessage = _generateWeeklySummaryHtml(summary);
    
    return await sendEmail(
      to: user.email,
      subject: subject,
      body: message,
      htmlBody: htmlMessage,
    );
  }

  /// Send payment reminder
  Future<bool> sendPaymentReminder(User user, Map<String, dynamic> paymentInfo) async {
    final subject = 'Payment Reminder - Sparktracks';
    final message = _generatePaymentReminderText(paymentInfo);
    
    return await sendNotification(
      user: user,
      subject: subject,
      message: message,
      type: NotificationType.email,
    );
  }

  /// Send class reminder
  Future<bool> sendClassReminder(User user, Map<String, dynamic> classInfo) async {
    final subject = 'Class Reminder - ${classInfo['className']}';
    final message = _generateClassReminderText(classInfo);
    
    return await sendNotification(
      user: user,
      subject: subject,
      message: message,
      type: NotificationType.sms, // SMS for urgent reminders
    );
  }

  /// Send achievement notification
  Future<bool> sendAchievementNotification(User user, Map<String, dynamic> achievement) async {
    final subject = '🎉 Achievement Unlocked!';
    final message = _generateAchievementText(achievement);
    
    return await sendNotification(
      user: user,
      subject: subject,
      message: message,
      type: NotificationType.email,
    );
  }

  // Private helper methods

  bool _checkEmailRateLimit(String email) {
    final now = DateTime.now();
    final lastSent = _emailRateLimit[email];
    
    if (lastSent != null) {
      final timeDiff = now.difference(lastSent);
      if (timeDiff < AppConfig.emailCooldown) {
        return false;
      }
    }
    
    return true;
  }

  void _updateEmailRateLimit(String email) {
    _emailRateLimit[email] = DateTime.now();
  }

  bool _checkSmsRateLimit(String phone) {
    final now = DateTime.now();
    final lastSent = _smsRateLimit[phone];
    
    if (lastSent != null) {
      final timeDiff = now.difference(lastSent);
      if (timeDiff < AppConfig.smsCooldown) {
        return false;
      }
    }
    
    return true;
  }

  void _updateSmsRateLimit(String phone) {
    _smsRateLimit[phone] = DateTime.now();
  }

  String _generateHtmlEmail(String subject, String message, Map<String, dynamic>? data) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>$subject</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #6366F1, #4F46E5); color: white; padding: 20px; border-radius: 8px; }
        .content { background: #f9fafb; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .footer { text-align: center; color: #6b7280; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Sparktracks</h1>
        </div>
        <div class="content">
          $message
        </div>
        <div class="footer">
          <p>© 2024 Sparktracks. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
    ''';
  }

  String _generateWeeklySummaryText(Map<String, dynamic> summary) {
    return '''
    Weekly Summary - Sparktracks
    
    Tasks Completed: ${summary['tasksCompleted']}
    Points Earned: ${summary['pointsEarned']}
    Money Earned: \$${summary['moneyEarned']}
    Classes Attended: ${summary['classesAttended']}
    Streak: ${summary['streak']} days
    
    Keep up the great work!
    ''';
  }

  String _generateWeeklySummaryHtml(Map<String, dynamic> summary) {
    return '''
    <h2>Your Weekly Summary</h2>
    <p>Here's how you did this week:</p>
    <ul>
      <li><strong>Tasks Completed:</strong> ${summary['tasksCompleted']}</li>
      <li><strong>Points Earned:</strong> ${summary['pointsEarned']}</li>
      <li><strong>Money Earned:</strong> \$${summary['moneyEarned']}</li>
      <li><strong>Classes Attended:</strong> ${summary['classesAttended']}</li>
      <li><strong>Current Streak:</strong> ${summary['streak']} days</li>
    </ul>
    <p>Keep up the great work! 🎉</p>
    ''';
  }

  String _generatePaymentReminderText(Map<String, dynamic> paymentInfo) {
    return '''
    Payment Reminder
    
    Amount Due: \$${paymentInfo['amount']}
    Due Date: ${paymentInfo['dueDate']}
    Class: ${paymentInfo['className']}
    
    Please make your payment to continue enjoying Sparktracks.
    ''';
  }

  String _generateClassReminderText(Map<String, dynamic> classInfo) {
    return '''
    Class Reminder: ${classInfo['className']}
    Time: ${classInfo['time']}
    Location: ${classInfo['location']}
    
    Don't forget your class today!
    ''';
  }

  String _generateAchievementText(Map<String, dynamic> achievement) {
    return '''
    🎉 Achievement Unlocked!
    
    ${achievement['title']}
    ${achievement['description']}
    
    Congratulations on this milestone!
    ''';
  }
} 
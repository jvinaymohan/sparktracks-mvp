import 'package:flutter/foundation.dart';

enum EmailTemplate {
  taskAssigned,
  taskCompleted,
  taskApproved,
  taskRejected,
  classEnrolled,
  classReminder,
  attendanceMarked,
  paymentDue,
  paymentReceived,
  makeupRequest,
  achievementUnlocked,
  messageReceived,
}

class EmailService {
  // In a real app, this would integrate with SendGrid, AWS SES, or similar
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? replyTo,
  }) async {
    if (kDebugMode) {
      print('📧 Email sent to: $to');
      print('Subject: $subject');
      print('Body: $body');
    }
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In production, integrate with email service:
    // - SendGrid API
    // - AWS SES
    // - Mailgun
    // - Postmark
    
    return true;
  }

  static Future<bool> sendTemplateEmail({
    required String to,
    required String recipientName,
    required EmailTemplate template,
    required Map<String, dynamic> data,
  }) async {
    final emailContent = _buildTemplateContent(template, recipientName, data);
    
    return await sendEmail(
      to: to,
      subject: emailContent['subject'] as String,
      body: emailContent['body'] as String,
    );
  }

  static Map<String, String> _buildTemplateContent(
    EmailTemplate template,
    String recipientName,
    Map<String, dynamic> data,
  ) {
    switch (template) {
      case EmailTemplate.taskAssigned:
        return {
          'subject': '📝 New Task Assigned: ${data['taskTitle']}',
          'body': '''
Hi $recipientName,

A new task has been assigned to you!

Task: ${data['taskTitle']}
Due Date: ${data['dueDate']}
Reward: ${data['rewardPoints']} points

Description:
${data['description']}

Log in to Sparktracks to view details and start working on it!

Best regards,
Sparktracks Team
''',
        };
        
      case EmailTemplate.taskCompleted:
        return {
          'subject': '✓ Task Completed: ${data['taskTitle']}',
          'body': '''
Hi $recipientName,

${data['childName']} has completed a task and is waiting for your approval!

Task: ${data['taskTitle']}
Completed: ${data['completedDate']}

Please review and approve the task in your Sparktracks dashboard.

Best regards,
Sparktracks Team
''',
        };
        
      case EmailTemplate.taskApproved:
        return {
          'subject': '🎉 Task Approved: ${data['taskTitle']}',
          'body': '''
Hi $recipientName,

Great news! Your task has been approved!

Task: ${data['taskTitle']}
Points Earned: ${data['rewardPoints']}

Keep up the excellent work!

Best regards,
Sparktracks Team
''',
        };
        
      case EmailTemplate.classEnrolled:
        return {
          'subject': '🎓 Enrolled in ${data['className']}',
          'body': '''
Hi $recipientName,

You have been successfully enrolled in a new class!

Class: ${data['className']}
Coach: ${data['coachName']}
Schedule: ${data['schedule']}
Start Date: ${data['startDate']}

Log in to view class details and meeting information.

Best regards,
Sparktracks Team
''',
        };
        
      case EmailTemplate.paymentDue:
        return {
          'subject': '💰 Payment Due: ${data['className']}',
          'body': '''
Hi $recipientName,

This is a reminder that a payment is due for ${data['className']}.

Amount Due: \$${data['amount']}
Due Date: ${data['dueDate']}
Student: ${data['studentName']}

Please process the payment through your Sparktracks dashboard.

Best regards,
Sparktracks Team
''',
        };
        
      case EmailTemplate.achievementUnlocked:
        return {
          'subject': '🏆 Achievement Unlocked: ${data['achievementTitle']}',
          'body': '''
Hi $recipientName,

Congratulations! You've unlocked a new achievement!

Achievement: ${data['achievementTitle']}
Description: ${data['achievementDescription']}
Bonus Points: ${data['rewardPoints']}

Keep up the great work and unlock more achievements!

Best regards,
Sparktracks Team
''',
        };
        
      case EmailTemplate.messageReceived:
        return {
          'subject': '💬 New Message from ${data['senderName']}',
          'body': '''
Hi $recipientName,

You have received a new message on Sparktracks!

From: ${data['senderName']}

"${data['messagePreview']}"

Log in to read and reply to the message.

Best regards,
Sparktracks Team
''',
        };
        
      default:
        return {
          'subject': 'Notification from Sparktracks',
          'body': '''
Hi $recipientName,

You have a new notification on Sparktracks.

Please log in to view details.

Best regards,
Sparktracks Team
''',
        };
    }
  }

  // Send bulk emails
  static Future<void> sendBulkEmails(List<Map<String, dynamic>> emails) async {
    for (var email in emails) {
      await sendEmail(
        to: email['to'],
        subject: email['subject'],
        body: email['body'],
      );
      
      // Rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Send payment reminders
  static Future<void> sendPaymentReminders(List<Map<String, dynamic>> reminders) async {
    for (var reminder in reminders) {
      await sendTemplateEmail(
        to: reminder['parentEmail'],
        recipientName: reminder['parentName'],
        template: EmailTemplate.paymentDue,
        data: reminder,
      );
    }
  }
}


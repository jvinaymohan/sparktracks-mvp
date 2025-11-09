import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

/// Service for managing class reminders
class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Schedule a reminder for a class
  /// This creates a reminder document that will be picked up by Cloud Functions
  Future<void> scheduleReminder({
    required String classId,
    required DateTime classTime,
    required List<String> recipientEmails,
    ReminderType type = ReminderType.twentyFourHours,
  }) async {
    final reminderTime = _getReminderTime(classTime, type);
    
    // Only schedule if reminder time is in the future
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final reminderId = _firestore.collection('reminders').doc().id;

    await _firestore.collection('reminders').doc(reminderId).set({
      'id': reminderId,
      'classId': classId,
      'reminderTime': Timestamp.fromDate(reminderTime),
      'classTime': Timestamp.fromDate(classTime),
      'recipientEmails': recipientEmails,
      'type': type.toString().split('.').last,
      'status': 'pending', // pending, sent, failed
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Schedule all reminders for a class (24hr and 1hr)
  Future<void> scheduleAllRemindersForClass({
    required Class classItem,
    required List<String> recipientEmails,
  }) async {
    // 24-hour reminder
    await scheduleReminder(
      classId: classItem.id,
      classTime: classItem.startTime,
      recipientEmails: recipientEmails,
      type: ReminderType.twentyFourHours,
    );

    // 1-hour reminder
    await scheduleReminder(
      classId: classItem.id,
      classTime: classItem.startTime,
      recipientEmails: recipientEmails,
      type: ReminderType.oneHour,
    );
  }

  /// Cancel all reminders for a class
  Future<void> cancelRemindersForClass(String classId) async {
    final reminders = await _firestore
        .collection('reminders')
        .where('classId', isEqualTo: classId)
        .where('status', isEqualTo: 'pending')
        .get();

    final batch = _firestore.batch();
    for (final doc in reminders.docs) {
      batch.update(doc.reference, {'status': 'cancelled'});
    }
    await batch.commit();
  }

  /// Update reminders when class time changes
  Future<void> updateRemindersForClass({
    required String classId,
    required DateTime newClassTime,
    required List<String> recipientEmails,
  }) async {
    // Cancel old reminders
    await cancelRemindersForClass(classId);

    // Create new reminders
    await scheduleReminder(
      classId: classId,
      classTime: newClassTime,
      recipientEmails: recipientEmails,
      type: ReminderType.twentyFourHours,
    );

    await scheduleReminder(
      classId: classId,
      classTime: newClassTime,
      recipientEmails: recipientEmails,
      type: ReminderType.oneHour,
    );
  }

  DateTime _getReminderTime(DateTime classTime, ReminderType type) {
    switch (type) {
      case ReminderType.twentyFourHours:
        return classTime.subtract(const Duration(hours: 24));
      case ReminderType.oneHour:
        return classTime.subtract(const Duration(hours: 1));
      case ReminderType.fifteenMinutes:
        return classTime.subtract(const Duration(minutes: 15));
    }
  }

  /// Get reminders for a specific class
  Stream<List<Map<String, dynamic>>> getRemindersForClass(String classId) {
    return _firestore
        .collection('reminders')
        .where('classId', isEqualTo: classId)
        .orderBy('reminderTime')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

enum ReminderType {
  twentyFourHours,
  oneHour,
  fifteenMinutes,
}


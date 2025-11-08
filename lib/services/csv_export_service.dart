import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/student_model.dart';
import '../models/class_model.dart';
import '../models/invoice_model.dart';
import '../models/expense_model.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';

/// Service for exporting data to CSV format
class CsvExportService {
  final FirestoreService _firestoreService = FirestoreService();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  /// Export tasks to CSV
  Future<String> exportTasks(List<Task> tasks) async {
    final List<List<dynamic>> rows = [
      [
        'Task ID',
        'Title',
        'Description',
        'Child ID',
        'Parent ID',
        'Status',
        'Priority',
        'Due Date',
        'Created Date',
        'Completed Date',
        'Points',
        'Recurring',
        'Category',
      ],
    ];

    for (var task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description,
        task.childId,
        task.parentId,
        task.status.name,
        task.priority?.name ?? 'N/A',
        task.dueDate != null ? _dateFormat.format(task.dueDate!) : 'N/A',
        _dateFormat.format(task.createdAt),
        task.completedAt != null ? _dateTimeFormat.format(task.completedAt!) : 'N/A',
        task.points,
        task.isRecurring ? 'Yes' : 'No',
        task.category ?? 'N/A',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export task history report with completion rates
  Future<String> exportTaskHistoryReport(String userId, {required bool isParent}) async {
    final tasks = await _firestoreService.getTasks(
      userId,
      userType: isParent ? null : null,
    );

    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();
    final totalPoints = completedTasks.fold<int>(0, (sum, task) => sum + task.points);

    final List<List<dynamic>> rows = [
      ['Task History Report'],
      ['Generated', DateTime.now().toString()],
      ['User ID', userId],
      [],
      ['Summary'],
      ['Total Tasks', tasks.length],
      ['Completed Tasks', completedTasks.length],
      ['Pending Tasks', tasks.where((t) => t.status == TaskStatus.pending).length],
      ['Overdue Tasks', tasks.where((t) => t.status == TaskStatus.overdue).length],
      ['Total Points Earned', totalPoints],
      ['Completion Rate', '${tasks.isEmpty ? 0 : ((completedTasks.length / tasks.length) * 100).toStringAsFixed(1)}%'],
      [],
      ['Task Details'],
      [
        'Title',
        'Status',
        'Due Date',
        'Completed Date',
        'Points',
        'Days to Complete',
      ],
    ];

    for (var task in tasks) {
      final daysToComplete = task.completedAt != null && task.dueDate != null
          ? task.completedAt!.difference(task.createdAt).inDays
          : null;

      rows.add([
        task.title,
        task.status.name,
        task.dueDate != null ? _dateFormat.format(task.dueDate!) : 'N/A',
        task.completedAt != null ? _dateFormat.format(task.completedAt!) : 'N/A',
        task.points,
        daysToComplete?.toString() ?? 'N/A',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export students/children to CSV
  Future<String> exportStudents(List<Student> students) async {
    final List<List<dynamic>> rows = [
      [
        'Student ID',
        'User ID',
        'Name',
        'Email',
        'Date of Birth',
        'Age',
        'Parent ID',
        'Enrolled Date',
        'Color Code',
      ],
    ];

    for (var student in students) {
      final age = DateTime.now().year - student.dateOfBirth.year;
      rows.add([
        student.id,
        student.userId,
        student.name,
        student.email,
        _dateFormat.format(student.dateOfBirth),
        age,
        student.parentId,
        _dateFormat.format(student.enrolledAt),
        student.colorCode,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export classes to CSV
  Future<String> exportClasses(List<Class> classes) async {
    final List<List<dynamic>> rows = [
      [
        'Class ID',
        'Title',
        'Category',
        'Coach ID',
        'Type',
        'Location Type',
        'Location',
        'Skill Level',
        'Price',
        'Currency',
        'Duration (min)',
        'Capacity',
        'Enrolled Count',
        'Is Public',
        'Is Group',
        'Start Date',
        'End Date',
        'Status',
      ],
    ];

    for (var classItem in classes) {
      rows.add([
        classItem.id,
        classItem.title,
        classItem.category ?? 'N/A',
        classItem.coachId,
        classItem.type.name,
        classItem.locationType?.name ?? 'N/A',
        classItem.location ?? 'N/A',
        classItem.skillLevel?.name ?? 'N/A',
        classItem.price,
        classItem.currency,
        classItem.durationMinutes,
        classItem.capacity,
        classItem.enrolledStudents.length,
        classItem.isPublic ? 'Yes' : 'No',
        classItem.isGroupClass ? 'Yes' : 'No',
        classItem.startDate != null ? _dateFormat.format(classItem.startDate!) : 'N/A',
        classItem.endDate != null ? _dateFormat.format(classItem.endDate!) : 'N/A',
        classItem.status.name,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export class roster (students enrolled in a class)
  Future<String> exportClassRoster(Class classItem, List<Student> students) async {
    final List<List<dynamic>> rows = [
      ['Class Roster'],
      ['Class', classItem.title],
      ['Coach ID', classItem.coachId],
      ['Location', classItem.location ?? 'N/A'],
      ['Start Date', classItem.startDate != null ? _dateFormat.format(classItem.startDate!) : 'N/A'],
      [],
      ['Enrolled Students'],
      [
        'Student Name',
        'Email',
        'Age',
        'Enrolled Date',
        'Parent ID',
      ],
    ];

    for (var student in students) {
      final age = DateTime.now().year - student.dateOfBirth.year;
      rows.add([
        student.name,
        student.email,
        age,
        _dateFormat.format(student.enrolledAt),
        student.parentId,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export financial report (invoices and expenses)
  Future<String> exportFinancialReport({
    required List<Invoice> invoices,
    required List<Expense> expenses,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final totalIncome = invoices
        .where((i) => i.status == InvoiceStatus.paid)
        .fold<double>(0, (sum, invoice) => sum + invoice.amount);

    final totalExpenses = expenses
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final netProfit = totalIncome - totalExpenses;

    final List<List<dynamic>> rows = [
      ['Financial Report'],
      ['Period', '${_dateFormat.format(startDate)} to ${_dateFormat.format(endDate)}'],
      ['Generated', DateTime.now().toString()],
      [],
      ['Summary'],
      ['Total Income', totalIncome.toStringAsFixed(2)],
      ['Total Expenses', totalExpenses.toStringAsFixed(2)],
      ['Net Profit', netProfit.toStringAsFixed(2)],
      [],
      ['Income Details'],
      [
        'Invoice ID',
        'Student Name',
        'Class Name',
        'Amount',
        'Status',
        'Issue Date',
        'Due Date',
        'Paid Date',
      ],
    ];

    for (var invoice in invoices) {
      rows.add([
        invoice.id,
        invoice.studentName,
        invoice.className,
        invoice.amount.toStringAsFixed(2),
        invoice.status.name,
        _dateFormat.format(invoice.issueDate),
        _dateFormat.format(invoice.dueDate),
        invoice.paidDate != null ? _dateFormat.format(invoice.paidDate!) : 'N/A',
      ]);
    }

    rows.addAll([
      [],
      ['Expense Details'],
      [
        'Expense ID',
        'Category',
        'Description',
        'Amount',
        'Date',
        'Payment Method',
      ],
    ]);

    for (var expense in expenses) {
      rows.add([
        expense.id,
        expense.category,
        expense.description,
        expense.amount.toStringAsFixed(2),
        _dateFormat.format(expense.date),
        expense.paymentMethod,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export reviews for a coach
  Future<String> exportReviews(List<Review> reviews, String coachName) async {
    final averageRating = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0, (sum, review) => sum + review.rating) / reviews.length;

    final List<List<dynamic>> rows = [
      ['Reviews for $coachName'],
      ['Total Reviews', reviews.length],
      ['Average Rating', averageRating.toStringAsFixed(2)],
      [],
      ['Review Details'],
      [
        'Parent Name',
        'Rating',
        'Comment',
        'Tags',
        'Date',
        'Class Name',
      ],
    ];

    for (var review in reviews) {
      rows.add([
        review.parentName,
        review.rating.toStringAsFixed(1),
        review.comment ?? '',
        review.tags.join(', '),
        _dateFormat.format(review.createdAt),
        review.className ?? 'N/A',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export student progress report
  Future<String> exportStudentProgress(Student student, List<Task> tasks, List<Class> classes) async {
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final totalPoints = tasks
        .where((t) => t.status == TaskStatus.completed)
        .fold<int>(0, (sum, task) => sum + task.points);

    final List<List<dynamic>> rows = [
      ['Student Progress Report'],
      ['Student', student.name],
      ['Age', DateTime.now().year - student.dateOfBirth.year],
      ['Generated', DateTime.now().toString()],
      [],
      ['Task Summary'],
      ['Total Tasks', tasks.length],
      ['Completed', completedTasks],
      ['Completion Rate', '${tasks.isEmpty ? 0 : ((completedTasks / tasks.length) * 100).toStringAsFixed(1)}%'],
      ['Total Points', totalPoints],
      [],
      ['Enrolled Classes'],
      [
        'Class Name',
        'Category',
        'Type',
        'Start Date',
        'Status',
      ],
    ];

    for (var classItem in classes) {
      rows.add([
        classItem.title,
        classItem.category ?? 'N/A',
        classItem.type.name,
        classItem.startDate != null ? _dateFormat.format(classItem.startDate!) : 'N/A',
        classItem.status.name,
      ]);
    }

    rows.addAll([
      [],
      ['Recent Tasks'],
      [
        'Task',
        'Status',
        'Due Date',
        'Completed',
        'Points',
      ],
    ]);

    final recentTasks = tasks..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (var task in recentTasks.take(20)) {
      rows.add([
        task.title,
        task.status.name,
        task.dueDate != null ? _dateFormat.format(task.dueDate!) : 'N/A',
        task.completedAt != null ? _dateFormat.format(task.completedAt!) : 'N/A',
        task.points,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Helper to download CSV (for web)
  String getCsvFileName(String prefix) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${prefix}_$timestamp.csv';
  }

  /// Create a data URI for web download
  String createCsvDataUri(String csvContent) {
    final bytes = utf8.encode(csvContent);
    final base64Str = base64Encode(bytes);
    return 'data:text/csv;base64,$base64Str';
  }
}


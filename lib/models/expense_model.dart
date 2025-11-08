import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

/// Categories for coach business expenses
enum ExpenseCategory {
  @JsonValue('equipment')
  equipment,
  @JsonValue('travel')
  travel,
  @JsonValue('marketing')
  marketing,
  @JsonValue('supplies')
  supplies,
  @JsonValue('software')
  software,
  @JsonValue('insurance')
  insurance,
  @JsonValue('rent')
  rent,
  @JsonValue('utilities')
  utilities,
  @JsonValue('professional_development')
  professionalDevelopment,
  @JsonValue('other')
  other,
}

/// Payment methods for expenses
enum ExpensePaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('debit_card')
  debitCard,
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('check')
  check,
  @JsonValue('other')
  other,
}

/// Model for tracking coach business expenses
@JsonSerializable(explicitToJson: true)
class Expense {
  final String id;
  final String coachId;
  final String category;
  final String description;
  final double amount;
  final String currency;
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime date;
  
  final String paymentMethod;
  final String? receiptUrl;
  final String? notes;
  final bool isRecurring;
  final String? recurringFrequency; // 'monthly', 'yearly', etc.
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime createdAt;
  
  @JsonKey(fromJson: _fromTimestampNullable, toJson: _toTimestampNullable)
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.coachId,
    required this.category,
    required this.description,
    required this.amount,
    this.currency = 'USD',
    required this.date,
    required this.paymentMethod,
    this.receiptUrl,
    this.notes,
    this.isRecurring = false,
    this.recurringFrequency,
    required this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  Expense copyWith({
    String? id,
    String? coachId,
    String? category,
    String? description,
    double? amount,
    String? currency,
    DateTime? date,
    String? paymentMethod,
    String? receiptUrl,
    String? notes,
    bool? isRecurring,
    String? recurringFrequency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  static dynamic _toTimestamp(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  static DateTime? _fromTimestampNullable(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  static dynamic _toTimestampNullable(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

/// Helper class for expense statistics
class ExpenseStats {
  final double totalExpenses;
  final Map<String, double> expensesByCategory;
  final Map<String, double> expensesByMonth;
  final double averageMonthlyExpenses;

  ExpenseStats({
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.expensesByMonth,
    required this.averageMonthlyExpenses,
  });

  factory ExpenseStats.fromExpenses(List<Expense> expenses) {
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final expensesByCategory = <String, double>{};
    for (var expense in expenses) {
      expensesByCategory[expense.category] = 
        (expensesByCategory[expense.category] ?? 0) + expense.amount;
    }

    final expensesByMonth = <String, double>{};
    for (var expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      expensesByMonth[monthKey] = 
        (expensesByMonth[monthKey] ?? 0) + expense.amount;
    }

    final averageMonthlyExpenses = expensesByMonth.isEmpty
        ? 0.0
        : totalExpenses / expensesByMonth.length;

    return ExpenseStats(
      totalExpenses: totalExpenses,
      expensesByCategory: expensesByCategory,
      expensesByMonth: expensesByMonth,
      averageMonthlyExpenses: averageMonthlyExpenses,
    );
  }
}


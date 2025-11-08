// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String,
  coachId: json['coachId'] as String,
  category: json['category'] as String,
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  date: Expense._fromTimestamp(json['date']),
  paymentMethod: json['paymentMethod'] as String,
  receiptUrl: json['receiptUrl'] as String?,
  notes: json['notes'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringFrequency: json['recurringFrequency'] as String?,
  createdAt: Expense._fromTimestamp(json['createdAt']),
  updatedAt: Expense._fromTimestampNullable(json['updatedAt']),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'coachId': instance.coachId,
  'category': instance.category,
  'description': instance.description,
  'amount': instance.amount,
  'currency': instance.currency,
  'date': Expense._toTimestamp(instance.date),
  'paymentMethod': instance.paymentMethod,
  'receiptUrl': instance.receiptUrl,
  'notes': instance.notes,
  'isRecurring': instance.isRecurring,
  'recurringFrequency': instance.recurringFrequency,
  'createdAt': Expense._toTimestamp(instance.createdAt),
  'updatedAt': Expense._toTimestampNullable(instance.updatedAt),
};

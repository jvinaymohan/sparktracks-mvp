// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  userId: json['userId'] as String,
  classId: json['classId'] as String?,
  taskId: json['taskId'] as String?,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  type: $enumDecode(_$PaymentTypeEnumMap, json['type']),
  status:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
      PaymentStatus.pending,
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  transactionId: json['transactionId'] as String?,
  notes: json['notes'] as String?,
  receiptUrl: json['receiptUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  processedBy: json['processedBy'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'classId': instance.classId,
  'taskId': instance.taskId,
  'amount': instance.amount,
  'currency': instance.currency,
  'type': _$PaymentTypeEnumMap[instance.type]!,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'transactionId': instance.transactionId,
  'notes': instance.notes,
  'receiptUrl': instance.receiptUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'processedBy': instance.processedBy,
  'metadata': instance.metadata,
};

const _$PaymentTypeEnumMap = {
  PaymentType.classFee: 'class_fee',
  PaymentType.taskReward: 'task_reward',
  PaymentType.bonus: 'bonus',
  PaymentType.refund: 'refund',
  PaymentType.penalty: 'penalty',
  PaymentType.adjustment: 'adjustment',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.cancelled: 'cancelled',
  PaymentStatus.refunded: 'refunded',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.bankTransfer: 'bank_transfer',
  PaymentMethod.digitalWallet: 'digital_wallet',
  PaymentMethod.points: 'points',
};

PaymentSummary _$PaymentSummaryFromJson(Map<String, dynamic> json) =>
    PaymentSummary(
      userId: json['userId'] as String,
      classId: json['classId'] as String?,
      totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      outstandingBalance:
          (json['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
      lastPaymentDate: DateTime.parse(json['lastPaymentDate'] as String),
      recentPayments:
          (json['recentPayments'] as List<dynamic>?)
              ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PaymentSummaryToJson(PaymentSummary instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'classId': instance.classId,
      'totalDue': instance.totalDue,
      'totalPaid': instance.totalPaid,
      'outstandingBalance': instance.outstandingBalance,
      'totalTransactions': instance.totalTransactions,
      'lastPaymentDate': instance.lastPaymentDate.toIso8601String(),
      'recentPayments': instance.recentPayments,
    };

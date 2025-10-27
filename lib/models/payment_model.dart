import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

enum PaymentType {
  @JsonValue('class_fee')
  classFee,
  @JsonValue('task_reward')
  taskReward,
  @JsonValue('bonus')
  bonus,
  @JsonValue('refund')
  refund,
  @JsonValue('penalty')
  penalty,
  @JsonValue('adjustment')
  adjustment,
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
}

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('digital_wallet')
  digitalWallet,
  @JsonValue('points')
  points,
}

@JsonSerializable()
class Payment {
  final String id;
  final String userId;
  final String? classId;
  final String? taskId;
  final double amount;
  final String currency;
  final PaymentType type;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? notes;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? processedBy;
  final Map<String, dynamic> metadata;

  Payment({
    required this.id,
    required this.userId,
    this.classId,
    this.taskId,
    required this.amount,
    required this.currency,
    required this.type,
    this.status = PaymentStatus.pending,
    required this.method,
    this.transactionId,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.processedBy,
    this.metadata = const {},
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  Payment copyWith({
    String? id,
    String? userId,
    String? classId,
    String? taskId,
    double? amount,
    String? currency,
    PaymentType? type,
    PaymentStatus? status,
    PaymentMethod? method,
    String? transactionId,
    String? notes,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? processedBy,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      classId: classId ?? this.classId,
      taskId: taskId ?? this.taskId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      status: status ?? this.status,
      method: method ?? this.method,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      processedBy: processedBy ?? this.processedBy,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class PaymentSummary {
  final String userId;
  final String? classId;
  final double totalDue;
  final double totalPaid;
  final double outstandingBalance;
  final int totalTransactions;
  final DateTime lastPaymentDate;
  final List<Payment> recentPayments;

  PaymentSummary({
    required this.userId,
    this.classId,
    this.totalDue = 0.0,
    this.totalPaid = 0.0,
    this.outstandingBalance = 0.0,
    this.totalTransactions = 0,
    required this.lastPaymentDate,
    this.recentPayments = const [],
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) => _$PaymentSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentSummaryToJson(this);
}

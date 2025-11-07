import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'invoice_model.g.dart';

enum InvoiceStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('sent')
  sent,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
  @JsonValue('cancelled')
  cancelled,
}

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('venmo')
  venmo,
  @JsonValue('zelle')
  zelle,
  @JsonValue('check')
  check,
  @JsonValue('other')
  other,
}

@JsonSerializable(explicitToJson: true)
class Invoice {
  final String id;
  final String coachId;
  final String studentId;
  final String studentName;
  final String parentEmail;
  
  // Invoice Details
  final String invoiceNumber;
  final List<InvoiceLineItem> lineItems;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String currency;
  
  // Status & Dates
  final InvoiceStatus status;
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime issueDate;
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime dueDate;
  @JsonKey(fromJson: _fromTimestampNullable, toJson: _toTimestampNullable)
  final DateTime? paidDate;
  
  // Payment Info
  final PaymentMethod? paymentMethod;
  final String? transactionId;
  final String? notes;

  Invoice({
    required this.id,
    required this.coachId,
    required this.studentId,
    required this.studentName,
    required this.parentEmail,
    required this.invoiceNumber,
    required this.lineItems,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.currency = 'USD',
    this.status = InvoiceStatus.draft,
    required this.issueDate,
    required this.dueDate,
    this.paidDate,
    this.paymentMethod,
    this.transactionId,
    this.notes,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static Timestamp _toTimestamp(DateTime date) => Timestamp.fromDate(date);

  static DateTime? _fromTimestampNullable(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return null;
  }

  static Timestamp? _toTimestampNullable(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

@JsonSerializable()
class InvoiceLineItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) => _$InvoiceLineItemFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceLineItemToJson(this);
}

@JsonSerializable()
class CoachFinancialStats {
  final String coachId;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final int totalStudents;
  final int activeStudents;
  final double averageSessionPrice;
  final Map<String, double> revenueByMonth;
  final Map<String, int> studentsByClass;
  final double outstandingBalance;
  final int pendingInvoices;

  CoachFinancialStats({
    required this.coachId,
    this.totalRevenue = 0,
    this.totalExpenses = 0,
    this.netProfit = 0,
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.averageSessionPrice = 0,
    this.revenueByMonth = const {},
    this.studentsByClass = const {},
    this.outstandingBalance = 0,
    this.pendingInvoices = 0,
  });

  factory CoachFinancialStats.fromJson(Map<String, dynamic> json) => _$CoachFinancialStatsFromJson(json);
  Map<String, dynamic> toJson() => _$CoachFinancialStatsToJson(this);
}


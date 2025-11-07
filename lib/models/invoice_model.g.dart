// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  id: json['id'] as String,
  coachId: json['coachId'] as String,
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  parentEmail: json['parentEmail'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  lineItems: (json['lineItems'] as List<dynamic>)
      .map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: (json['subtotal'] as num).toDouble(),
  discount: (json['discount'] as num?)?.toDouble() ?? 0,
  tax: (json['tax'] as num?)?.toDouble() ?? 0,
  total: (json['total'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  status:
      $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']) ??
      InvoiceStatus.draft,
  issueDate: Invoice._fromTimestamp(json['issueDate']),
  dueDate: Invoice._fromTimestamp(json['dueDate']),
  paidDate: Invoice._fromTimestampNullable(json['paidDate']),
  paymentMethod: $enumDecodeNullable(
    _$PaymentMethodEnumMap,
    json['paymentMethod'],
  ),
  transactionId: json['transactionId'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'coachId': instance.coachId,
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'parentEmail': instance.parentEmail,
  'invoiceNumber': instance.invoiceNumber,
  'lineItems': instance.lineItems.map((e) => e.toJson()).toList(),
  'subtotal': instance.subtotal,
  'discount': instance.discount,
  'tax': instance.tax,
  'total': instance.total,
  'currency': instance.currency,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'issueDate': Invoice._toTimestamp(instance.issueDate),
  'dueDate': Invoice._toTimestamp(instance.dueDate),
  'paidDate': Invoice._toTimestampNullable(instance.paidDate),
  'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod],
  'transactionId': instance.transactionId,
  'notes': instance.notes,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.sent: 'sent',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.cancelled: 'cancelled',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.venmo: 'venmo',
  PaymentMethod.zelle: 'zelle',
  PaymentMethod.check: 'check',
  PaymentMethod.other: 'other',
};

InvoiceLineItem _$InvoiceLineItemFromJson(Map<String, dynamic> json) =>
    InvoiceLineItem(
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );

Map<String, dynamic> _$InvoiceLineItemToJson(InvoiceLineItem instance) =>
    <String, dynamic>{
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'total': instance.total,
    };

CoachFinancialStats _$CoachFinancialStatsFromJson(Map<String, dynamic> json) =>
    CoachFinancialStats(
      coachId: json['coachId'] as String,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      activeStudents: (json['activeStudents'] as num?)?.toInt() ?? 0,
      averageSessionPrice:
          (json['averageSessionPrice'] as num?)?.toDouble() ?? 0,
      revenueByMonth:
          (json['revenueByMonth'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      studentsByClass:
          (json['studentsByClass'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      outstandingBalance: (json['outstandingBalance'] as num?)?.toDouble() ?? 0,
      pendingInvoices: (json['pendingInvoices'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CoachFinancialStatsToJson(
  CoachFinancialStats instance,
) => <String, dynamic>{
  'coachId': instance.coachId,
  'totalRevenue': instance.totalRevenue,
  'totalExpenses': instance.totalExpenses,
  'netProfit': instance.netProfit,
  'totalStudents': instance.totalStudents,
  'activeStudents': instance.activeStudents,
  'averageSessionPrice': instance.averageSessionPrice,
  'revenueByMonth': instance.revenueByMonth,
  'studentsByClass': instance.studentsByClass,
  'outstandingBalance': instance.outstandingBalance,
  'pendingInvoices': instance.pendingInvoices,
};

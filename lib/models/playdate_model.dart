import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playdate_model.g.dart';

/// Playdate event model - coordinate activities with other families
@JsonSerializable(explicitToJson: true)
class Playdate {
  final String id;
  final String title;
  final String description;
  final String organizerId; // Parent who created it
  final String organizerName;
  
  // Activity Details
  final String activityType; // 'park', 'class', 'sports', 'playdate', 'party', 'study_group'
  final String location;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  
  // Timing
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime startTime;
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime endTime;
  
  // Participants
  final List<PlaydateInvite> invites;
  final int maxParticipants;
  final int currentParticipants;
  
  // Coordination
  final bool needsTransportation;
  final List<TransportationOffer> transportationOffers;
  
  // Expenses
  final bool hasSharedExpenses;
  final List<String> expenseIds; // References to SharedExpense collection
  
  // Status
  final PlaydateStatus status;
  final String? cancellationReason;
  
  // Metadata
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime createdAt;
  
  @JsonKey(fromJson: _fromTimestampNullable, toJson: _toTimestampNullable)
  final DateTime? updatedAt;
  
  final String? imageUrl;
  final List<String> tags; // 'outdoor', 'educational', 'sports', etc.

  Playdate({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    required this.activityType,
    required this.location,
    this.locationAddress,
    this.latitude,
    this.longitude,
    required this.startTime,
    required this.endTime,
    this.invites = const [],
    this.maxParticipants = 20,
    this.currentParticipants = 1,
    this.needsTransportation = false,
    this.transportationOffers = const [],
    this.hasSharedExpenses = false,
    this.expenseIds = const [],
    this.status = PlaydateStatus.upcoming,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.tags = const [],
  });

  factory Playdate.fromJson(Map<String, dynamic> json) => _$PlaydateFromJson(json);
  Map<String, dynamic> toJson() => _$PlaydateToJson(this);

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _toTimestamp(DateTime dateTime) => dateTime.toIso8601String();

  static DateTime? _fromTimestampNullable(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return null;
  }

  static dynamic _toTimestampNullable(DateTime? dateTime) => dateTime?.toIso8601String();
}

/// Playdate status
enum PlaydateStatus {
  @JsonValue('upcoming')
  upcoming,
  
  @JsonValue('confirmed')
  confirmed,
  
  @JsonValue('in_progress')
  inProgress,
  
  @JsonValue('completed')
  completed,
  
  @JsonValue('cancelled')
  cancelled,
}

/// Invitation to a playdate
@JsonSerializable()
class PlaydateInvite {
  final String parentId;
  final String parentName;
  final List<String> childIds; // Children invited
  final List<String> childNames;
  final RSVPStatus status;
  final String? notes;
  final DateTime invitedAt;
  final DateTime? respondedAt;

  PlaydateInvite({
    required this.parentId,
    required this.parentName,
    required this.childIds,
    required this.childNames,
    this.status = RSVPStatus.pending,
    this.notes,
    required this.invitedAt,
    this.respondedAt,
  });

  factory PlaydateInvite.fromJson(Map<String, dynamic> json) => _$PlaydateInviteFromJson(json);
  Map<String, dynamic> toJson() => _$PlaydateInviteToJson(this);
}

/// RSVP status
enum RSVPStatus {
  @JsonValue('pending')
  pending,
  
  @JsonValue('accepted')
  accepted,
  
  @JsonValue('declined')
  declined,
  
  @JsonValue('maybe')
  maybe,
}

/// Transportation offer for a playdate
@JsonSerializable()
class TransportationOffer {
  final String parentId;
  final String parentName;
  final String direction; // 'pickup', 'dropoff', 'both'
  final int availableSeats;
  final List<String> route; // List of stops/addresses
  final String? vehicleInfo; // Optional: "Blue Honda Civic"
  final String? phoneNumber;
  final List<String> acceptedByParentIds; // Who's taking this offer

  TransportationOffer({
    required this.parentId,
    required this.parentName,
    required this.direction,
    required this.availableSeats,
    this.route = const [],
    this.vehicleInfo,
    this.phoneNumber,
    this.acceptedByParentIds = const [],
  });

  factory TransportationOffer.fromJson(Map<String, dynamic> json) => _$TransportationOfferFromJson(json);
  Map<String, dynamic> toJson() => _$TransportationOfferToJson(this);

  int get remainingSeats => availableSeats - acceptedByParentIds.length;
  bool get isFull => remainingSeats <= 0;
}

/// Shared expense for a playdate
@JsonSerializable(explicitToJson: true)
class SharedExpense {
  final String id;
  final String playdateId;
  final String paidById; // Parent who paid
  final String paidByName;
  final double totalAmount;
  final String currency;
  final String description;
  final String category; // 'food', 'tickets', 'supplies', 'transportation', 'other'
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime date;
  
  final String? receiptUrl;
  
  // Splitting
  final SplitType splitType;
  final Map<String, double> splits; // parentId -> amount owed
  final Map<String, bool> paidStatus; // parentId -> has paid
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime createdAt;

  SharedExpense({
    required this.id,
    required this.playdateId,
    required this.paidById,
    required this.paidByName,
    required this.totalAmount,
    this.currency = 'USD',
    required this.description,
    required this.category,
    required this.date,
    this.receiptUrl,
    this.splitType = SplitType.equal,
    required this.splits,
    required this.paidStatus,
    required this.createdAt,
  });

  factory SharedExpense.fromJson(Map<String, dynamic> json) => _$SharedExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$SharedExpenseToJson(this);

  double getAmountOwed(String parentId) => splits[parentId] ?? 0.0;
  bool hasPaid(String parentId) => paidStatus[parentId] ?? false;
  
  int get totalPaid => paidStatus.values.where((paid) => paid).length;
  int get totalParticipants => splits.length;
  double get totalCollected => splits.entries
      .where((entry) => paidStatus[entry.key] == true)
      .fold(0.0, (sum, entry) => sum + entry.value);
  double get remainingBalance => totalAmount - totalCollected;

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _toTimestamp(DateTime dateTime) => dateTime.toIso8601String();
}

/// How to split expenses
enum SplitType {
  @JsonValue('equal')
  equal, // Split equally among all participants
  
  @JsonValue('custom')
  custom, // Custom amounts per person
  
  @JsonValue('percentage')
  percentage, // Percentage-based split
  
  @JsonValue('per_child')
  perChild, // Split based on number of children
}

/// Running balance between two parents
@JsonSerializable()
class ParentBalance {
  final String parent1Id;
  final String parent2Id;
  final double balance; // Positive if parent1 owes parent2, negative if parent2 owes parent1
  final List<String> relatedExpenseIds;
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime updatedAt;

  ParentBalance({
    required this.parent1Id,
    required this.parent2Id,
    required this.balance,
    required this.relatedExpenseIds,
    required this.updatedAt,
  });

  factory ParentBalance.fromJson(Map<String, dynamic> json) => _$ParentBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$ParentBalanceToJson(this);

  String getBalanceMessage(String currentParentId) {
    if (balance == 0) return 'All settled up!';
    
    final amount = balance.abs();
    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    
    if (currentParentId == parent1Id) {
      return balance > 0 
        ? 'You owe $formattedAmount' 
        : 'They owe you $formattedAmount';
    } else {
      return balance > 0 
        ? 'They owe you $formattedAmount' 
        : 'You owe $formattedAmount';
    }
  }

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _toTimestamp(DateTime dateTime) => dateTime.toIso8601String();
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coin_wallet_model.g.dart';

/// Virtual Coins Economy - Teaching Financial Literacy!
/// Kids earn coins by completing tasks and can save for classes
@JsonSerializable(explicitToJson: true)
class CoinWallet {
  final String id; // userId
  final String userId;
  final double balance; // Current coin balance
  final double totalEarned; // All-time earnings
  final double totalSpent; // All-time spending
  final double totalGifted; // Coins received as gifts
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime createdAt;
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime updatedAt;
  
  // Statistics
  final int tasksCompleted; // Tasks that earned coins
  final int streakBonusCount; // Times earned streak bonus
  final int levelUpBonusCount; // Times earned level bonus

  CoinWallet({
    required this.id,
    required this.userId,
    this.balance = 0.0,
    this.totalEarned = 0.0,
    this.totalSpent = 0.0,
    this.totalGifted = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.tasksCompleted = 0,
    this.streakBonusCount = 0,
    this.levelUpBonusCount = 0,
  });

  factory CoinWallet.fromJson(Map<String, dynamic> json) => _$CoinWalletFromJson(json);
  Map<String, dynamic> toJson() => _$CoinWalletToJson(this);

  CoinWallet copyWith({
    String? id,
    String? userId,
    double? balance,
    double? totalEarned,
    double? totalSpent,
    double? totalGifted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? tasksCompleted,
    int? streakBonusCount,
    int? levelUpBonusCount,
  }) {
    return CoinWallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      totalGifted: totalGifted ?? this.totalGifted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      streakBonusCount: streakBonusCount ?? this.streakBonusCount,
      levelUpBonusCount: levelUpBonusCount ?? this.levelUpBonusCount,
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
}

/// Transaction types
enum CoinTransactionType {
  @JsonValue('earned')
  earned, // From task completion
  
  @JsonValue('spent')
  spent, // Redeemed for reward
  
  @JsonValue('bonus')
  bonus, // Streak bonus, level bonus
  
  @JsonValue('gift')
  gift, // Parent gifted coins
  
  @JsonValue('penalty')
  penalty, // Parent deducted coins
  
  @JsonValue('refund')
  refund, // Refund from class cancellation
  
  @JsonValue('class_redemption')
  classRedemption, // Spent on class enrollment
}

/// Individual coin transaction
@JsonSerializable(explicitToJson: true)
class CoinTransaction {
  final String id;
  final String walletId;
  final String userId;
  final double amount; // Positive for earning, negative for spending
  final CoinTransactionType type;
  final String source; // 'task_completion', 'streak_bonus', 'parent_gift', etc.
  final String? description;
  final String? relatedId; // Task ID, Class ID, etc.
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime timestamp;
  
  // Metadata
  final Map<String, dynamic> metadata; // Additional context

  CoinTransaction({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.source,
    this.description,
    this.relatedId,
    required this.timestamp,
    this.metadata = const {},
  });

  factory CoinTransaction.fromJson(Map<String, dynamic> json) => _$CoinTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$CoinTransactionToJson(this);

  bool get isPositive => amount > 0;
  bool get isNegative => amount < 0;

  String get displayAmount {
    final prefix = isPositive ? '+' : '';
    return '$prefix${amount.toInt()} coins';
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
}

/// Conversion rates and settings
class CoinEconomySettings {
  // Default conversion: 1 task point = 10 coins
  static const double pointsToCoinMultiplier = 10.0;
  
  // Bonus multipliers
  static const double streakBonusPerDay = 10.0; // 10 coins per day in streak
  static const double levelUpBonus = 100.0; // 100 coins per level
  
  // Class pricing (in coins)
  static const double coinValueInDollars = 0.01; // 100 coins = $1
  
  // Parent can gift coins
  static const double maxParentGiftPerDay = 500.0;
  
  // Savings thresholds
  static const double encouragementThreshold = 0.8; // Show "almost there!" at 80%
}


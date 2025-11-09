// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinWallet _$CoinWalletFromJson(Map<String, dynamic> json) => CoinWallet(
  id: json['id'] as String,
  userId: json['userId'] as String,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
  totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
  totalGifted: (json['totalGifted'] as num?)?.toDouble() ?? 0.0,
  createdAt: CoinWallet._fromTimestamp(json['createdAt']),
  updatedAt: CoinWallet._fromTimestamp(json['updatedAt']),
  tasksCompleted: (json['tasksCompleted'] as num?)?.toInt() ?? 0,
  streakBonusCount: (json['streakBonusCount'] as num?)?.toInt() ?? 0,
  levelUpBonusCount: (json['levelUpBonusCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CoinWalletToJson(CoinWallet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'balance': instance.balance,
      'totalEarned': instance.totalEarned,
      'totalSpent': instance.totalSpent,
      'totalGifted': instance.totalGifted,
      'createdAt': CoinWallet._toTimestamp(instance.createdAt),
      'updatedAt': CoinWallet._toTimestamp(instance.updatedAt),
      'tasksCompleted': instance.tasksCompleted,
      'streakBonusCount': instance.streakBonusCount,
      'levelUpBonusCount': instance.levelUpBonusCount,
    };

CoinTransaction _$CoinTransactionFromJson(Map<String, dynamic> json) =>
    CoinTransaction(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$CoinTransactionTypeEnumMap, json['type']),
      source: json['source'] as String,
      description: json['description'] as String?,
      relatedId: json['relatedId'] as String?,
      timestamp: CoinTransaction._fromTimestamp(json['timestamp']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CoinTransactionToJson(CoinTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'walletId': instance.walletId,
      'userId': instance.userId,
      'amount': instance.amount,
      'type': _$CoinTransactionTypeEnumMap[instance.type]!,
      'source': instance.source,
      'description': instance.description,
      'relatedId': instance.relatedId,
      'timestamp': CoinTransaction._toTimestamp(instance.timestamp),
      'metadata': instance.metadata,
    };

const _$CoinTransactionTypeEnumMap = {
  CoinTransactionType.earned: 'earned',
  CoinTransactionType.spent: 'spent',
  CoinTransactionType.bonus: 'bonus',
  CoinTransactionType.gift: 'gift',
  CoinTransactionType.penalty: 'penalty',
  CoinTransactionType.refund: 'refund',
  CoinTransactionType.classRedemption: 'class_redemption',
};

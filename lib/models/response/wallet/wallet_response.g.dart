// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletResponse _$WalletResponseFromJson(Map<String, dynamic> json) =>
    WalletResponse(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      totalBalance: (json['totalBalance'] as num).toInt(),
      availableBalance: (json['availableBalance'] as num).toInt(),
      lastUpdated: WalletResponse._dateTimeFromString(
        json['lastUpdated'] as String,
      ),
      createdAt: WalletResponse._dateTimeFromString(
        json['createdAt'] as String,
      ),
      version: (json['__v'] as num).toInt(),
    );

Map<String, dynamic> _$WalletResponseToJson(WalletResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'totalBalance': instance.totalBalance,
      'availableBalance': instance.availableBalance,
      'lastUpdated': WalletResponse._dateTimeToString(instance.lastUpdated),
      'createdAt': WalletResponse._dateTimeToString(instance.createdAt),
      '__v': instance.version,
    };

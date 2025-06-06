// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllTransactionResponse _$GetAllTransactionResponseFromJson(
  Map<String, dynamic> json,
) => GetAllTransactionResponse(
  count: (json['count'] as num).toInt(),
  transactionResponse: (json['transactionResponse'] as List<dynamic>)
      .map((e) => TransactionResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetAllTransactionResponseToJson(
  GetAllTransactionResponse instance,
) => <String, dynamic>{
  'count': instance.count,
  'transactionResponse': instance.transactionResponse,
};

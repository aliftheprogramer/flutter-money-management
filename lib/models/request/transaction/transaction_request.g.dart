// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionRequest _$TransactionRequestFromJson(Map<String, dynamic> json) =>
    TransactionRequest(
      transactionName: json['transactionName'] as String,
      amount: json['amount'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$TransactionRequestToJson(TransactionRequest instance) =>
    <String, dynamic>{
      'transactionName': instance.transactionName,
      'amount': instance.amount,
      'category': instance.category,
    };

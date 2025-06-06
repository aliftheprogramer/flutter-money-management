// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionResponse _$TransactionResponseFromJson(Map<String, dynamic> json) =>
    TransactionResponse(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      categoryId: CategoryResponse.fromJson(
        json['categoryId'] as Map<String, dynamic>,
      ),
      type: json['type'] as String,
      transactionName: json['transactionName'] as String,
      amount: (json['amount'] as num).toInt(),
      category: json['category'] as String,
      note: json['note'] as String,
      date: TransactionResponse._dateTimeFromString(json['date'] as String),
      createdAt: TransactionResponse._dateTimeFromString(
        json['createdAt'] as String,
      ),
      version: (json['__v'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionResponseToJson(
  TransactionResponse instance,
) => <String, dynamic>{
  '_id': instance.id,
  'userId': instance.userId,
  'categoryId': instance.categoryId,
  'type': instance.type,
  'transactionName': instance.transactionName,
  'amount': instance.amount,
  'category': instance.category,
  'note': instance.note,
  'date': TransactionResponse._dateTimeToString(instance.date),
  'createdAt': TransactionResponse._dateTimeToString(instance.createdAt),
  '__v': instance.version,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_response_by_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetResponse _$BudgetResponseFromJson(
  Map<String, dynamic> json,
) => BudgetResponse(
  id: json['_id'] as String,
  userId: json['userId'] as String,
  amount: (json['amount'] as num).toInt(),
  period: json['period'] as String,
  category: json['category'] as String,
  startDate: BudgetResponse._dateTimeFromString(json['startDate'] as String),
  endDate: BudgetResponse._nullableDateTimeFromString(
    json['endDate'] as String?,
  ),
  createdAt: BudgetResponse._dateTimeFromString(json['createdAt'] as String),
  version: (json['__v'] as num).toInt(),
  spent: (json['spent'] as num).toInt(),
  remaining: (json['remaining'] as num).toInt(),
  percentage: (json['percentage'] as num).toInt(),
  status: json['status'] as String,
);

Map<String, dynamic> _$BudgetResponseToJson(BudgetResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'amount': instance.amount,
      'period': instance.period,
      'category': instance.category,
      'startDate': BudgetResponse._dateTimeToString(instance.startDate),
      'endDate': BudgetResponse._nullableDateTimeToString(instance.endDate),
      'createdAt': BudgetResponse._dateTimeToString(instance.createdAt),
      '__v': instance.version,
      'spent': instance.spent,
      'remaining': instance.remaining,
      'percentage': instance.percentage,
      'status': instance.status,
    };

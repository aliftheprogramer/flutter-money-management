// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetRequest _$BudgetRequestFromJson(Map<String, dynamic> json) =>
    BudgetRequest(
      amount: json['amount'] as String,
      period: json['period'] as String,
      category: json['category'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );

Map<String, dynamic> _$BudgetRequestToJson(BudgetRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'period': instance.period,
      'category': instance.category,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
    };

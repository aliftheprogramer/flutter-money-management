// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_response_all.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllBudgetsResponse _$GetAllBudgetsResponseFromJson(
  Map<String, dynamic> json,
) => GetAllBudgetsResponse(
  budgets: (json['budgets'] as List<dynamic>)
      .map((e) => BudgetResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetAllBudgetsResponseToJson(
  GetAllBudgetsResponse instance,
) => <String, dynamic>{'budgets': instance.budgets};

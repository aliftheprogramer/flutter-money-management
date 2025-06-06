import 'package:json_annotation/json_annotation.dart';
import 'package:money_management/models/response/budget/budget_response_by_id.dart';

part 'budget_response_all.g.dart';

@JsonSerializable()
class GetAllBudgetsResponse {
  final List<BudgetResponse> budgets;

  GetAllBudgetsResponse({required this.budgets});

  // Special factory for when the response is directly an array of budgets
  factory GetAllBudgetsResponse.fromJsonArray(List<dynamic> json) =>
      GetAllBudgetsResponse(
        budgets: json
            .map((e) => BudgetResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  // Regular factory for when the response might have a wrapper object
  factory GetAllBudgetsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllBudgetsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllBudgetsResponseToJson(this);
}

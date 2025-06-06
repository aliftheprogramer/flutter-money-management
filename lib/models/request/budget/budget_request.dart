import 'package:json_annotation/json_annotation.dart';

part 'budget_request.g.dart';

@JsonSerializable()
class BudgetRequest {
  final String amount;
  final String period;
  final String category;
  final String startDate;
  final String endDate;

  BudgetRequest({
    required this.amount,
    required this.period,
    required this.category,
    required this.startDate,
    required this.endDate,
  });

  factory BudgetRequest.fromJson(Map<String, dynamic> json) =>
      _$BudgetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetRequestToJson(this);
}

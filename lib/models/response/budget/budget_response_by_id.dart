import 'package:json_annotation/json_annotation.dart';

part 'budget_response_by_id.g.dart';

@JsonSerializable()
class BudgetResponse {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  final int amount;
  final String period;
  final String category;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime startDate;
  @JsonKey(
    fromJson: _nullableDateTimeFromString,
    toJson: _nullableDateTimeToString,
  )
  final DateTime? endDate;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime createdAt;
  @JsonKey(name: '__v')
  final int version;
  final int spent;
  final int remaining;
  final int percentage;
  final String status;

  BudgetResponse({
    required this.id,
    required this.userId,
    required this.amount,
    required this.period,
    required this.category,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.version,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.status,
  });

  factory BudgetResponse.fromJson(Map<String, dynamic> json) =>
      _$BudgetResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetResponseToJson(this);

  // Date conversion helpers
  static DateTime _dateTimeFromString(String date) => DateTime.parse(date);
  static String _dateTimeToString(DateTime date) => date.toIso8601String();

  // Nullable date conversion helpers
  static DateTime? _nullableDateTimeFromString(String? date) =>
      date != null ? DateTime.parse(date) : null;
  static String? _nullableDateTimeToString(DateTime? date) =>
      date?.toIso8601String();
}

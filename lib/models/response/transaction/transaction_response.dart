import 'package:json_annotation/json_annotation.dart';
import 'package:money_management/models/response/transaction/category_response.dart';

part 'transaction_response.g.dart';

@JsonSerializable()
class TransactionResponse {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  final CategoryResponse categoryId;
  final String type;
  final String transactionName;
  final int amount;
  final String category;
  final String note;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime date;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime createdAt;
  @JsonKey(name: '__v')
  final int version;

  TransactionResponse({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.transactionName,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.version,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionResponseToJson(this);

  static DateTime _dateTimeFromString(String date) => DateTime.parse(date);
  static String _dateTimeToString(DateTime date) => date.toIso8601String();
}

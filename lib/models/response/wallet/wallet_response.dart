import 'package:json_annotation/json_annotation.dart';

part 'wallet_response.g.dart';

@JsonSerializable()
class WalletResponse {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  final int totalBalance;
  final int availableBalance;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime lastUpdated;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime createdAt;
  @JsonKey(name: '__v')
  final int version;

  WalletResponse({
    required this.id,
    required this.userId,
    required this.totalBalance,
    required this.availableBalance,
    required this.lastUpdated,
    required this.createdAt,
    required this.version,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletResponseToJson(this);

  // Date conversion helpers
  static DateTime _dateTimeFromString(String date) => DateTime.parse(date);
  static String _dateTimeToString(DateTime date) => date.toIso8601String();
}

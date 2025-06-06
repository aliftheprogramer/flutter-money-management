import 'package:json_annotation/json_annotation.dart';

part 'transaction_request.g.dart';

@JsonSerializable()
class TransactionRequest {
  final String transactionName;
  final String amount;
  final String category;

  TransactionRequest({
    required this.transactionName,
    required this.amount,
    required this.category,
  });

  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionRequestToJson(this);
}

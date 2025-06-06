import 'package:json_annotation/json_annotation.dart';
import 'package:money_management/models/response/transaction/transaction_response.dart';

part 'get_all_transaction_response.g.dart';

@JsonSerializable()
class GetAllTransactionResponse {
  final int count;
  final List<TransactionResponse> transactionResponse;

  GetAllTransactionResponse({
    required this.count,
    required this.transactionResponse,
  });

  factory GetAllTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllTransactionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllTransactionResponseToJson(this);
}

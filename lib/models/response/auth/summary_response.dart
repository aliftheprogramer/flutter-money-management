import 'package:json_annotation/json_annotation.dart';

part 'summary_response.g.dart';

@JsonSerializable()
class SummaryResponse {
  final Summary summary;
  final List<MonthlySummary> monthlySummary;
  final DebugInfo debug;

  SummaryResponse({
    required this.summary,
    required this.monthlySummary,
    required this.debug,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SummaryResponseToJson(this);
}

@JsonSerializable()
class Summary {
  final TransactionTypeSummary pengeluaran;
  final TransactionTypeSummary pemasukan;

  Summary({required this.pengeluaran, required this.pemasukan});

  factory Summary.fromJson(Map<String, dynamic> json) =>
      _$SummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SummaryToJson(this);
}

@JsonSerializable()
class TransactionTypeSummary {
  final int total;
  final int count;

  TransactionTypeSummary({required this.total, required this.count});

  factory TransactionTypeSummary.fromJson(Map<String, dynamic> json) =>
      _$TransactionTypeSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionTypeSummaryToJson(this);
}

@JsonSerializable()
class MonthlySummary {
  final int year;
  final int month;
  final String type;
  final int total;
  final int count;

  MonthlySummary({
    required this.year,
    required this.month,
    required this.type,
    required this.total,
    required this.count,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlySummaryToJson(this);
}

@JsonSerializable()
class DebugInfo {
  final String requestedUserId;
  final String tokenUserId;
  final TransactionExist transactionsExist;

  DebugInfo({
    required this.requestedUserId,
    required this.tokenUserId,
    required this.transactionsExist,
  });

  factory DebugInfo.fromJson(Map<String, dynamic> json) =>
      _$DebugInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DebugInfoToJson(this);
}

@JsonSerializable()
class TransactionExist {
  @JsonKey(name: '_id')
  final String id;

  TransactionExist({required this.id});

  factory TransactionExist.fromJson(Map<String, dynamic> json) =>
      _$TransactionExistFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionExistToJson(this);
}

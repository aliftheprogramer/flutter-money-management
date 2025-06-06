// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SummaryResponse _$SummaryResponseFromJson(Map<String, dynamic> json) =>
    SummaryResponse(
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
      monthlySummary: (json['monthlySummary'] as List<dynamic>)
          .map((e) => MonthlySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      debug: DebugInfo.fromJson(json['debug'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SummaryResponseToJson(SummaryResponse instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'monthlySummary': instance.monthlySummary,
      'debug': instance.debug,
    };

Summary _$SummaryFromJson(Map<String, dynamic> json) => Summary(
  pengeluaran: TransactionTypeSummary.fromJson(
    json['pengeluaran'] as Map<String, dynamic>,
  ),
  pemasukan: TransactionTypeSummary.fromJson(
    json['pemasukan'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SummaryToJson(Summary instance) => <String, dynamic>{
  'pengeluaran': instance.pengeluaran,
  'pemasukan': instance.pemasukan,
};

TransactionTypeSummary _$TransactionTypeSummaryFromJson(
  Map<String, dynamic> json,
) => TransactionTypeSummary(
  total: (json['total'] as num).toInt(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$TransactionTypeSummaryToJson(
  TransactionTypeSummary instance,
) => <String, dynamic>{'total': instance.total, 'count': instance.count};

MonthlySummary _$MonthlySummaryFromJson(Map<String, dynamic> json) =>
    MonthlySummary(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      type: json['type'] as String,
      total: (json['total'] as num).toInt(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$MonthlySummaryToJson(MonthlySummary instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'type': instance.type,
      'total': instance.total,
      'count': instance.count,
    };

DebugInfo _$DebugInfoFromJson(Map<String, dynamic> json) => DebugInfo(
  requestedUserId: json['requestedUserId'] as String,
  tokenUserId: json['tokenUserId'] as String,
  transactionsExist: TransactionExist.fromJson(
    json['transactionsExist'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$DebugInfoToJson(DebugInfo instance) => <String, dynamic>{
  'requestedUserId': instance.requestedUserId,
  'tokenUserId': instance.tokenUserId,
  'transactionsExist': instance.transactionsExist,
};

TransactionExist _$TransactionExistFromJson(Map<String, dynamic> json) =>
    TransactionExist(id: json['_id'] as String);

Map<String, dynamic> _$TransactionExistToJson(TransactionExist instance) =>
    <String, dynamic>{'_id': instance.id};

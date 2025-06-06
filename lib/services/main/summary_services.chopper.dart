// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$SummaryServices extends SummaryServices {
  _$SummaryServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = SummaryServices;

  @override
  Future<Response<dynamic>> getSummary(String id) {
    final Uri $url = Uri.parse('api/user/summary/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}

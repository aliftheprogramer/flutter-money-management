// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$UserServices extends UserServices {
  _$UserServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = UserServices;

  @override
  Future<Response<dynamic>> getUserProfile(String id) {
    final Uri $url = Uri.parse('api/user/profile/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateUserProfile(
    String id,
    Map<String, dynamic> profileData,
  ) {
    final Uri $url = Uri.parse('api/user/profile/${id}');
    final $body = profileData;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserSummary(String id) {
    final Uri $url = Uri.parse('api/user/summary/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}

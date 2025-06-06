// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$MainServices extends MainServices {
  _$MainServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = MainServices;

  @override
  Future<Response<dynamic>> getDashboardData() {
    final Uri $url = Uri.parse('api/dashboard');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getCategories() {
    final Uri $url = Uri.parse('api/categories');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserProfile() {
    final Uri $url = Uri.parse('api/user/profile');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) {
    final Uri $url = Uri.parse('api/user/profile');
    final $body = profileData;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}

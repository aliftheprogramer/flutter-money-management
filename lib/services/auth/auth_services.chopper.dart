// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AuthServices extends AuthServices {
  _$AuthServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AuthServices;

  @override
  Future<Response<dynamic>> login(LoginRequest loginRequst) {
    final Uri $url = Uri.parse('api/auth/login');
    final $body = loginRequst;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> register(RegisterRequest registerRequest) {
    final Uri $url = Uri.parse('api/auth/register');
    final $body = registerRequest;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}

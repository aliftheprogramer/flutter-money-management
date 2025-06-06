// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$WalletServices extends WalletServices {
  _$WalletServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = WalletServices;

  @override
  Future<Response<dynamic>> getWalletInfo() {
    final Uri $url = Uri.parse('api/wallet/info');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}

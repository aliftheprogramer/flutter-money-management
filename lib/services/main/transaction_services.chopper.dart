// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$TransactionServices extends TransactionServices {
  _$TransactionServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = TransactionServices;

  @override
  Future<Response<dynamic>> getAllTransactionsByDate() {
    final Uri $url = Uri.parse('api/main/transactions/by-date');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAllTransactionsByAmount() {
    final Uri $url = Uri.parse('api/main/transactions/by-amount');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAllExpenseTransactions() {
    final Uri $url = Uri.parse('api/main/transaction/pengeluaran');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAllIncomeTransactions() {
    final Uri $url = Uri.parse('api/main/transaction/pemasukan');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getTransactionById(String id) {
    final Uri $url = Uri.parse('api/main/transaction/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createExpenseTransaction(
    TransactionRequest transactionRequest,
  ) {
    final Uri $url = Uri.parse('api/main/transaction/pengeluaran');
    final $body = transactionRequest;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createIncomeTransaction(
    TransactionRequest transactionRequest,
  ) {
    final Uri $url = Uri.parse('api/main/transaction/pemasukan');
    final $body = transactionRequest;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateTransaction(
    String id,
    TransactionRequest transactionRequest,
  ) {
    final Uri $url = Uri.parse('api/main/transaction/${id}');
    final $body = transactionRequest;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteTransaction(String id) {
    final Uri $url = Uri.parse('api/main/transaction/${id}');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}

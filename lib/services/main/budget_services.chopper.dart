// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$BudgetServices extends BudgetServices {
  _$BudgetServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = BudgetServices;

  @override
  Future<Response<dynamic>> getAllBudgets() {
    final Uri $url = Uri.parse('api/budget');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getBudgetAlerts() {
    final Uri $url = Uri.parse('api/budget/alerts');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getBudgetById(String id) {
    final Uri $url = Uri.parse('api/budget/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createBudget(BudgetRequest budgetRequest) {
    final Uri $url = Uri.parse('api/budget');
    final $body = budgetRequest;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateBudget(
    String id,
    BudgetRequest budgetRequest,
  ) {
    final Uri $url = Uri.parse('api/budget/${id}');
    final $body = budgetRequest;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteBudget(String id) {
    final Uri $url = Uri.parse('api/budget/${id}');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}

import 'package:chopper/chopper.dart';
import 'package:money_management/models/request/budget/budget_request.dart';
import 'package:money_management/services/api_client.dart';

part 'budget_services.chopper.dart';

@ChopperApi(baseUrl: 'api/budget')
abstract class BudgetServices extends ChopperService {
  // Get all budgets
  @GET()
  Future<Response<dynamic>> getAllBudgets();

  // Get budget alerts
  @GET(path: '/alerts')
  Future<Response<dynamic>> getBudgetAlerts();

  // Get budget by ID
  @GET(path: '/{id}')
  Future<Response<dynamic>> getBudgetById(@Path('id') String id);

  // Create new budget
  @POST()
  Future<Response<dynamic>> createBudget(@Body() BudgetRequest budgetRequest);

  // Update budget
  @PUT(path: '/{id}')
  Future<Response<dynamic>> updateBudget(
    @Path('id') String id,
    @Body() BudgetRequest budgetRequest,
  );

  // Delete budget
  @DELETE(path: '/{id}')
  Future<Response<dynamic>> deleteBudget(@Path('id') String id);

  static Future<BudgetServices> create() async {
    final client = await ApiClient().getClient();
    return _$BudgetServices(client);
  }
}

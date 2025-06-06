import 'package:chopper/chopper.dart';
import 'package:money_management/models/request/transaction/transaction_request.dart';
import 'package:money_management/services/api_client.dart';

part 'transaction_services.chopper.dart';

@ChopperApi(baseUrl: 'api/main')
abstract class TransactionServices extends ChopperService {
  // GET all transactions by filters
  @GET(path: '/transactions/by-date')
  Future<Response<dynamic>> getAllTransactionsByDate();

  @GET(path: '/transactions/by-amount')
  Future<Response<dynamic>> getAllTransactionsByAmount();

  // GET transactions by type
  @GET(path: '/transaction/pengeluaran')
  Future<Response<dynamic>> getAllExpenseTransactions();

  @GET(path: '/transaction/pemasukan')
  Future<Response<dynamic>> getAllIncomeTransactions();

  // GET transaction by ID
  @GET(path: '/transaction/{id}')
  Future<Response<dynamic>> getTransactionById(@Path('id') String id);

  // Create new transaction
  @POST(path: '/transaction/pengeluaran')
  Future<Response<dynamic>> createExpenseTransaction(
    @Body() TransactionRequest transactionRequest,
  );

  @POST(path: '/transaction/pemasukan')
  Future<Response<dynamic>> createIncomeTransaction(
    @Body() TransactionRequest transactionRequest,
  );

  // Update transaction
  @PUT(path: '/transaction/{id}')
  Future<Response<dynamic>> updateTransaction(
    @Path('id') String id,
    @Body() TransactionRequest transactionRequest,
  );

  // Delete transaction
  @DELETE(path: '/transaction/{id}')
  Future<Response<dynamic>> deleteTransaction(@Path('id') String id);

  static Future<TransactionServices> create() async {
    final client = await ApiClient().getClient();
    return _$TransactionServices(client);
  }
}

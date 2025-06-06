import 'package:chopper/chopper.dart';
import 'package:money_management/services/api_client.dart';

part 'summary_services.chopper.dart';

@ChopperApi(baseUrl: 'api/user')
abstract class SummaryServices extends ChopperService {
  // GET account summary data
  @GET(path: '/summary/{id}')
  Future<Response<dynamic>> getSummary(@Path('id') String id);

  static Future<SummaryServices> create() async {
    final client = await ApiClient().getClient();
    return _$SummaryServices(client);
  }
}

import 'package:chopper/chopper.dart';
import 'package:money_management/services/api_client.dart';

part 'wallet_services.chopper.dart';

@ChopperApi(baseUrl: 'api/wallet')
abstract class WalletServices extends ChopperService {
  // Get wallet information
  @GET(path: '/info')
  Future<Response<dynamic>> getWalletInfo();

  static Future<WalletServices> create() async {
    final client = await ApiClient().getClient();
    return _$WalletServices(client);
  }
}

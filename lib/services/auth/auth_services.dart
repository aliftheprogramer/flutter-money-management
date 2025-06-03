import 'package:chopper/chopper.dart';
import 'package:money_management/models/request/auth/login_request.dart';
import 'package:money_management/models/request/auth/register_request.dart';
import 'package:money_management/services/api_client.dart';

part 'auth_services.chopper.dart';

@ChopperApi(baseUrl: 'api')
abstract class AuthServices extends ChopperService {
  @POST(path: '/auth/login')
  Future<Response<dynamic>> login(@Body() LoginRequest loginRequst);

  @POST(path: '/auth/register')
  Future<Response<dynamic>> register(@Body() RegisterRequest registerRequest);

  static Future<AuthServices> create() async {
    final client = await ApiClient().getClient();
    return _$AuthServices(client);
  }
}

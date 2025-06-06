import 'package:chopper/chopper.dart';
import 'package:money_management/services/api_client.dart';

part 'user_services.chopper.dart';

@ChopperApi(baseUrl: 'api/user')
abstract class UserServices extends ChopperService {
  // Get user profile
  @GET(path: '/profile/{id}')
  Future<Response<dynamic>> getUserProfile(@Path('id') String id);

  // Update user profile
  @PUT(path: '/profile/{id}')
  Future<Response<dynamic>> updateUserProfile(
    @Path('id') String id,
    @Body() Map<String, dynamic> profileData,
  );

  // Get user summary
  @GET(path: '/summary/{id}')
  Future<Response<dynamic>> getUserSummary(@Path('id') String id);

  static Future<UserServices> create() async {
    final client = await ApiClient().getClient();
    return _$UserServices(client);
  }
}

import 'package:chopper/chopper.dart';
import 'package:money_management/services/api_client.dart';

part 'main_services.chopper.dart';

@ChopperApi(baseUrl: 'api')
abstract class MainServices extends ChopperService {
  // GET user dashboard data (combines multiple data types)
  @GET(path: '/dashboard')
  Future<Response<dynamic>> getDashboardData();

  // GET user categories
  @GET(path: '/categories')
  Future<Response<dynamic>> getCategories();

  // GET user profile info
  @GET(path: '/user/profile')
  Future<Response<dynamic>> getUserProfile();

  // Update user profile
  @PUT(path: '/user/profile')
  Future<Response<dynamic>> updateUserProfile(
    @Body() Map<String, dynamic> profileData,
  );

  static Future<MainServices> create() async {
    final client = await ApiClient().getClient();
    return _$MainServices(client);
  }
}

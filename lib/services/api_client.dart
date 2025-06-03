import 'package:chopper/chopper.dart';
import 'package:money_management/services/auth/token_services.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  ChopperClient? _client;
  final TokenService _tokenService = TokenService();

  static const String baseApiUrl =
      'https://beetle-sincere-obviously.ngrok-free.app';
  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  Future<ChopperClient> getClient() async {
    if (_client == null) {
      final token = await _tokenService.getToken();

      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _client = ChopperClient(
        baseUrl: Uri.parse(baseApiUrl),
        converter: JsonConverter(),
        interceptors: [
          HttpLoggingInterceptor(),
          if (headers.isNotEmpty) HeadersInterceptor(headers),
        ],
      );
    }
    return _client!;
  }

  Future<void> resetClient() async {
    _client = null;
    await getClient();
  }
}

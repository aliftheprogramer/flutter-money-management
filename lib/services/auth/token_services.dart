import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class TokenService {
  static const String TOKEN_KEY = 'auth_token';

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Delete token
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
  }

  // Check if token is valid
  Future<bool> isTokenValid() async {
    final token = await getToken();

    if (token == null) {
      return false;
    }

    try {
      // Check if token is expired
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final bool isExpired = JwtDecoder.isExpired(token);

      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  // Create a method to handle token expiration globally
  static void handleTokenExpiration(BuildContext context) async {
    final tokenService = TokenService();
    if (!await tokenService.isTokenValid()) {
      // Show a message to the user about session expiration
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );

      await tokenService.deleteToken();

      // Navigate to login screen and clear stack
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // Get decoded token
  Future<Map<String, dynamic>> getDecodedToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {};
    }

    try {
      final decoded = JwtDecoder.decode(token);
      Logger().d("Decoded token: $decoded"); // Debug the token content
      return decoded;
    } catch (e) {
      Logger().e("Error decoding token: $e");
      return {};
    }
  }
}

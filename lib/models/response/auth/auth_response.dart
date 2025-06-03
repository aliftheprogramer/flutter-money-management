import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String message;
  final String token;
  final Map<String, dynamic> user;
  final String? status;
  final String? error;

  AuthResponse({
    required this.message,
    required this.token,
    required this.user,
    required this.status,
    required this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

import 'dart:convert';
import 'api_client.dart';

class AuthApi {
  /// POST /auth/login
  /// [identifier] can be email or phone number.
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final res = await ApiClient.post(
      '/auth/login',
      body: {'identifier': identifier, 'password': password},
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST /auth/register  (form-encoded)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final res = await ApiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      },
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

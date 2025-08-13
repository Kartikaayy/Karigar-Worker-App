import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://callkaarigar.onrender.com/api";

  /// Fetch user profile with authentication token
  static Future<Map<String, dynamic>?> getUserProfile(String token) async {
    final url = Uri.parse("$baseUrl/users/profile");

    if (token.isEmpty) {
      print("❌ No token provided for getUserProfile()");
      return null;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // Better than forcing Content-Type
        },
      );

      print("📡 API Request → GET $url");
      print("🔑 Token: $token");
      print("📨 Status Code: ${response.statusCode}");
      print("📨 Response: ${response.body}");

      switch (response.statusCode) {
        case 200:
          return jsonDecode(response.body);

        case 401:
          print("⚠️ Unauthorized – token might be expired or invalid.");
          return {
            'error': 'unauthorized',
            'message': 'Token expired or invalid. Please log in again.'
          };

        default:
          print("⚠️ API Error – Status: ${response.statusCode}");
          return {
            'error': 'unknown_error',
            'message': 'Unexpected error occurred: ${response.body}'
          };
      }
    } catch (e) {
      print("❌ Exception in getUserProfile(): $e");
      return {
        'error': 'exception',
        'message': e.toString(),
      };
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

// Recommended: Use a config file for production apps.
const String _baseUrl = "https://callkaargarapi.rahulsh.me/api";

class ApiService {
  /// Fetches a user's profile using an authentication token.
  /// Returns a Map containing user data on success, or an error map on failure.
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    if (token.isEmpty) {
      return {'error': 'no_token', 'message': 'Authentication token is missing.'};
    }

    final url = Uri.parse("$_baseUrl/users/me");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print("📡 API Request → GET $url");
        print("🔑 Token: $token");
        print("📨 Status Code: ${response.statusCode}");
        print("📨 Response Body: ${response.body}");
      }

      final dynamic data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // This log was incorrect based on the API response,
        // as the 'workerProfileId' field is not present here.
        // if (kDebugMode && data is Map<String, dynamic> && data["workerProfileId"] != null) {
        //   print("🆔 Worker Profile ID: ${data["workerProfileId"]}");
        // }
        return data as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        return {
          'error': 'unauthorized',
          'message': 'Session expired. Please log in again.',
        };
      } else {
        return {
          'error': 'api_error',
          'message': 'Server responded with status code ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ API Exception: $e");
      }
      return {
        'error': 'exception',
        'message': e.toString(),
      };
    }
  }

  /// Fetches a specific worker profile by their user ID.
  /// Returns a Map containing worker profile data on success, or an error map on failure.
  static Future<Map<String, dynamic>> getWorkerProfileById(String workerUserId) async {
    if (workerUserId.isEmpty) {
      return {'error': 'invalid_id', 'message': 'Worker user ID is missing.'};
    }

    // This URL is incorrect. The provided screenshot shows the endpoint is /worker-profile with an ID in the body, but your log shows /worker-profile/user/:id, which is better.
    // The screenshot also shows a GET for all workers. To get a specific worker by user ID, the endpoint should be /worker-profile/user/:id as per your log.

    // final url = Uri.parse("$_baseUrl/worker-profile/user/$workerUserId");
    // The screenshot of Postman shows the endpoint to be `https://callkaarigar.onrender.com/api/worker-profile`
    // but the log in your terminal shows the call is being made to `https://callkaarigar.onrender.com/api/worker-profile/user/:id`.
    // We'll stick with the correct call you were making, since the general endpoint is for all workers.

    final url = Uri.parse("$_baseUrl/worker-profile/user/$workerUserId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print("📡 API Request → GET $url");
        print("📨 Status Code: ${response.statusCode}");
        print("📨 Response Body: ${response.body}");
      }

      final dynamic data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // The API response for a single worker is an array containing one object.
        // We need to return that object, not the whole map.
        if (data is Map<String, dynamic> && data['data'] is List && data['data'].isNotEmpty) {
          return data['data'][0] as Map<String, dynamic>;
        } else {
          return {
            'error': 'not_found',
            'message': 'Worker profile not found.',
          };
        }
      } else {
        return {
          'error': 'api_error',
          'message': 'Failed to fetch worker profile. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ API Exception: $e");
      }
      return {
        'error': 'exception',
        'message': e.toString(),
      };
    }
  }
}
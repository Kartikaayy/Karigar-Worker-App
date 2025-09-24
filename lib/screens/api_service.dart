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

  // static Future<Map<String, dynamic>> createAddress(
  //     String token,
  //     Map<String, dynamic> addressData
  //     ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/addresses'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode({
  //         'label': addressData['label'] ?? 'Home',
  //         'addressLine': addressData['addressLine'],
  //         'city': addressData['city'],
  //         'state': addressData['state'],
  //         'postalCode': addressData['postalCode'],
  //         'country': addressData['country'],
  //         'isPrimary': addressData['isPrimary'] ?? false,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return {
  //         'success': true,
  //         'data': json.decode(response.body),
  //         'message': 'Address created successfully'
  //       };
  //     } else {
  //       final errorData = json.decode(response.body);
  //       return {
  //         'error': 'create_failed',
  //         'message': errorData['message'] ?? 'Failed to create address',
  //         'statusCode': response.statusCode
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'error': 'network_error',
  //       'message': 'Network error: ${e.toString()}'
  //     };
  //   }
  // }
  //
  // /// Get user's specific addresses
  // /// GET /addresses/my-addresses/{workerId}
  // static Future<Map<String, dynamic>> getUserAddresses(
  //     String token,
  //     String workerId
  //     ) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/addresses/my-addresses'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       return {
  //         'success': true,
  //         'addresses': responseData['addresses'] ?? responseData['data'] ?? [],
  //         'message': 'Addresses fetched successfully'
  //       };
  //     } else if (response.statusCode == 404) {
  //       // No addresses found - this is not an error, just empty list
  //       return {
  //         'success': true,
  //         'addresses': [],
  //         'message': 'No addresses found'
  //       };
  //     } else {
  //       final errorData = json.decode(response.body);
  //       return {
  //         'error': 'fetch_failed',
  //         'message': errorData['message'] ?? 'Failed to fetch addresses',
  //         'statusCode': response.statusCode
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'error': 'network_error',
  //       'message': 'Network error: ${e.toString()}'
  //     };
  //   }
  // }
  //
  // /// Update an existing address (Full Update)
  // /// PUT /addresses/my-addresses/{workerId}
  // static Future<Map<String, dynamic>> updateAddress(
  //     String token,
  //     String workerId,
  //     Map<String, dynamic> addressData
  //     ) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('$_baseUrl/addresses/my-addresses/$workerId'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode({
  //         'label': addressData['label'] ?? 'Home',
  //         'addressLine': addressData['addressLine'],
  //         'city': addressData['city'],
  //         'state': addressData['state'],
  //         'postalCode': addressData['postalCode'],
  //         'country': addressData['country'],
  //         'isPrimary': addressData['isPrimary'] ?? false,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return {
  //         'success': true,
  //         'data': json.decode(response.body),
  //         'message': 'Address updated successfully'
  //       };
  //     } else {
  //       final errorData = json.decode(response.body);
  //       return {
  //         'error': 'update_failed',
  //         'message': errorData['message'] ?? 'Failed to update address',
  //         'statusCode': response.statusCode
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'error': 'network_error',
  //       'message': 'Network error: ${e.toString()}'
  //     };
  //   }
  // }
  //
  // /// Delete an address (if needed)
  // /// DELETE /addresses/{addressId}
  // static Future<Map<String, dynamic>> deleteAddress(
  //     String token,
  //     String addressId
  //     ) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse('$_baseUrl/addresses/my-addresses/$addressId'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     if (response.statusCode == 200 || response.statusCode == 204) {
  //       return {
  //         'success': true,
  //         'message': 'Address deleted successfully'
  //       };
  //     } else {
  //       final errorData = json.decode(response.body);
  //       return {
  //         'error': 'delete_failed',
  //         'message': errorData['message'] ?? 'Failed to delete address',
  //         'statusCode': response.statusCode
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'error': 'network_error',
  //       'message': 'Network error: ${e.toString()}'
  //     };
  //   }
  // }
  //
  // /// Set address as primary
  // /// PATCH /addresses/{addressId}/primary
  // static Future<Map<String, dynamic>> setPrimaryAddress(
  //     String token,
  //     String addressId
  //     ) async {
  //   try {
  //     final response = await http.patch(
  //       Uri.parse('$_baseUrl/addresses/$addressId/primary'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return {
  //         'success': true,
  //         'data': json.decode(response.body),
  //         'message': 'Primary address updated successfully'
  //       };
  //     } else {
  //       final errorData = json.decode(response.body);
  //       return {
  //         'error': 'primary_failed',
  //         'message': errorData['message'] ?? 'Failed to set primary address',
  //         'statusCode': response.statusCode
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'error': 'network_error',
  //       'message': 'Network error: ${e.toString()}'
  //     };
  //   }
  // }
  //
  // // Helper method to handle common API response patterns
  // static Map<String, dynamic> _handleResponse(http.Response response, String operation) {
  //   try {
  //     final responseData = json.decode(response.body);
  //
  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return {
  //         'success': true,
  //         'data': responseData,
  //         'message': '$operation completed successfully'
  //       };
  //     } else {
  //       return {
  //         'error': '${operation.toLowerCase()}_failed',
  //         'message': responseData['message'] ?? '$operation failed',
  //         'statusCode': response.statusCode
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'error': 'parse_error',
  //       'message': 'Failed to parse server response: ${e.toString()}'
  //     };
  //   }
  // }
  //
  // // Debug method to log API calls (remove in production)
  // static void _logApiCall(String method, String endpoint, {Map<String, String>? headers, String? body}) {
  //   print('=== API Call ===');
  //   print('Method: $method');
  //   print('Endpoint: $endpoint');
  //   if (headers != null) print('Headers: $headers');
  //   if (body != null) print('Body: $body');
  //   print('===============');
  // }
}

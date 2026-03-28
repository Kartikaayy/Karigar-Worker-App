import 'dart:convert';
import 'api_client.dart';

class UsersApi {
  /// GET /users/me  — returns the logged-in user's profile.
  static Future<Map<String, dynamic>> getMyProfile(String token) async {
    final res = await ApiClient.get('/users/me', token: token);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// GET /worker-profile/user/:id  — returns a worker's profile by user ID.
  static Future<Map<String, dynamic>> getWorkerProfileByUserId(
      String workerUserId) async {
    final res =
        await ApiClient.get('/worker-profile/user/$workerUserId');
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 &&
        data is Map<String, dynamic> &&
        data['data'] is List &&
        (data['data'] as List).isNotEmpty) {
      return data['data'][0] as Map<String, dynamic>;
    }
    return {
      'error': 'not_found',
      'message': 'Worker profile not found.',
      'statusCode': res.statusCode,
    };
  }
}

import 'dart:convert';
import 'api_client.dart';

class PaymentsApi {
  /// GET /payments/worker  — fetches earnings for the logged-in worker.
  static Future<Map<String, dynamic>> getWorkerEarnings(String token) async {
    final res = await ApiClient.get('/payments/worker', token: token);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

class ReviewsApi {
  /// GET /reviews/worker/:workerId  — fetches all reviews for a worker.
  static Future<Map<String, dynamic>> getWorkerReviews({
    required String token,
    required String workerId,
  }) async {
    final res =
        await ApiClient.get('/reviews/worker/$workerId', token: token);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

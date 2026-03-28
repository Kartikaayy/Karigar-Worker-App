import 'dart:convert';
import 'api_client.dart';

class BookingsApi {
  /// GET /bookings/worker  — fetches all bookings for the logged-in worker.
  static Future<Map<String, dynamic>> getWorkerBookings(String token) async {
    final res = await ApiClient.get('/bookings/worker', token: token);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST /bookings/:id/handle-request  — accept or reject a booking.
  /// [action] must be either 'accept' or 'reject'.
  static Future<Map<String, dynamic>> handleBookingRequest({
    required String token,
    required String bookingId,
    required String action, // 'accept' | 'reject'
  }) async {
    final res = await ApiClient.post(
      '/bookings/$bookingId/handle-request',
      token: token,
      body: {'action': action},
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST /bookings/:id/complete  — mark a booking as complete.
  static Future<Map<String, dynamic>> completeBooking({
    required String token,
    required String bookingId,
  }) async {
    final res = await ApiClient.post(
      '/bookings/$bookingId/complete',
      token: token,
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

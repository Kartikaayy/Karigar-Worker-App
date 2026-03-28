import 'dart:convert';
import 'api_client.dart';

class NotificationsApi {
  /// GET /notifications  — fetches all notifications for the logged-in user.
  static Future<Map<String, dynamic>> getNotifications(String token) async {
    final res = await ApiClient.get('/notifications', token: token);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PATCH /notifications/:id/read  — marks a notification as read.
  static Future<void> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    await ApiClient.patch(
      '/notifications/$notificationId/read',
      token: token,
    );
  }

  /// DELETE /notifications/:id  — deletes a notification.
  static Future<void> deleteNotification({
    required String token,
    required String notificationId,
  }) async {
    await ApiClient.delete(
      '/notifications/$notificationId',
      token: token,
    );
  }
}

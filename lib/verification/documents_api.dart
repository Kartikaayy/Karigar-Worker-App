// lib/screens/documents_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DocumentsApi {
  static const String baseUrl =
      'https://callkaarigar.onrender.com/api/worker-documents';

  /// Update worker documents with URLs (PUT request)
  static Future<Map<String, dynamic>?> updateDocumentUrls({
    required String workerId,
    required String aadhaarUrl,
    required String photoUrl,
    required String panUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("No token found.");
        return null;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$workerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "aadhaar": aadhaarUrl,
          "photo": photoUrl,
          "pan": panUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Error updating document URLs: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception while updating document URLs: $e");
      return null;
    }
  }
}

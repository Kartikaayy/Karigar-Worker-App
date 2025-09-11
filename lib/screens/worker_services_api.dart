import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkerServicesApi {
  static const String baseUrl = "https://callkaargarapi.rahulsh.me/api/worker-services";

  /// GET: Fetch all services for a specific worker
  static Future<List<dynamic>> getWorkerServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final workerId = prefs.getString('workerId');

      if (token == null || workerId == null) {
        throw Exception("Token or Worker ID not found in storage");
      }

      final url = Uri.parse("$baseUrl/service/$workerId");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Assuming API returns a list of services
      } else {
        throw Exception("Failed to fetch services: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching services: $e");
    }
  }

  /// POST: Add a new service for a worker
  static Future<bool> addWorkerService(Map<String, dynamic> serviceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final workerId = prefs.getString('workerId');

      if (token == null || workerId == null) {
        throw Exception("Token or Worker ID not found in storage");
      }

      // Ensure workerId is part of the request
      serviceData['workerId'] = workerId;

      final url = Uri.parse(baseUrl);
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Error response: ${response.body}");
        return false;
      }
    } catch (e) {
      throw Exception("Error adding service: $e");
    }
  }
}

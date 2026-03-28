import 'dart:convert';
import 'api_client.dart';

class ServiceCategoriesApi {
  /// GET /service-categories  — fetches all service categories (no auth needed).
  static Future<Map<String, dynamic>> getCategories() async {
    final res = await ApiClient.get('/service-categories');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

class ServicesApi {
  /// GET /services  — fetches all available services (no auth needed).
  static Future<Map<String, dynamic>> getAllServices() async {
    final res = await ApiClient.get('/services');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

class WorkerServicesApi {
  /// GET /worker-services/service/:workerId  — fetches services offered by a worker.
  static Future<List<dynamic>> getWorkerServices({
    required String token,
    required String workerId,
  }) async {
    final res = await ApiClient.get(
      '/worker-services/service/$workerId',
      token: token,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch worker services: ${res.statusCode}');
  }

  /// POST /worker-services  — adds a new service for a worker.
  static Future<bool> addWorkerService({
    required String token,
    required Map<String, dynamic> serviceData,
  }) async {
    final res = await ApiClient.post(
      '/worker-services',
      token: token,
      body: serviceData,
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }
}

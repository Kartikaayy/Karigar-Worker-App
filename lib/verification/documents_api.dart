// lib/screens/documents_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

class DocumentsApi {
  static const String baseUrl =
      'https://call-kaarigar-server.onrender.com/api/worker-documents';

  /// Upload all worker documents in one API call
  static Future<Map<String, dynamic>?> uploadAllDocuments({
    required String workerId,
    required PlatformFile aadhaarFile,
    required PlatformFile photoFile,
    required PlatformFile panFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      request.fields['workerId'] = workerId;

      // Aadhaar
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'aadhaar',
          aadhaarFile.bytes!,
          filename: aadhaarFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'aadhaar',
          aadhaarFile.path!,
        ));
      }

      // Photo
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          photoFile.bytes!,
          filename: photoFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photoFile.path!,
        ));
      }

      // PAN
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'pan',
          panFile.bytes!,
          filename: panFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'pan',
          panFile.path!,
        ));
      }

      // Add Authorization header
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      } else {
        print('No token found.');
        return null;
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseData.body);
      } else {
        print('Error uploading documents: ${responseData.body}');
        return null;
      }
    } catch (e) {
      print('Exception during document upload: $e');
      return null;
    }
  }
}
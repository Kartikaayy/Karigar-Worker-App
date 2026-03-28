import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// ─────────────────────────────────────────────
///  CHANGE YOUR BASE URL HERE — and only here.
/// ─────────────────────────────────────────────
const String kBaseUrl =
    "https://call-karigar-backend-production.up.railway.app/api";

/// A thin HTTP client that automatically:
///   • Prepends [kBaseUrl] to every path
///   • Injects Content-Type and optional Bearer token headers
///   • Logs requests/responses in debug mode
///   • Returns the decoded body or throws on non-2xx
class ApiClient {
  // ── internal helpers ────────────────────────────────────────────────────

  static Map<String, String> _headers({
    String? token,
    bool formEncoded = false,
  }) {
    return {
      if (formEncoded)
        'Content-Type': 'application/x-www-form-urlencoded'
      else
        'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Uri _uri(String path) => Uri.parse("$kBaseUrl$path");

  static void _log(String method, Uri url, int status, String body) {
    if (kDebugMode) {
      print("📡 $method $url  →  $status");
      print("📨 $body");
    }
  }

  // ── public methods ───────────────────────────────────────────────────────

  static Future<http.Response> get(
    String path, {
    String? token,
  }) async {
    final url = _uri(path);
    final res = await http.get(url, headers: _headers(token: token));
    _log("GET", url, res.statusCode, res.body);
    return res;
  }

  static Future<http.Response> post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
    Map<String, String>? formBody,
  }) async {
    final url = _uri(path);
    final res = await http.post(
      url,
      headers: _headers(token: token, formEncoded: formBody != null),
      body: formBody != null ? formBody : (body != null ? jsonEncode(body) : null),
    );
    _log("POST", url, res.statusCode, res.body);
    return res;
  }

  static Future<http.Response> patch(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final url = _uri(path);
    final res = await http.patch(
      url,
      headers: _headers(token: token),
      body: body != null ? jsonEncode(body) : null,
    );
    _log("PATCH", url, res.statusCode, res.body);
    return res;
  }

  static Future<http.Response> delete(
    String path, {
    String? token,
  }) async {
    final url = _uri(path);
    final res = await http.delete(url, headers: _headers(token: token));
    _log("DELETE", url, res.statusCode, res.body);
    return res;
  }
}

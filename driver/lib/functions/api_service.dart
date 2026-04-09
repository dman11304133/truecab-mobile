import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'functions.dart';

class ApiService {
  static final String _baseUrl = url;

  static Map<String, String> _getHeaders({bool withAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (withAuth && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${bearerToken[0].token}';
    }
    return headers;
  }

  // The _getAuthOnlyHeaders method is removed as its primary purpose was to include the 'Host' header.

  /// JSON-encoded POST with Content-Type: application/json
  static Future<http.Response> post(String endpoint, dynamic body) async {
    var response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      debugPrint('API POST error ($endpoint): ${response.statusCode} - ${response.body}');
    }
    return response;
  }

  /// Form-encoded POST (for endpoints that don't accept JSON)
  static Future<http.Response> postRaw(
      String endpoint, Map<String, String> body) async {
    return await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {},
      body: body,
    );
  }

  static Future<http.Response> get(String endpoint) async {
    var response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _getHeaders(),
    );
    if (response.statusCode != 200) {
      debugPrint('API GET error ($endpoint): ${response.statusCode} - ${response.body}');
    }
    return response;
  }

  /// Builds a MultipartRequest with auth headers pre-attached
  static http.MultipartRequest buildMultipartRequest(
      String method, String endpoint) {
    var request =
        http.MultipartRequest(method, Uri.parse('$_baseUrl$endpoint'));
    request.headers.addAll({
      'Authorization':
          bearerToken.isNotEmpty ? 'Bearer ${bearerToken[0].token}' : '',
    });
    return request;
  }

  /// Convenience: create a MultipartFile from a file path
  static Future<http.MultipartFile> multipartFile(
      String field, String filePath) async {
    return await http.MultipartFile.fromPath(field, filePath);
  }

  /// Convert a StreamedResponse to a full Response
  static Future<http.Response> responseFromStream(
      http.StreamedResponse streamed) async {
    return await http.Response.fromStream(streamed);
  }
}

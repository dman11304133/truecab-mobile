import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'functions.dart';

class ApiService {
  static final String _baseUrl = url;
  static String get _hostHeader => url.replaceAll('https://', '').replaceAll('http://', '').split('/')[0];

  static Map<String, String> _getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${bearerToken[0].token}';
    }
    return headers;
  }
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

  static Future<http.Response> postRaw(String endpoint, Map<String, dynamic> body) async {
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
}

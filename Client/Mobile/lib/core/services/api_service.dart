import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

/// Lightweight HTTP wrapper around the Renty REST API.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // ── Helpers ──────────────────────────────────────────────────────

  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('${ApiEndpoints.baseUrl}$path');

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ── Public methods ───────────────────────────────────────────────

  /// POST request — returns the decoded JSON body.
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
  }) async {
    String? token;
    if (authenticated) token = await _getToken();

    final response = await http.post(
      _uri(path),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// GET request — returns the decoded JSON body.
  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = false,
  }) async {
    String? token;
    if (authenticated) token = await _getToken();

    final response = await http.get(
      _uri(path),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
  }) async {
    String? token;
    if (authenticated) token = await _getToken();

    final response = await http.put(
      _uri(path),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    bool authenticated = false,
  }) async {
    String? token;
    if (authenticated) token = await _getToken();

    final response = await http.delete(
      _uri(path),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  /// POST with empty body (e.g.  for favorites toggle)
  Future<Map<String, dynamic>> postEmpty(
    String path, {
    bool authenticated = false,
  }) async {
    String? token;
    if (authenticated) token = await _getToken();

    final response = await http.post(
      _uri(path),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  // ── Response handling ────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    // The backend wraps everything in { error, data, messages }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // For error status codes, still return the body so caller can
    // read `messages` array.
    return body;
  }

  // ── File Upload ─────────────────────────────────────────────────

  /// Multipart file upload — returns the decoded JSON body.
  Future<Map<String, dynamic>> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? extraFields,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest('POST', _uri(path));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }
}

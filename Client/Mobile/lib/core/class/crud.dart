import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class Crud {
  /// POST request with optional headers (for authentication)
  Future<Map<String, dynamic>> postRequest(
      String url,
      Map<String, dynamic> data, {
        Map<String, String>? headers,
      }) async {
    try {
      // Prepare request headers
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Add custom headers if provided
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await http.post(
        Uri.parse(url),
        body: data.map((key, value) => MapEntry(key, value.toString())),
        headers: requestHeaders, // FIX: Use the combined headers
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      print("POST Request Error: $e");
      return {
        "status": "error",
        "message": "Network error: ${e.toString()}"
      };
    }
  }

  /// POST request with file upload (for images)
  Future<Map<String, dynamic>> postRequestWithFile(
      String url,
      Map<String, dynamic> data,
      File file, {
        String fileFieldName = "file",
        Map<String, String>? headers,
      }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers if provided - FIXED: Properly handle headers
      if (headers != null) {
        request.headers.addAll(headers);
      } else {
        // Default headers for file upload
        request.headers['Content-Type'] = 'multipart/form-data';
      }

      // Add form fields
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add file
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        fileFieldName,
        stream,
        length,
        filename: basename(file.path),
      );
      request.files.add(multipartFile);

      // Send request
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 60),
        onTimeout: () => throw Exception('Upload timeout'),
      );

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Upload failed: ${response.statusCode}"
        };
      }
    } catch (e) {
      print("File Upload Error: $e");
      return {
        "status": "error",
        "message": "Upload error: ${e.toString()}"
      };
    }
  }

  /// GET request with optional headers - FIXED: Proper header handling
  Future<Map<String, dynamic>> getRequest(
      String url, {
        Map<String, String>? headers,
      }) async {
    try {
      // Prepare request headers
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      // Add custom headers if provided
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      print("GET Request Error: $e");
      return {
        "status": "error",
        "message": "Network error: ${e.toString()}"
      };
    }
  }

  /// DELETE request with optional headers - FIXED: Proper header handling
  Future<Map<String, dynamic>> deleteRequest(
      String url, {
        Map<String, String>? headers,
      }) async {
    try {
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await http.delete(
        Uri.parse(url),
        headers: requestHeaders,
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      print("DELETE Request Error: $e");
      return {
        "status": "error",
        "message": "Network error: ${e.toString()}"
      };
    }
  }

  /// PUT request for updates - NEW: Added PUT method
  Future<Map<String, dynamic>> putRequest(
      String url,
      Map<String, dynamic> data, {
        Map<String, String>? headers,
      }) async {
    try {
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await http.put(
        Uri.parse(url),
        body: data.map((key, value) => MapEntry(key, value.toString())),
        headers: requestHeaders,
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      print("PUT Request Error: $e");
      return {
        "status": "error",
        "message": "Network error: ${e.toString()}"
      };
    }
  }
}
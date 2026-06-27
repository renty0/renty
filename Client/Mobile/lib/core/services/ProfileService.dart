import 'dart:io';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/main.dart';

/// Professional service class to handle all profile-related API calls
/// Migrated from old Crud/AppLink to generated OpenAPI client
class ProfileService {
  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await ApiService.auth.authMe();
      if (response != null && response.data != null) {
        final data = response.data!;
        return {
          'id': data.id,
          'firstName': data.firstName,
          'lastName': data.lastName,
          'email': data.email,
          'phone': data.phone,
          'phoneNumber': data.phone,
          'profileImageUrl': data.profileImageUrl,
          'profilePictureUrl': data.profileImageUrl,
          'city': data.city,
          'address': data.address,
          'country': data.country,
          'bio': data.bio,
          'isVerified': data.isVerified,
          'role': data.role,
        };
      } else {
        throw Exception("Failed to load profile");
      }
    } catch (e) {
      print("Error fetching profile: $e");
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>?> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final command = UpdateUserCommand(
        firstName: name,
        phoneNumber: phone,
      );
      final response = await ApiService.auth.authUpdateMe(command);
      if (response != null && response.error != true) {
        // Re-fetch profile to get updated data
        final profile = await getUserProfile();
        // Update local cache
        if (profile != null) {
          if (profile['firstName'] != null) {
            sharedPref.setString("user_name", profile['firstName']);
          }
          if (profile['phone'] != null) {
            sharedPref.setString("user_phone", profile['phone']);
          }
        }
        return profile;
      } else {
        throw Exception("Failed to update profile");
      }
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }

  /// Upload profile image via media API
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final filePath = imageFile.path;
      final filename = filePath.split(Platform.pathSeparator).last;
      final ext = filename.split('.').last.toLowerCase();
      final mimeSubtype = const {
        'jpg': 'jpeg', 'jpeg': 'jpeg', 'png': 'png',
        'gif': 'gif', 'webp': 'webp', 'bmp': 'bmp', 'heic': 'heic',
      }[ext] ?? 'jpeg';

      final multipartFile = await MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: filename,
        contentType: MediaType('image', mimeSubtype),
      );
      final response = await ApiService.media.uploadMedia(file: multipartFile);
      if (response != null && response.data != null) {
        return response.data!.url;
      } else {
        throw Exception("Failed to upload image");
      }
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Use the auth API's reset password or a dedicated endpoint
      // For now, using the raw API client to hit the change-password endpoint
      final response = await ApiService.client.invokeAPI(
        '/api/v1/auth/change-password',
        'POST',
        [],
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        {},
        {},
        'application/json',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error changing password: $e");
      rethrow;
    }
  }

  /// Validate user session
  Future<bool> validateSession() async {
    try {
      final response = await ApiService.auth.authMe();
      return response != null && response.data != null;
    } catch (e) {
      print("Session validation error: $e");
      return false;
    }
  }

  /// Delete user account permanently
  Future<bool> deleteAccount() async {
    try {
      final response = await ApiService.client.invokeAPI(
        '/api/v1/auth/me',
        'DELETE',
        [],
        null,
        {},
        {},
        null,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error deleting account: $e");
      rethrow;
    }
  }
}
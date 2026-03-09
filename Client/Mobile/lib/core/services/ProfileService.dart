import 'dart:io';
import 'package:renty/core/constant/linkapi.dart';
import 'package:renty/main.dart';
import 'package:renty/core/class/crud.dart';
/// Professional service class to handle all profile-related API calls
class ProfileService {
  final Crud _crud = Crud();

  /// Get authentication headers
  Map<String, String> _getAuthHeaders() {
    final token = sharedPref.getString("token");
    if (token == null || token.isEmpty) {
      throw Exception("No authentication token found. Please login again.");
    }
    return {"Authorization": "Bearer $token"};
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.getProfile,
        {},
        headers: headers,
      );

      if (response["status"] == "success") {
        return response["data"];
      } else {
        print("Profile fetch failed: ${response['message']}");
        throw Exception(response['message'] ?? "Failed to load profile");
      }
    } catch (e) {
      print("Error fetching profile: $e");
      rethrow;
    }
  }

  /// Update user profile (name and phone)
  Future<Map<String, dynamic>?> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final headers = _getAuthHeaders();

      Map<String, String> requestData = {"name": name};
      if (phone != null && phone.isNotEmpty) {
        requestData["phone"] = phone;
      }

      var response = await _crud.postRequest(
        AppLink.updateProfile,
        requestData,
        headers: headers,
      );

      if (response["status"] == "success") {
        // Update local cache
        if (response["data"]["name"] != null) {
          sharedPref.setString("user_name", response["data"]["name"]);
        }
        if (response["data"]["phone"] != null) {
          sharedPref.setString("user_phone", response["data"]["phone"]);
        }
        return response["data"];
      } else {
        print("Profile update failed: ${response['message']}");
        throw Exception(response['message'] ?? "Failed to update profile");
      }
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }

  /// Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequestWithFile(
        AppLink.uploadProfileImage,
        {},
        imageFile,
        fileFieldName: "profile_image",
        headers: headers,
      );

      if (response["status"] == "success") {
        return response["data"]["profile_image"];
      } else {
        print("Image upload failed: ${response['message']}");
        throw Exception(response['message'] ?? "Failed to upload image");
      }
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  /// Delete profile image
  Future<bool> deleteProfileImage() async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.deleteProfileImage,
        {},
        headers: headers,
      );

      if (response["status"] == "success") {
        return true;
      } else {
        print("Image deletion failed: ${response['message']}");
        throw Exception(response['message'] ?? "Failed to delete image");
      }
    } catch (e) {
      print("Error deleting image: $e");
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
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.changePassword,
        {
          "current_password": currentPassword,
          "new_password": newPassword,
          "confirm_password": confirmPassword,
        },
        headers: headers,
      );

      if (response["status"] == "success") {
        return true;
      } else {
        print("Password change failed: ${response['message']}");
        throw Exception(response['message'] ?? "Failed to change password");
      }
    } catch (e) {
      print("Error changing password: $e");
      rethrow;
    }
  }

  /// Validate user session
  Future<bool> validateSession() async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.validateSession,
        {},
        headers: headers,
      );

      return response["status"] == "success";
    } catch (e) {
      print("Session validation error: $e");
      return false;
    }
  }

  /// Delete user account permanently
  Future<bool> deleteAccount() async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.deleteAccount,
        {},
        headers: headers,
      );

      if (response["status"] == "success") {
        return true;
      } else {
        print("Account deletion failed: ${response['message']}");
        throw Exception(response['message'] ?? "Failed to delete account");
      }
    } catch (e) {
      print("Error deleting account: $e");
      rethrow;
    }
  }
}
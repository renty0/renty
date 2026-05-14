import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller handling all authentication logic.
/// Mirrors the web's AuthService.
class AuthController extends GetxController {
  final _api = ApiService.instance;

  // ── Observable state ─────────────────────────────────────────────
  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    isLoggedIn.value = token != null && token.isNotEmpty;
  }

  // ── Login ────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final res = await _api.post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      });

      final error = res['error'] as bool? ?? false;
      final data = res['data'] as Map<String, dynamic>?;
      final messages = (res['messages'] as List?)?.cast<String>() ?? [];

      if (!error && data != null) {
        await _storeTokens(data);
        isLoggedIn.value = true;
        Get.offAllNamed('/');
      } else if (messages.isNotEmpty && messages[0] == 'EmailNotConfirmed') {
        Get.snackbar('Info', 'Please verify your email first',
            snackPosition: SnackPosition.BOTTOM);
        Get.toNamed('/verify-email', arguments: {'email': email});
      } else {
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Invalid credentials',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Register ─────────────────────────────────────────────────────

  Future<void> register(Map<String, dynamic> payload) async {
    isLoading.value = true;
    try {
      final res = await _api.post(ApiEndpoints.register, payload);

      final error = res['error'] as bool? ?? false;
      final messages = (res['messages'] as List?)?.cast<String>() ?? [];

      if (!error) {
        Get.snackbar('Success', 'Registration successful! Please verify your email.',
            snackPosition: SnackPosition.BOTTOM);
        Get.offNamed('/verify-email', arguments: {'email': payload['email']});
      } else {
        // Show ALL validation errors from the API
        final errorMsg = messages.isNotEmpty ? messages.join('\n') : 'Registration failed';
        Get.snackbar('Error', errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5));
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Verify Email ─────────────────────────────────────────────────

  Future<bool> verifyEmail(String email, String code) async {
    isLoading.value = true;
    try {
      final res = await _api.post(ApiEndpoints.verifyEmail, {
        'email': email,
        'code': code,
      });

      final error = res['error'] as bool? ?? false;
      final messages = (res['messages'] as List?)?.cast<String>() ?? [];

      if (!error) {
        Get.snackbar('Success', 'Email verified successfully!',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Verification failed',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Forgot Password ──────────────────────────────────────────────

  Future<bool> forgotPassword(String email) async {
    isLoading.value = true;
    try {
      final res = await _api.post(ApiEndpoints.forgotPassword, {
        'email': email,
      });

      final error = res['error'] as bool? ?? false;
      final messages = (res['messages'] as List?)?.cast<String>() ?? [];

      if (!error) {
        Get.snackbar('Success', 'Password reset code has been sent to your email',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Failed to send reset code',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Verify Reset Code ────────────────────────────────────────────

  Future<bool> verifyResetCode(String email, String token) async {
    isLoading.value = true;
    try {
      final res = await _api.post(ApiEndpoints.verifyResetCode, {
        'email': email,
        'token': token,
      });

      final error = res['error'] as bool? ?? false;
      final messages = (res['messages'] as List?)?.cast<String>() ?? [];

      if (!error) {
        Get.snackbar('Success', 'Code verified!',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Invalid or expired code',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Reset Password ───────────────────────────────────────────────

  Future<void> resetPassword(String email, String token, String newPassword) async {
    isLoading.value = true;
    try {
      final res = await _api.post(ApiEndpoints.resetPassword, {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      });

      final error = res['error'] as bool? ?? false;
      final messages = (res['messages'] as List?)?.cast<String>() ?? [];

      if (!error) {
        Get.snackbar('Success', 'Password reset successfully!',
            snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed('/login');
      } else {
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Failed to reset password',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Send Verification Email ────────────────────────────────────────

  Future<bool> sendVerification(String email) async {
    isLoading.value = true;
    try {
      final res = await _api.post(ApiEndpoints.sendVerification, {
        'email': email,
      });

      final error = res['error'] as bool? ?? false;
      final messages = (res['messages'] as List?)?.cast<String>() ?? [];

      if (!error) {
        Get.snackbar('Success', 'Verification code sent to your email',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Failed to send code',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Refresh Token ─────────────────────────────────────────────────

  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshTkn = prefs.getString('refresh_token');

      if (accessToken == null || refreshTkn == null) return false;

      final res = await _api.post(ApiEndpoints.refresh, {
        'accessToken': accessToken,
        'refreshToken': refreshTkn,
      });

      final error = res['error'] as bool? ?? false;
      final data = res['data'];

      if (!error && data is Map<String, dynamic>) {
        if (data['accessToken'] != null) {
          await prefs.setString('access_token', data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await prefs.setString('refresh_token', data['refreshToken']);
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }

  // ── Private helpers ──────────────────────────────────────────────

  Future<void> _storeTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data['accessToken'] != null) {
      await prefs.setString('access_token', data['accessToken']);
    }
    if (data['refreshToken'] != null) {
      await prefs.setString('refresh_token', data['refreshToken']);
    }
    if (data['user'] != null) {
      // Store user data as JSON string
      await prefs.setString('user_data', data['user'].toString());
    }
  }
}

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for the user profile — load, edit, save, avatar upload.
class ProfileController extends GetxController {
  final _api = ApiService.instance;
  final _picker = ImagePicker();

  // ── User data ─────────────────────────────────────────────────
  final userData = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploading = false.obs;

  // ── Form values ───────────────────────────────────────────────
  final firstName = ''.obs;
  final lastName = ''.obs;
  final email = ''.obs;
  final address = ''.obs;
  final city = ''.obs;
  final country = ''.obs;
  final bio = ''.obs;
  final phone = ''.obs;
  final profilePictureUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // ── Load Profile ──────────────────────────────────────────────

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        ApiEndpoints.me,
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      final data = res['data'];

      if (!error && data is Map<String, dynamic>) {
        userData.value = data;
        _populateFields(data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    firstName.value = data['firstName'] ?? '';
    lastName.value = data['lastName'] ?? '';
    email.value = data['email'] ?? '';
    phone.value = data['phone'] ?? '';
    address.value = data['address'] ?? '';
    city.value = data['city'] ?? '';
    country.value = data['country'] ?? '';
    bio.value = data['bio'] ?? '';
    // Swagger GET /auth/me returns "profileImageUrl"
    profilePictureUrl.value = data['profileImageUrl'] ?? data['profilePictureUrl'] ?? '';
  }

  // ── Update Profile ────────────────────────────────────────────

  Future<void> updateProfile() async {
    isSaving.value = true;
    try {
      final body = <String, dynamic>{
        'firstName': firstName.value,
        'lastName': lastName.value,
        'phoneNumber': phone.value.isEmpty ? null : phone.value,
        'address': address.value.isEmpty ? null : address.value,
        'city': city.value.isEmpty ? null : city.value,
        'country': country.value.isEmpty ? null : country.value,
        'bio': bio.value.isEmpty ? null : bio.value,
        'profilePictureUrl': profilePictureUrl.value.isEmpty
            ? null
            : profilePictureUrl.value,
      };

      final res = await _api.put(
        ApiEndpoints.me,
        body,
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        // Reload profile to get fresh data
        await loadProfile();
        Get.snackbar('Success', 'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        final msg = messages.isNotEmpty ? messages[0] : 'Update failed';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // ── Avatar Upload ─────────────────────────────────────────────

  Future<void> pickAndUploadAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return;

    isUploading.value = true;
    try {
      final res = await _api.uploadFile(
        ApiEndpoints.mediaUpload,
        image.path,
      );

      final data = res['data'];
      if (data is Map<String, dynamic>) {
        final url = data['url'] as String?;
        if (url != null && url.isNotEmpty) {
          profilePictureUrl.value = url;
          Get.snackbar('Success', 'Photo updated',
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload photo',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    Get.offAllNamed('/login');
  }
}

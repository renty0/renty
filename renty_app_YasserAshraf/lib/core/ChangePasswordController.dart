import 'package:get/get.dart';
import 'package:renty/core/services/ProfileService.dart';

class ChangePasswordController extends GetxController {
  final ProfileService _profileService = ProfileService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      isLoading.value = false;
      return success;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}
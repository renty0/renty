import 'package:get/get.dart';
import 'package:renty/core/services/ProfileService.dart';

class DeleteAccountController extends GetxController {
  final ProfileService _profileService = ProfileService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _profileService.deleteAccount();

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
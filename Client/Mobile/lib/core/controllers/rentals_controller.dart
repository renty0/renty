import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';

class RentalsController extends GetxController {
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final rentals = <RentalListDto>[].obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final itemsPerPage = 15;

  // Filter
  final selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRentals();
  }

  Future<void> loadRentals({bool reset = true}) async {
    if (reset) {
      currentPage.value = 1;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await ApiService.rentals.getRentals(
        currentPage.value,
        itemsPerPage,
        status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null,
      );

      if (response != null && response.data != null) {
        final data = response.data!;
        if (reset) {
          rentals.value = data.rentals;
        } else {
          rentals.addAll(data.rentals);
        }
        totalPages.value = data.pages ?? 1;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load rentals';
      print('RentalsController error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadNextPage() {
    if (!isLoadingMore.value && currentPage.value < totalPages.value) {
      currentPage.value++;
      loadRentals(reset: false);
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    loadRentals(reset: true);
  }

  Future<bool> confirmRental(String rentalId) async {
    try {
      final response = await ApiService.rentals.confirmRental(rentalId);
      if (response != null) {
        await loadRentals();
        return true;
      }
      return false;
    } catch (e) {
      print('Error confirming rental: $e');
      Get.snackbar('Error', 'Failed to confirm rental');
      return false;
    }
  }

  Future<bool> activateRental(String rentalId) async {
    try {
      final response = await ApiService.rentals.activateRental(rentalId);
      if (response != null) {
        await loadRentals();
        return true;
      }
      return false;
    } catch (e) {
      print('Error activating rental: $e');
      Get.snackbar('Error', 'Failed to activate rental');
      return false;
    }
  }

  Future<bool> completeRental(String rentalId, {bool damaged = false}) async {
    try {
      final response = await ApiService.rentals.completeRental(rentalId, damaged);
      if (response != null) {
        await loadRentals();
        return true;
      }
      return false;
    } catch (e) {
      print('Error completing rental: $e');
      Get.snackbar('Error', 'Failed to complete rental');
      return false;
    }
  }

  Future<bool> cancelRental(String rentalId) async {
    try {
      final response = await ApiService.rentals.cancelRental(rentalId);
      if (response != null) {
        await loadRentals();
        return true;
      }
      return false;
    } catch (e) {
      print('Error cancelling rental: $e');
      Get.snackbar('Error', 'Failed to cancel rental');
      return false;
    }
  }

  Future<ApiResponseOfRentalCreateDataData?> createRental({
    required String itemId,
    required DateTime startDate,
    required DateTime endDate,
    required String pricingType,
  }) async {
    try {
      final command = CreateRentalCommand(
        itemId: itemId,
        startDate: startDate,
        endDate: endDate,
        pricingType: pricingType,
      );
      final response = await ApiService.rentals.createRental(command);
      if (response != null && response.data != null) {
        Get.snackbar('Success', 'Rental request created!');
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error creating rental: $e');
      Get.snackbar('Error', 'Failed to create rental');
      return null;
    }
  }

  Future<void> refreshRentals() async {
    await loadRentals(reset: true);
  }
}

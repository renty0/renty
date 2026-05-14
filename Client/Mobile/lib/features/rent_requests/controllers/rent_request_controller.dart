import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Rentals — list, create, confirm, activate, complete, cancel.
/// Matches the Swagger Rentals API at /api/v1/rentals.
class RentRequestController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final _api = ApiService.instance;

  // ── Tab Controller ────────────────────────────────────────────
  late TabController tabController;

  // ── Data ──────────────────────────────────────────────────────
  final myRequests = <Map<String, dynamic>>[].obs;
  final receivedRequests = <Map<String, dynamic>>[].obs;
  final selectedRequest = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // ── Create form fields ────────────────────────────────────────
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final message = ''.obs;
  final isDeliveryRequested = false.obs;
  final deliveryAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        _loadCurrentTab();
      }
    });
    loadMyRequests();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void _loadCurrentTab() {
    if (tabController.index == 0) {
      loadMyRequests();
    } else {
      loadReceivedRequests();
    }
  }

  // ── Load My Rentals ───────────────────────────────────────────

  Future<void> loadMyRequests() async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        '${ApiEndpoints.rentals}?page=1&limit=50',
        authenticated: true,
      );
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        final rentals = data['rentals'];
        if (rentals is List) {
          myRequests.value = rentals.cast<Map<String, dynamic>>();
        }
      } else if (data is List) {
        myRequests.value = data.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Silent
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load Received (placeholder — uses same endpoint with different filter)

  Future<void> loadReceivedRequests() async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        '${ApiEndpoints.rentals}?page=1&limit=50',
        authenticated: true,
      );
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        final rentals = data['rentals'];
        if (rentals is List) {
          receivedRequests.value = rentals.cast<Map<String, dynamic>>();
        }
      } else if (data is List) {
        receivedRequests.value = data.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Silent
    } finally {
      isLoading.value = false;
    }
  }

  // ── Get Rental Detail ─────────────────────────────────────────

  Future<void> loadRequestDetail(dynamic id) async {
    isLoading.value = true;
    try {
      final strId = id.toString();
      final res = await _api.get(
        ApiEndpoints.rentalById(strId),
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      final data = res['data'];
      if (!error && data is Map<String, dynamic>) {
        selectedRequest.value = data;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to load rental detail',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create Rental ─────────────────────────────────────────────

  Future<bool> createRequest(String rentableItemId) async {
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar('Error', 'Please select start and end dates',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'itemId': rentableItemId,
        'startDate': startDate.value!.toIso8601String(),
        'endDate': endDate.value!.toIso8601String(),
        'pricingType': 'daily',
      };

      final res = await _api.post(
        ApiEndpoints.rentals,
        body,
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Rental request submitted!',
            snackPosition: SnackPosition.BOTTOM);
        _resetForm();
        loadMyRequests();
        return true;
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        final msg = messages.isNotEmpty ? messages[0] : 'Failed to submit';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to submit request',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Confirm Rental (Owner) ────────────────────────────────────

  Future<void> respondToRequest(dynamic id, bool approve,
      {String? ownerResponse}) async {
    isSubmitting.value = true;
    try {
      final strId = id.toString();
      final endpoint = approve
          ? ApiEndpoints.confirmRental(strId)
          : ApiEndpoints.cancelRental(strId);

      final res = await _api.put(
        endpoint,
        <String, dynamic>{},
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar(
            'Success', approve ? 'Rental confirmed' : 'Rental cancelled',
            snackPosition: SnackPosition.BOTTOM);
        _loadCurrentTab();
        if (selectedRequest.value != null) loadRequestDetail(id);
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Action failed',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Cancel Rental ─────────────────────────────────────────────

  Future<void> cancelRequest(dynamic id, {String? reason}) async {
    isSubmitting.value = true;
    try {
      final strId = id.toString();
      final res = await _api.put(
        ApiEndpoints.cancelRental(strId),
        <String, dynamic>{},
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Rental cancelled',
            snackPosition: SnackPosition.BOTTOM);
        loadMyRequests();
        if (selectedRequest.value != null) loadRequestDetail(id);
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to cancel',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Activate Rental ───────────────────────────────────────────

  Future<void> startRentalAction(dynamic id) async {
    isSubmitting.value = true;
    try {
      final strId = id.toString();
      final res = await _api.put(
        ApiEndpoints.activateRental(strId),
        <String, dynamic>{},
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Rental activated!',
            snackPosition: SnackPosition.BOTTOM);
        _loadCurrentTab();
        if (selectedRequest.value != null) loadRequestDetail(id);
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to activate rental',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Complete Rental ───────────────────────────────────────────

  Future<void> completeRentalAction(dynamic id, {bool damaged = false}) async {
    isSubmitting.value = true;
    try {
      final strId = id.toString();
      final res = await _api.put(
        '${ApiEndpoints.completeRental(strId)}?damaged=$damaged',
        <String, dynamic>{},
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Rental completed!',
            snackPosition: SnackPosition.BOTTOM);
        _loadCurrentTab();
        if (selectedRequest.value != null) loadRequestDetail(id);
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to complete rental',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  void _resetForm() {
    startDate.value = null;
    endDate.value = null;
    message.value = '';
    isDeliveryRequested.value = false;
    deliveryAddress.value = '';
  }

  static String statusLabel(dynamic status) {
    final s = status?.toString().toLowerCase() ?? '';
    switch (s) {
      case 'pending':
      case '1':
        return 'Pending';
      case 'confirmed':
      case '2':
        return 'Confirmed';
      case 'active':
      case '3':
        return 'Active';
      case 'completed':
      case '4':
        return 'Completed';
      case 'cancelled':
      case '5':
        return 'Cancelled';
      default:
        return status?.toString() ?? 'Unknown';
    }
  }

  static Color statusColor(dynamic status) {
    final s = status?.toString().toLowerCase() ?? '';
    switch (s) {
      case 'pending':
      case '1':
        return const Color(0xFFF59E0B); // amber
      case 'confirmed':
      case '2':
        return const Color(0xFF3B82F6); // blue
      case 'active':
      case '3':
        return const Color(0xFF10B981); // emerald
      case 'completed':
      case '4':
        return const Color(0xFF8B5CF6); // purple
      case 'cancelled':
      case '5':
        return const Color(0xFF6B7280); // gray
      default:
        return const Color(0xFF6B7280);
    }
  }
}

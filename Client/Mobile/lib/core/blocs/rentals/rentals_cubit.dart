import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'rentals_state.dart';

class RentalsCubit extends Cubit<RentalsState> {
  static RentalsCubit? _instance;
  static RentalsCubit get instance => _instance ??= RentalsCubit();

  RentalsCubit() : super(const RentalsState()) {
    _instance = this;
  }

  Future<void> loadRentals({bool reset = true}) async {
    if (reset) {
      emit(state.copyWith(
        currentPage: 1,
        isLoading: true,
        errorMessage: '',
      ));
    } else {
      if (state.isLoadingMore) return;
      emit(state.copyWith(isLoadingMore: true, errorMessage: ''));
    }

    try {
      final response = await ApiService.rentals.getRentals(
        state.currentPage,
        state.itemsPerPage,
        status: state.selectedStatus.isNotEmpty ? state.selectedStatus : null,
        role: state.selectedRole,
      );

      if (response != null && response.data != null) {
        final data = response.data!;
        final newRentals = data.rentals;
        final allRentals =
            reset ? newRentals : [...state.rentals, ...newRentals];

        emit(state.copyWith(
          rentals: allRentals,
          totalPages: data.pages ?? 1,
          isLoading: false,
          isLoadingMore: false,
          errorMessage: '',
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      print('RentalsCubit error: $e');
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Failed to load rentals',
      ));
    }
  }

  void loadNextPage() {
    if (!state.isLoadingMore && state.currentPage < state.totalPages) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
      loadRentals(reset: false);
    }
  }

  void filterByStatus(String status) {
    emit(state.copyWith(selectedStatus: status));
    loadRentals(reset: true);
  }

  void changeRole(String role) {
    emit(state.copyWith(selectedRole: role));
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
      AppNavigator.showSnackBar('Error', 'Failed to confirm rental', isError: true);
      return false;
    }
  }

  Future<bool> verifyHandoffCode(String rentalId, String code) async {
    try {
      final response = await ApiService.rentals.verifyTransfer(rentalId, code);
      if (response != null) {
        await loadRentals();
        return true;
      }
      return false;
    } catch (e) {
      print('Error verifying handoff code: $e');
      AppNavigator.showSnackBar('Error', 'Failed to verify handoff code', isError: true);
      return false;
    }
  }

  Future<bool> completeRental(String rentalId, {bool damaged = false}) async {
    try {
      final response =
          await ApiService.rentals.completeRental(rentalId, damaged);
      if (response != null) {
        await loadRentals();
        return true;
      }
      return false;
    } catch (e) {
      print('Error completing rental: $e');
      AppNavigator.showSnackBar('Error', 'Failed to complete rental', isError: true);
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
      AppNavigator.showSnackBar('Error', 'Failed to cancel rental', isError: true);
      return false;
    }
  }

  Future<ApiResponseOfRentalCreateDataData?> createRental({
    required String itemId,
    required DateTime startDate,
    required DateTime endDate,
    required String pricingType,
  }) async {
    return createRentalFull(
      itemId: itemId,
      startDate: startDate,
      endDate: endDate,
      pricingType: pricingType,
    );
  }

  Future<ApiResponseOfRentalCreateDataData?> createRentalFull({
    required String itemId,
    required DateTime startDate,
    required DateTime endDate,
    required String pricingType,
    String? notes,
    bool requestExpertReview = false,
  }) async {
    try {
      final command = CreateRentalRequest(
        itemId: itemId,
        startDate: startDate,
        endDate: endDate,
        pricingType: pricingType.toLowerCase(),
        notes: notes,
        requestExpertReview: requestExpertReview,
      );
      final response = await ApiService.rentals.createRental(command);
      if (response != null && response.data != null) {
        AppNavigator.showSnackBar('Success', 'Rental request submitted!');
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error creating rental: $e');
      AppNavigator.showSnackBar('Error', 'Failed to create rental', isError: true);
      return null;
    }
  }

  Future<void> refreshRentals() async {
    await loadRentals(reset: true);
  }

  @override
  Future<void> close() {
    if (_instance == this) _instance = null;
    return super.close();
  }
}

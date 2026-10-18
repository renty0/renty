import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/core/services/ProfileService.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ProfileService _profileService = ProfileService();

  ChangePasswordCubit() : super(const ChangePasswordState());

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: '', isSuccess: false));

      final success = await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      emit(state.copyWith(
        isLoading: false,
        isSuccess: success,
      ));
      return success;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      ));
      return false;
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: ''));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/core/services/ProfileService.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final ProfileService _profileService = ProfileService();

  DeleteAccountCubit() : super(const DeleteAccountState());

  Future<bool> deleteAccount() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: '', isSuccess: false));

      final success = await _profileService.deleteAccount();

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

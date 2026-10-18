import 'package:equatable/equatable.dart';

class DeleteAccountState extends Equatable {
  final bool isLoading;
  final String errorMessage;
  final bool isSuccess;

  const DeleteAccountState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isSuccess = false,
  });

  DeleteAccountState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return DeleteAccountState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, isSuccess];
}

import 'package:equatable/equatable.dart';

class ChangePasswordState extends Equatable {
  final bool isLoading;
  final String errorMessage;
  final bool isSuccess;

  const ChangePasswordState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isSuccess = false,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, isSuccess];
}

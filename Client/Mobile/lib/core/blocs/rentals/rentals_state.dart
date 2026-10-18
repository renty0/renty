import 'package:equatable/equatable.dart';
import 'package:renty/api/lib/api.dart';

class RentalsState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final List<RentalListDto> rentals;
  final String errorMessage;

  final int currentPage;
  final int totalPages;
  final int itemsPerPage;

  final String selectedStatus;
  final String selectedRole;

  const RentalsState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.rentals = const [],
    this.errorMessage = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.itemsPerPage = 15,
    this.selectedStatus = '',
    this.selectedRole = 'renter',
  });

  RentalsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<RentalListDto>? rentals,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    String? selectedStatus,
    String? selectedRole,
  }) {
    return RentalsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      rentals: rentals ?? this.rentals,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        rentals,
        errorMessage,
        currentPage,
        totalPages,
        itemsPerPage,
        selectedStatus,
        selectedRole,
      ];
}

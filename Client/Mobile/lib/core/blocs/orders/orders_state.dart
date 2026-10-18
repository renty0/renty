import 'package:equatable/equatable.dart';
import 'package:renty/api/lib/api.dart';

class OrdersState extends Equatable {
  final bool isLoading;
  final List<OrderListDto> orders;
  final String errorMessage;

  const OrdersState({
    this.isLoading = true,
    this.orders = const [],
    this.errorMessage = '',
  });

  OrdersState copyWith({
    bool? isLoading,
    List<OrderListDto>? orders,
    String? errorMessage,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, orders, errorMessage];
}

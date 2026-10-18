import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersState());

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      final response = await ApiService.orders.getOrders();
      if (response != null && response.data != null) {
        emit(state.copyWith(
          orders: response.data!.orders,
          isLoading: false,
          errorMessage: '',
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      print('OrdersCubit error: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load orders',
      ));
    }
  }

  Future<String?> createOrder(List<OrderItemInputDto> items) async {
    try {
      final command = CreateOrderCommand(items: items);
      final response = await ApiService.orders.createOrder(command);
      if (response != null && response.data != null) {
        AppNavigator.showSnackBar('Success', 'Order created!');
        await loadOrders();
        return response.data!.orderId;
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      AppNavigator.showSnackBar('Error', 'Failed to create order', isError: true);
      return null;
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }
}

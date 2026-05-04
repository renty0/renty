import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';

class OrdersController extends GetxController {
  final isLoading = true.obs;
  final orders = <OrderListDto>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.orders.getOrders();
      if (response != null && response.data != null) {
        orders.value = response.data!.orders;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load orders';
      print('OrdersController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createOrder(List<OrderItemInputDto> items) async {
    try {
      final command = CreateOrderCommand(items: items);
      final response = await ApiService.orders.createOrder(command);
      if (response != null && response.data != null) {
        Get.snackbar('Success', 'Order created!');
        await loadOrders();
        return response.data!.orderId;
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      Get.snackbar('Error', 'Failed to create order');
      return null;
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }
}

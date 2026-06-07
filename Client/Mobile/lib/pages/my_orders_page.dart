import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/orders_controller.dart';
import 'package:renty/pages/order_detail_page.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('My Orders',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context, controller);
        }

        if (controller.orders.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: AppColor.primaryColor,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(context, controller.orders[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderListDto order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final statusColor = _getStatusColor(order.status ?? '');

    return GestureDetector(
      onTap: () {
        if (order.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(orderId: order.id!),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColor.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.shopping_bag_outlined,
                          size: 20, color: AppColor.primaryColor),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id?.substring(0, 8) ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColor.darkText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          order.createdAt != null
                              ? dateFormat.format(order.createdAt!)
                              : 'Unknown date',
                          style: TextStyle(
                              fontSize: 12, color: isDark ? Colors.white70 : AppColor.mediumText),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    (order.status ?? 'Unknown').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Divider(height: 1, color: AppColor.borderGray),
            SizedBox(height: 12),

            // Footer Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 16, color: isDark ? Colors.white54 : AppColor.grey),
                    SizedBox(width: 4),
                    Text(
                      '${order.itemCount ?? 0} item${(order.itemCount ?? 0) > 1 ? 's' : ''}',
                      style: TextStyle(
                          fontSize: 13, color: isDark ? Colors.white70 : AppColor.mediumText),
                    ),
                  ],
                ),
                Text(
                  'EGP ${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80, color: isDark ? const Color(0xFF334155) : AppColor.borderGray),
          SizedBox(height: 16),
          Text('No Orders Yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColor.darkText)),
          SizedBox(height: 8),
          Text('Your order history will appear here',
              style:
                  TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColor.mediumText)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, OrdersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: AppColor.warningColor),
          SizedBox(height: 16),
          Text(controller.errorMessage.value,
              style:
                  TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColor.mediumText)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshOrders,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor),
            child:
                Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Color(0xFFd97706);
      case 'processing':
        return Color(0xFF2563eb);
      case 'paid':
      case 'delivered':
      case 'completed':
        return AppColor.successColor;
      case 'cancelled':
      case 'failed':
        return AppColor.warningColor;
      case 'shipped':
        return Color(0xFF7c3aed);
      default:
        return AppColor.grey;
    }
  }
}

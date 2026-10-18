import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/pages/order_detail_page.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit()..loadOrders(),
      child: const _MyOrdersPageContent(),
    );
  }
}

class _MyOrdersPageContent extends StatelessWidget {
  const _MyOrdersPageContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<OrdersCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('My Orders'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }

          if (state.errorMessage.isNotEmpty) {
            return _buildErrorState(context, controller, state.errorMessage);
          }

          if (state.orders.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: controller.refreshOrders,
            color: AppColor.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(context, state.orders[index]);
              },
            ),
          );
        },
      ),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColor.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.shopping_bag_outlined,
                          size: 20, color: AppColor.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id != null && order.id!.length >= 8 ? order.id!.substring(0, 8) : order.id ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColor.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.createdAt != null
                              ? dateFormat.format(order.createdAt!)
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark ? Colors.white54 : AppColor.mediumText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    (order.status ?? '').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Items Count & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 16,
                        color: isDark ? Colors.white54 : AppColor.mediumText),
                    const SizedBox(width: 6),
                    Text(
                      '${order.itemCount ?? 0} ${order.itemCount == 1 ? 'item'.tr : 'items'.tr}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColor.mediumText,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Total: '.tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : AppColor.mediumText,
                      ),
                    ),
                    Text(
                      'EGP ${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : AppColor.primaryColor,
                      ),
                    ),
                  ],
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
              size: 80,
              color: isDark ? const Color(0xFF334155) : AppColor.borderGray),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet'.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColor.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here'.tr,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColor.mediumText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, OrdersCubit controller, String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColor.mediumText,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
            ),
            child:
                Text('Retry'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFd97706);
      case 'processing':
        return const Color(0xFF2563eb);
      case 'paid':
      case 'delivered':
      case 'completed':
        return AppColor.successColor;
      case 'cancelled':
      case 'failed':
        return AppColor.warningColor;
      case 'shipped':
        return const Color(0xFF7c3aed);
      default:
        return AppColor.grey;
    }
  }
}

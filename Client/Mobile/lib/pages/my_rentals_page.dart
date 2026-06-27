import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/rentals_controller.dart';
import 'package:renty/pages/rental_detail_page.dart';
import 'package:renty/pages/create_rental_page.dart';

class MyRentalsPage extends StatelessWidget {
  const MyRentalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RentalsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('My Rentals'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status Filter Chips
          _buildFilterChips(context, controller),
          // Rental List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState(context, controller);
              }

              if (controller.rentals.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshRentals,
                color: AppColor.primaryColor,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      controller.loadNextPage();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: controller.rentals.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.rentals.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: AppColor.primaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      return _buildRentalCard(
                          context, controller.rentals[index]);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, RentalsController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statuses = ['All', 'Pending', 'Confirmed', 'Active', 'Completed', 'Cancelled', 'Overdue', 'Disputed'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() => Row(
              children: statuses.map((status) {
                final isSelected = (status == 'All' &&
                        controller.selectedStatus.value.isEmpty) ||
                    controller.selectedStatus.value.toLowerCase() ==
                        status.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status.tr),
                    selected: isSelected,
                    onSelected: (_) {
                      controller.filterByStatus(
                          status == 'All' ? '' : status.toLowerCase());
                    },
                    selectedColor: isDark ? AppColor.primaryColor : Colors.white,
                    backgroundColor: isDark ? const Color(0xFF334155) : AppColor.secondColor,
                    labelStyle: TextStyle(
                      color: isSelected 
                        ? (isDark ? Colors.white : AppColor.primaryColor) 
                        : (isDark ? Colors.white70 : Colors.white70),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    checkmarkColor: isDark ? Colors.white : AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.white : Colors.white24,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildRentalCard(BuildContext context, RentalListDto rental) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = _getStatusColor(rental.status ?? '');

    return GestureDetector(
      onTap: () {
        if (rental.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RentalDetailPage(rentalId: rental.id!),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
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
          children: [
            // Image + Status badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                  child: rental.itemImage != null
                      ? Image.network(
                          rental.itemImage!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 140,
                            color: isDark ? const Color(0xFF334155) : AppColor.borderGray,
                            child: Icon(Icons.image_not_supported,
                                size: 48, color: isDark ? Colors.white54 : AppColor.grey),
                          ),
                        )
                      : Container(
                          height: 140,
                          color: isDark ? const Color(0xFF334155) : AppColor.borderGray,
                          child: Icon(Icons.inventory_2_outlined,
                              size: 48, color: isDark ? Colors.white54 : AppColor.grey),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (rental.status ?? 'Unknown').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rental.itemTitle ?? 'Untitled Item'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColor.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: isDark ? Colors.white54 : AppColor.grey),
                      SizedBox(width: 4),
                      Text(
                        rental.startDate != null
                            ? dateFormat.format(rental.startDate!)
                            : 'N/A',
                        style:
                            TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColor.mediumText),
                      ),
                      Text(' → ',
                          style: TextStyle(
                              color: isDark ? Colors.white54 : AppColor.grey, fontSize: 12)),
                      Text(
                        rental.endDate != null
                            ? dateFormat.format(rental.endDate!)
                            : 'N/A',
                        style:
                            TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColor.mediumText),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EGP ${rental.rentalPrice?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor,
                        ),
                      ),
                      if (rental.depositStatus != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : Color(0xFF1A1A1A).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Deposit: ${rental.depositStatus}'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFFD4D4D8) : AppColor.earthBrown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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
          Icon(Icons.receipt_long_outlined, size: 80, color: isDark ? const Color(0xFF334155) : AppColor.borderGray),
          const SizedBox(height: 16),
          Text('No Rentals Yet'.tr,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColor.darkText)),
          const SizedBox(height: 8),
          Text('Your rental history will appear here'.tr,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColor.mediumText)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, RentalsController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
          SizedBox(height: 16),
          Text(controller.errorMessage.value,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColor.mediumText)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshRentals,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor),
            child: Text('Retry'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Color(0xFFd97706);
      case 'confirmed':
        return Color(0xFF2563eb);
      case 'active':
        return AppColor.successColor;
      case 'completed':
        return AppColor.primaryColor;
      case 'cancelled':
        return AppColor.warningColor;
      default:
        return AppColor.grey;
    }
  }
}

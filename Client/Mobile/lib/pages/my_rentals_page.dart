import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/pages/rental_detail_page.dart';

class MyRentalsPage extends StatelessWidget {
  const MyRentalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RentalsCubit()..loadRentals(),
      child: const _MyRentalsPageContent(),
    );
  }
}

class _MyRentalsPageContent extends StatelessWidget {
  const _MyRentalsPageContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<RentalsCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('My Rentals'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildRoleTabs(context, controller),
          // Status Filter Chips
          _buildFilterChips(context, controller),
          // Rental List
          Expanded(
            child: BlocBuilder<RentalsCubit, RentalsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  );
                }

                if (state.errorMessage.isNotEmpty) {
                  return _buildErrorState(context, controller, state.errorMessage);
                }

                if (state.rentals.isEmpty) {
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
                      padding: const EdgeInsets.all(16),
                      itemCount: state.rentals.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.rentals.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: AppColor.primaryColor,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                        return _buildRentalCard(
                            context, state.rentals[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTabs(BuildContext context, RentalsCubit controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<RentalsCubit, RentalsState>(
      buildWhen: (prev, curr) => prev.selectedRole != curr.selectedRole,
      builder: (context, state) {
        final selected = state.selectedRole;
        return Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Row(
            children: [
              _buildTabItem(
                context: context,
                label: 'Items I Rented'.tr,
                isSelected: selected == 'renter',
                onTap: () => controller.changeRole('renter'),
              ),
              _buildTabItem(
                context: context,
                label: 'Rentals of My Items'.tr,
                isSelected: selected == 'owner',
                onTap: () => controller.changeRole('owner'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? (isDark
                        ? const Color(0xFF60A5FA)
                        : AppColor.primaryColor)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.white : AppColor.primaryColor)
                  : (isDark ? Colors.white38 : AppColor.mediumText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, RentalsCubit controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statuses = [
      'All',
      'Pending',
      'Confirmed',
      'Active',
      'Completed',
      'Cancelled',
      'Overdue',
      'Disputed'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<RentalsCubit, RentalsState>(
          buildWhen: (prev, curr) =>
              prev.selectedStatus != curr.selectedStatus,
          builder: (context, state) => Row(
            children: statuses.map((status) {
              final isSelected = (status == 'All' &&
                      state.selectedStatus.isEmpty) ||
                  state.selectedStatus.toLowerCase() == status.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status.tr),
                  selected: isSelected,
                  onSelected: (_) {
                    controller.filterByStatus(
                        status == 'All' ? '' : status.toLowerCase());
                  },
                  selectedColor:
                      isDark ? AppColor.primaryColor : Colors.white,
                  backgroundColor:
                      isDark ? const Color(0xFF334155) : AppColor.secondColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (isDark ? Colors.white : AppColor.primaryColor)
                        : (isDark ? Colors.white70 : Colors.white70),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  checkmarkColor:
                      isDark ? Colors.white : AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.white : Colors.white24,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
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
        margin: const EdgeInsets.only(bottom: 12),
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
          children: [
            // Image + Status badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: rental.itemImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: rental.itemImageUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 140,
                            color: isDark
                                ? const Color(0xFF334155)
                                : AppColor.borderGray,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 140,
                            color: isDark
                                ? const Color(0xFF334155)
                                : AppColor.borderGray,
                            child: const Icon(Icons.image_not_supported,
                                size: 40, color: Colors.grey),
                          ),
                        )
                      : Container(
                          height: 140,
                          color: isDark
                              ? const Color(0xFF334155)
                              : AppColor.borderGray,
                          child: const Icon(Icons.image_not_supported,
                              size: 40, color: Colors.grey),
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (rental.status ?? '').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Rental Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rental.itemTitle ?? 'Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColor.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 13,
                          color: isDark ? Colors.white54 : AppColor.mediumText),
                      const SizedBox(width: 4),
                      Text(
                        '${rental.startDate != null ? dateFormat.format(rental.startDate!) : ''} - ${rental.endDate != null ? dateFormat.format(rental.endDate!) : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : AppColor.mediumText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 13,
                              color: isDark
                                  ? Colors.white54
                                  : AppColor.mediumText),
                          const SizedBox(width: 4),
                          Text(
                            rental.ownerFirstName ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : AppColor.mediumText,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'EGP ${rental.rentalPrice?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 15,
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
          Icon(Icons.receipt_long_outlined,
              size: 80,
              color: isDark ? const Color(0xFF334155) : AppColor.borderGray),
          const SizedBox(height: 16),
          Text(
            'No Rentals Yet'.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColor.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your rental history will appear here'.tr,
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
      BuildContext context, RentalsCubit controller, String error) {
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
            onPressed: controller.refreshRentals,
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
      case 'confirmed':
        return const Color(0xFF2563eb);
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

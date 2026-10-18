import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/pages/create_rental_page.dart';
import 'package:renty/pages/public_profile_page.dart';
import 'package:renty/pages/checkout_page.dart';

class ItemDetailPage extends StatelessWidget {
  final String? itemId;
  const ItemDetailPage({super.key, this.itemId});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final effectiveItemId = itemId ?? (args?['itemId'] as String?);

    return BlocProvider(
      create: (_) {
        final cubit = ItemDetailCubit();
        if (effectiveItemId != null) {
          cubit.loadItem(effectiveItemId);
        }
        return cubit;
      },
      child: const _ItemDetailPageContent(),
    );
  }
}

class _ItemDetailPageContent extends StatelessWidget {
  const _ItemDetailPageContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ItemDetailCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : AppColor.backgroundcolor,
      body: BlocBuilder<ItemDetailCubit, ItemDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.fourthColor),
            );
          }

          if (state.errorMessage.isNotEmpty || state.item == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage.isNotEmpty
                        ? state.errorMessage
                        : 'Item not found'.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'.tr),
                  ),
                ],
              ),
            );
          }

          final item = state.item!;

        return CustomScrollView(
          slivers: [
            // ── Image Gallery ──
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                // Share
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    final title = item.titleEn ?? item.titleAr ?? '';
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Check out "$title" on Renty!\nhttps://starfish-app-vavqt.ondigitalocean.app/items/${item.id}',
                      ),
                    );
                  },
                ),
                // Reminder (only when rented)
                if (item.status?.toLowerCase() == 'rented')
                  BlocBuilder<ItemDetailCubit, ItemDetailState>(
                    buildWhen: (p, c) => p.isReminded != c.isReminded,
                    builder: (context, s) => IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          s.isReminded
                              ? Icons.notifications_active
                              : Icons.notifications_outlined,
                          color: s.isReminded
                              ? const Color(0xFFF59E0B)
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: controller.toggleReminder,
                    ),
                  ),
                // Favorite
                BlocBuilder<ItemDetailCubit, ItemDetailState>(
                  buildWhen: (p, c) => p.isFavorite != c.isFavorite,
                  builder: (context, s) => IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        s.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: s.isFavorite
                            ? Colors.red
                            : Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: controller.toggleFavorite,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _ImageGallery(
                  images: (() {
                    final list = List<ItemImageDto>.from(item.images);
                    list.sort((a, b) {
                      if (a.isPrimary == true && b.isPrimary != true) return -1;
                      if (a.isPrimary != true && b.isPrimary == true) return 1;
                      return 0;
                    });
                    return list;
                  })(),
                  primaryImage: item.images.isEmpty
                      ? null
                      : item.images.firstWhere(
                          (i) => i.isPrimary == true,
                          orElse: () => item.images.first,
                        ),
                ),
              ),
            ),

            // ── Item Info ──
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title + Status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.status != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  item.status!,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.status!,
                                style: TextStyle(
                                  color: _getStatusColor(item.status!),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Text(
                            item.titleEn ?? item.titleAr ?? 'Untitled',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : AppColor.primaryColor,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Rating row
                          Row(
                            children: [
                              if (state.avgRating > 0) ...[
                                Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFF1A1A1A),
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  state.avgRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : AppColor.darkText,
                                  ),
                                ),
                                Text(
                                  ' (${state.totalReviews} reviews)',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : AppColor.lightText,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                              if (item.city != null) ...[
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: isDark
                                      ? Colors.white54
                                      : AppColor.lightText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.city!,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : AppColor.lightText,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _divider(isDark),

                    // ── Pricing ──
                    if (item.pricing.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pricing'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppColor.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: item.pricing.map((p) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.fourthColor.withOpacity(
                                      0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColor.fourthColor.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${p.price?.toStringAsFixed(0) ?? '0'} EGP',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColor.fourthColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '/ ${p.pricingType ?? 'day'}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white54
                                              : AppColor.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            if (item.defaultDeposit != null &&
                                item.defaultDeposit! > 0) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 16,
                                    color: AppColor.successColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Deposit: ${item.defaultDeposit!.toStringAsFixed(0)} EGP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      _divider(isDark),
                    ],

                    // ── Availability Calendar ──
                    BlocBuilder<ItemDetailCubit, ItemDetailState>(
                      buildWhen: (p, c) =>
                          p.bookedRanges != c.bookedRanges ||
                          p.isLoadingAvailability != c.isLoadingAvailability,
                      builder: (context, availState) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Availability'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColor.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey[800]!
                                        : Colors.grey[200]!,
                                  ),
                                ),
                                child: TableCalendar(
                                  firstDay: DateTime.now(),
                                  lastDay: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                  focusedDay: DateTime.now(),
                                  calendarFormat: CalendarFormat.month,
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    titleTextStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : AppColor.darkText,
                                    ),
                                    leftChevronIcon: Icon(
                                      Icons.chevron_left,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColor.mediumText,
                                    ),
                                    rightChevronIcon: Icon(
                                      Icons.chevron_right,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColor.mediumText,
                                    ),
                                  ),
                                  calendarStyle: CalendarStyle(
                                    defaultTextStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : AppColor.darkText,
                                    ),
                                    weekendTextStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : AppColor.mediumText,
                                    ),
                                    outsideTextStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.grey[400]!,
                                    ),
                                    todayDecoration: BoxDecoration(
                                      color: AppColor.fourthColor.withOpacity(
                                        0.3,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    todayTextStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : AppColor.darkText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    disabledTextStyle: const TextStyle(
                                      color: Colors.red,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  enabledDayPredicate: (day) =>
                                      !availState.isDateBooked(day),
                                  onDaySelected: (_, __) {},
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColor.successColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Available'.tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColor.mediumText,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Booked'.tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColor.mediumText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    _divider(isDark),

                    // ── Description ──
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.descEn ??
                                item.descAr ??
                                'No description available.',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? Colors.white70
                                  : AppColor.mediumText,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(isDark),

                    // ── Details (Type, Condition, Category) ──
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Details'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _detailRow('Type'.tr, item.type ?? 'N/A', isDark),
                          _detailRow(
                            'Condition'.tr,
                            item.condition ?? 'N/A',
                            isDark,
                          ),
                          if (item.category != null)
                            _detailRow(
                              'Category'.tr,
                              item.category!.nameEn ??
                                  item.category!.nameAr ??
                                  '',
                              isDark,
                            ),
                          if (item.subcategory != null)
                            _detailRow(
                              'Subcategory'.tr,
                              item.subcategory!.nameEn ??
                                  item.subcategory!.nameAr ??
                                  '',
                              isDark,
                            ),
                          if (item.brand != null)
                            _detailRow(
                              'Brand'.tr,
                              item.brand!.nameEn ?? item.brand!.nameAr ?? '',
                              isDark,
                            ),
                        ],
                      ),
                    ),
                    _divider(isDark),

                    // ── Owner ──
                    if (item.owner != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfilePage(
                                userId: '',
                                userName: item.owner!.firstName ?? 'Owner',
                                userCity: item.owner!.city,
                                userImageUrl: item.owner!.profileImageUrl,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColor.fourthColor
                                    .withOpacity(0.1),
                                backgroundImage:
                                    item.owner!.profileImageUrl != null
                                    ? CachedNetworkImageProvider(
                                        item.owner!.profileImageUrl!,
                                      )
                                    : null,
                                child: item.owner!.profileImageUrl == null
                                    ? Icon(
                                        Icons.person,
                                        color: AppColor.fourthColor,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.owner!.firstName ?? 'Owner',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : AppColor.darkText,
                                      ),
                                    ),
                                    if (item.owner!.city != null)
                                      Text(
                                        item.owner!.city!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white54
                                              : AppColor.lightText,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Chat with Owner button (only when ownerId available)
                              BlocBuilder<ItemDetailCubit, ItemDetailState>(
                                buildWhen: (p, c) =>
                                    p.ownerId != c.ownerId ||
                                    p.isChatting != c.isChatting,
                                builder: (context, chatState) {
                                  if (chatState.ownerId == null) {
                                    return Icon(
                                      Icons.chevron_right_rounded,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.grey[400],
                                    );
                                  }
                                  return SizedBox(
                                    height: 36,
                                    child: ElevatedButton.icon(
                                      onPressed: chatState.isChatting
                                          ? null
                                          : controller.startChat,
                                      icon: chatState.isChatting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.chat_bubble_outline,
                                              size: 16,
                                            ),
                                      label: Text(
                                        chatState.isChatting
                                            ? 'Opening...'
                                            : 'Chat'.tr,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColor.fourthColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Reviews with Star Distribution ──
                    if (state.reviews.isNotEmpty) ...[
                      _divider(isDark),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reviews (${state.totalReviews})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppColor.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Star distribution chart (like Web)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avg rating display
                                Column(
                                  children: [
                                    Text(
                                      state.avgRating
                                          .toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : AppColor.darkText,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < state.avgRating.round()
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 16,
                                          color: const Color(0xFFFFB800),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${state.totalReviews} reviews',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white54
                                            : AppColor.lightText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                // Bar chart
                                Expanded(
                                  child: Column(
                                    children: List.generate(5, (index) {
                                      final star = 5 - index;
                                      final pct = state.getStarPercent(
                                        star,
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 14,
                                              child: Text(
                                                '$star',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : AppColor.lightText,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.star_rounded,
                                              size: 12,
                                              color: const Color(0xFFFFB800),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: pct / 100,
                                                  backgroundColor: isDark
                                                      ? Colors.grey[800]
                                                      : Colors.grey[200],
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        const Color(0xFFFFB800),
                                                      ),
                                                  minHeight: 8,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                '${pct.round()}%',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : AppColor.lightText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...state.reviews
                                .take(5)
                                .map(
                                  (review) => _ReviewCard(
                                    review: review,
                                    isDark: isDark,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],

                    // ── Write a Review (only if user has rented) ──
                    BlocBuilder<ItemDetailCubit, ItemDetailState>(
                      buildWhen: (p, c) => p.hasRentedItem != c.hasRentedItem,
                      builder: (context, rentState) {
                        if (!rentState.hasRentedItem) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            _divider(isDark),
                            _WriteReviewSection(
                              cubit: controller,
                              isDark: isDark,
                            ),
                          ],
                        );
                      },
                    ),

                    // ── Similar Items ──
                    BlocBuilder<ItemDetailCubit, ItemDetailState>(
                      buildWhen: (p, c) => p.similarItems != c.similarItems,
                      builder: (context, simState) {
                        if (simState.similarItems.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _divider(isDark),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                              child: Text(
                                'Similar Items'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColor.primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: simState.similarItems.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final si = simState.similarItems[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ItemDetailPage(itemId: si.id),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF2A2A2A)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.06),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(14),
                                                ),
                                            child: CachedNetworkImage(
                                              imageUrl: si.primaryImage ?? '',
                                              height: 110,
                                              width: 150,
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) => Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                              errorWidget: (_, __, ___) =>
                                                  Container(
                                                    color: Colors.grey[200],
                                                    height: 110,
                                                    child: const Icon(
                                                      Icons.image_outlined,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  si.titleEn ?? si.titleAr ?? '',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? Colors.white
                                                        : AppColor.darkText,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                if (si.dailyPrice != null)
                                                  Text(
                                                    '${si.dailyPrice!.toStringAsFixed(0)} EGP',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColor.fourthColor,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // ── Bottom Action Bar ──
      bottomNavigationBar: BlocBuilder<ItemDetailCubit, ItemDetailState>(
        buildWhen: (p, c) => p.item != c.item,
        builder: (context, bState) {
          if (bState.item == null) return const SizedBox.shrink();
          final item = bState.item!;
          final price = item.pricing.firstOrNull?.price;

          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (price != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${price.toStringAsFixed(0)} EGP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColor.fourthColor,
                        ),
                      ),
                      Text(
                        '/ ${item.pricing.first.pricingType ?? 'day'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : AppColor.lightText,
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
                // Show Buy Now for sell/both items
                if (item.type?.toLowerCase() == 'sell' ||
                    item.type?.toLowerCase() == 'both')
                  Padding(
                    padding: EdgeInsets.only(
                      right: item.type?.toLowerCase() == 'both' ? 8 : 0,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              items: [
                                CheckoutItem(
                                  itemId: item.id ?? '',
                                  title:
                                      item.titleEn ?? item.titleAr ?? 'Untitled',
                                  price: price?.toDouble() ?? 0,
                                  quantity: 1,
                                  imageUrl: item.images.firstOrNull?.imageUrl,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Buy Now'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // Show Rent Now for rent/both items
                if (item.type?.toLowerCase() != 'sell')
                  ElevatedButton(
                    onPressed: () {
                      num? dailyP, weeklyP, monthlyP;
                      for (final p in item.pricing) {
                        switch (p.pricingType?.toLowerCase()) {
                          case 'daily':
                            dailyP = p.price;
                            break;
                          case 'weekly':
                            weeklyP = p.price;
                            break;
                          case 'monthly':
                            monthlyP = p.price;
                            break;
                        }
                      }
                      dailyP ??= price;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateRentalPage(
                            itemId: item.id ?? '',
                            itemTitle: item.titleEn ?? item.titleAr ?? 'Untitled',
                            itemImageUrl: item.images.firstOrNull?.imageUrl,
                            ownerName: item.owner?.firstName != null
                                ? '${item.owner!.firstName} ${item.owner?.lastName ?? ''}'.trim()
                                : null,
                            dailyPrice: dailyP,
                            weeklyPrice: weeklyP,
                            monthlyPrice: monthlyP,
                            depositAmount: item.defaultDeposit,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.fourthColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Rent Now'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : AppColor.lightText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColor.successColor;
      case 'rented':
        return AppColor.fourthColor;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColor.grey;
    }
  }
}

class _ImageGallery extends StatefulWidget {
  final List<ItemImageDto> images;
  final ItemImageDto? primaryImage;

  const _ImageGallery({required this.images, this.primaryImage});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final image = widget.images[index];
            return CachedNetworkImage(
              imageUrl: image.imageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
        // Page indicator
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        // Image counter
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPage + 1}/${widget.images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewDto review;
  final bool isDark;

  const _ReviewCard({required this.review, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColor.fourthColor.withOpacity(0.1),
                backgroundImage: review.reviewer?.profileImageUrl != null
                    ? CachedNetworkImageProvider(
                        review.reviewer!.profileImageUrl!,
                      )
                    : null,
                child: review.reviewer?.profileImageUrl == null
                    ? Icon(Icons.person, size: 16, color: AppColor.fourthColor)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                review.reviewer?.firstName ?? 'User',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColor.darkText,
                ),
              ),
              const Spacer(),
              ...List.generate(
                5,
                (i) => Icon(
                  i < (review.rating ?? 0)
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColor.mediumText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WriteReviewSection extends StatefulWidget {
  final ItemDetailCubit cubit;
  final bool isDark;
  const _WriteReviewSection({required this.cubit, required this.isDark});

  @override
  State<_WriteReviewSection> createState() => _WriteReviewSectionState();
}

class _WriteReviewSectionState extends State<_WriteReviewSection> {
  int _selectedStar = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave a Review'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.isDark ? Colors.white : AppColor.primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          // Star selector
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedStar = star),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    star <= _selectedStar
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36,
                    color: star <= _selectedStar
                        ? const Color(0xFFFFB800)
                        : (widget.isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          // Comment field
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            maxLength: 500,
            style: TextStyle(
              color: widget.isDark ? Colors.white : AppColor.darkText,
            ),
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              hintStyle: TextStyle(
                color: widget.isDark ? Colors.white38 : Colors.grey[400],
              ),
              filled: true,
              fillColor: widget.isDark
                  ? const Color(0xFF2A2A2A)
                  : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColor.fourthColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Submit button
          Align(
            alignment: Alignment.centerRight,
            child: BlocBuilder<ItemDetailCubit, ItemDetailState>(
              buildWhen: (p, c) => p.isSubmittingReview != c.isSubmittingReview,
              builder: (context, revState) {
                final isSubmitting = revState.isSubmittingReview;
                return ElevatedButton(
                  onPressed:
                      (_selectedStar == 0 ||
                          _commentCtrl.text.trim().length < 10 ||
                          isSubmitting)
                      ? null
                      : () async {
                          await widget.cubit.submitReview(
                            _selectedStar,
                            _commentCtrl.text.trim(),
                          );
                          setState(() => _selectedStar = 0);
                          _commentCtrl.clear();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.fourthColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Submit Review'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

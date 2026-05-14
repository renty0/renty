import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/rent_request_controller.dart';
import 'rent_request_detail_view.dart';

/// Rent Requests list page with two tabs: My Requests / Received.
class RentRequestsView extends StatelessWidget {
  const RentRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RentRequestController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Rent Requests',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: ctrl.tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
          labelStyle: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'My Requests'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: ctrl.tabController,
        children: [
          _RequestList(requests: ctrl.myRequests, ctrl: ctrl, isMine: true),
          _RequestList(
              requests: ctrl.receivedRequests, ctrl: ctrl, isMine: false),
        ],
      ),
    );
  }
}

/// Scrollable list of rent request cards.
class _RequestList extends StatelessWidget {
  final RxList<Map<String, dynamic>> requests;
  final RentRequestController ctrl;
  final bool isMine;

  const _RequestList({
    required this.requests,
    required this.ctrl,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value && requests.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (requests.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 72, color: AppColors.gray300),
                const SizedBox(height: 20),
                Text(
                  isMine
                      ? 'No rent requests yet'
                      : 'No incoming requests',
                  style:
                      AppTextStyles.heading3.copyWith(color: AppColors.gray500),
                ),
                const SizedBox(height: 12),
                Text(
                  isMine
                      ? 'Browse the marketplace to rent items'
                      : 'Requests from renters will appear here',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: isMine ? ctrl.loadMyRequests : ctrl.loadReceivedRequests,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return _RentRequestCard(request: req, isMine: isMine);
          },
        ),
      );
    });
  }
}

/// Individual rent request card.
class _RentRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final bool isMine;

  const _RentRequestCard({required this.request, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final status = request['status'];
    final statusText = RentRequestController.statusLabel(status);
    final statusClr = RentRequestController.statusColor(status);

    final itemTitle = _extractItemTitle();
    final startDate = request['startDate'] ?? '';
    final endDate = request['endDate'] ?? '';
    final grandTotal = request['grandTotal'];
    final id = request['id'];

    return GestureDetector(
      onTap: () {
        if (id != null) {
          Get.to(() => RentRequestDetailView(
                requestId: id.toString(),
                isMine: isMine,
              ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    itemTitle.isNotEmpty ? itemTitle : 'Rent Request #$id',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusClr.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: statusClr,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date range
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.gray400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$startDate  →  $endDate',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.gray500,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (grandTotal != null)
                  Text(
                    '$grandTotal EGP',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _extractItemTitle() {
    // Swagger response uses 'itemTitle' directly
    if (request['itemTitle'] != null) return request['itemTitle'].toString();
    final item = request['rentableItem'] ?? request['item'];
    if (item is Map<String, dynamic>) {
      return item['titleEn'] ?? item['titleAr'] ?? item['title'] ?? '';
    }
    return '';
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/payment_page.dart';
import 'package:renty/pages/checkout_page.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isLoading = true;
  ApiResponseOfOrderDetailDto? _response;
  ApiResponseOfPaymentDto? _paymentResponse;
  List<TrackingEntryDto> _deliveryTracking = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.orders.getOrderById(widget.orderId);
      setState(() {
        _response = response;
        _isLoading = false;
      });

      // Also load payment + delivery in parallel
      final futures = await Future.wait([
        ApiService.payments.getPaymentByOrder(widget.orderId).catchError((_) => null),
        ApiService.delivery.getDelivery(widget.orderId).catchError((_) => null),
      ]);
      if (mounted) {
        setState(() {
          _paymentResponse = futures[0] as ApiResponseOfPaymentDto?;
          final deliveryRes = futures[1] as ApiResponseOfListOfTrackingEntryDto?;
          _deliveryTracking = deliveryRes?.data ?? [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Order Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor))
          : _errorMessage != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
          SizedBox(height: 16),
          Text(_errorMessage!,
              style: TextStyle(fontSize: 16, color: AppColor.mediumText)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrderDetail,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _response?.data;
    if (data == null) return _buildError();

    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final status = data.status ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return RefreshIndicator(
      onRefresh: _loadOrderDetail,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primaryColor, AppColor.secondColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${data.id?.substring(0, 8) ?? 'N/A'}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (data.createdAt != null)
                    Text(
                      dateFormat.format(data.createdAt!),
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  SizedBox(height: 12),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Order Items
            _buildSectionTitle('Order Items'),
            SizedBox(height: 8),
            if (data.items.isNotEmpty)
              ...data.items.map((item) => _buildOrderItemCard(item))
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No items in this order',
                    style: TextStyle(color: AppColor.mediumText)),
              ),

            SizedBox(height: 20),

            // Price Summary
            _buildPriceCard(data),

            SizedBox(height: 20),

            // Payment Info
            _buildPaymentSection(),

            SizedBox(height: 20),

            // Delivery Tracking
            _buildDeliveryTimeline(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText));
  }

  Widget _buildOrderItemCard(OrderItemDetailDto item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.primaryImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.primaryImageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 60,
                      height: 60,
                      color: AppColor.borderGray,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppColor.borderGray,
                      child: Icon(Icons.image, color: AppColor.grey),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColor.borderGray,
                    child: Icon(Icons.inventory_2_outlined,
                        color: AppColor.grey),
                  ),
          ),
          SizedBox(width: 12),
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? 'Untitled Item',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity ?? 1}',
                  style:
                      TextStyle(fontSize: 12, color: AppColor.mediumText),
                ),
              ],
            ),
          ),
          // Price
          Text(
            'EGP ${item.priceAtTime?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(dynamic data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined,
                  size: 20, color: AppColor.primaryColor),
              SizedBox(width: 8),
              Text('Price Summary',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor)),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: AppColor.borderGray),
          SizedBox(height: 8),
          _buildPriceRow(
            'Total',
            'EGP ${data.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(dynamic paymentData) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, size: 20, color: AppColor.successColor),
              SizedBox(width: 8),
              Text('Payment',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor)),
            ],
          ),
          SizedBox(height: 12),
          _buildPriceRow('Status', paymentData.status ?? 'N/A'),
          _buildPriceRow(
              'Amount',
              'EGP ${paymentData.amount?.toStringAsFixed(2) ?? '0.00'}'),
          if (paymentData.method != null)
            _buildPriceRow('Method', paymentData.method!),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 14, color: AppColor.mediumText)),
          Text(value,
              style: TextStyle(
                fontSize: isBold ? 18 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? AppColor.primaryColor : AppColor.darkText,
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    if (_paymentResponse?.data != null) {
      return _buildPaymentCard(_paymentResponse!.data!);
    }
    // No payment yet — show Pay Now
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColor.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(children: [
        Row(children: [
          Icon(Icons.payment, size: 20, color: Color(0xFFd97706)),
          SizedBox(width: 8),
          Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.primaryColor)),
        ]),
        SizedBox(height: 12),
        Text('No payment recorded yet.', style: TextStyle(color: AppColor.mediumText, fontSize: 14)),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => PaymentPage(
                  orderId: widget.orderId,
                  totalAmount: _response?.data?.totalAmount?.toDouble() ?? 0,
                  items: [],
                ),
              )).then((_) => _loadOrderDetail());
            },
            icon: Icon(Icons.payments_outlined, size: 18),
            label: Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fourthColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDeliveryTimeline() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColor.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.local_shipping_outlined, size: 20, color: AppColor.primaryColor),
          SizedBox(width: 8),
          Text('Delivery Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.primaryColor)),
        ]),
        SizedBox(height: 12),
        if (_deliveryTracking.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(children: [
                Icon(Icons.hourglass_empty, size: 36, color: Colors.grey[300]),
                SizedBox(height: 8),
                Text('No tracking info yet', style: TextStyle(color: AppColor.mediumText, fontSize: 13)),
              ]),
            ),
          )
        else
          ..._deliveryTracking.asMap().entries.map((e) => _buildTimelineItem(e.key, e.value, e.key == _deliveryTracking.length - 1)),
      ]),
    );
  }

  Widget _buildTimelineItem(int index, TrackingEntryDto step, bool isLast) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final isFirst = index == 0;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 28,
          child: Column(children: [
            Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFirst ? AppColor.fourthColor : Colors.grey[300],
                border: isFirst ? Border.all(color: AppColor.fourthColor.withOpacity(0.3), width: 3) : null,
              ),
            ),
            if (!isLast)
              Expanded(child: Container(width: 2, color: Colors.grey[200])),
          ]),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                (step.status ?? 'Unknown').replaceAll('_', ' ').capitalize,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isFirst ? AppColor.darkText : AppColor.mediumText),
              ),
              if (step.location != null && step.location!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Row(children: [
                    Icon(Icons.location_on, size: 12, color: AppColor.lightText),
                    SizedBox(width: 4),
                    Text(step.location!, style: TextStyle(fontSize: 12, color: AppColor.lightText)),
                  ]),
                ),
              if (step.updatedAt != null)
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(dateFormat.format(step.updatedAt!), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ),
            ]),
          ),
        ),
      ]),
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
      case 'success':
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

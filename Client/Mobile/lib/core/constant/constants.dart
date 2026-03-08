import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Renty Admin';
  static const String appVersion = '1.0.0';

  // ⭐ DISABLE MOCK MODE - Use real backend
  static const bool useMockData = false;

  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderProcessing = 'processing';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  static List<String> get orderStatuses => [
    orderPending,
    orderConfirmed,
    orderProcessing,
    orderShipped,
    orderDelivered,
    orderCancelled,
  ];

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // Delivery Status
  static const String deliveryAvailable = 'available';
  static const String deliveryBusy = 'busy';
  static const String deliveryOffline = 'offline';

  // Store Status
  static const String storeActive = 'active';
  static const String storeInactive = 'inactive';
  static const String storeOpen = 'open';
  static const String storeClosed = 'closed';

  // Store Working Days
  static const List<String> defaultWorkingDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // Store Operating Hours
  static const TimeOfDay defaultOpeningTime = TimeOfDay(hour: 9, minute: 0);
  static const TimeOfDay defaultClosingTime = TimeOfDay(hour: 22, minute: 0);

  // Notification Types
  static const String notificationOrder = 'order';
  static const String notificationSystem = 'system';
  static const String notificationPromotion = 'promotion';
  static const String notificationDelivery = 'delivery';

  // Pagination
  static const int itemsPerPage = 20;
  static const int storesPerPage = 10;
  static const int notificationsPerPage = 15;

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 1000;

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String unknownError = 'An unknown error occurred.';
  static const String authError = 'Authentication failed.';
  static const String serverError = 'Server error. Please try again later.';

  // Timeouts
  static const int apiTimeoutSeconds = 30;
}

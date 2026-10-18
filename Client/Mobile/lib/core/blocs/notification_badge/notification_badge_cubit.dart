import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/notification_signalr_service.dart';
import 'notification_badge_state.dart';

class NotificationBadgeCubit extends Cubit<NotificationBadgeState> {
  static NotificationBadgeCubit? _instance;
  static NotificationBadgeCubit get instance =>
      _instance ??= NotificationBadgeCubit();
  static NotificationBadgeCubit get to => instance;

  final NotificationSignalrService _signalr = NotificationSignalrService();
  StreamSubscription? _sub;

  NotificationBadgeCubit() : super(const NotificationBadgeState()) {
    _instance = this;
    loadCount();
    _listenRealTime();
  }

  int get unreadCount => state.unreadCount;

  /// Fetch current unread count from the REST API.
  Future<void> loadCount() async {
    try {
      final response = await ApiService.notifications.getNotifications();
      if (response != null && response.data != null) {
        emit(state.copyWith(unreadCount: response.data!.unreadCount ?? 0));
      }
    } catch (_) {}
  }

  /// Increment badge for every push that arrives via SignalR.
  void _listenRealTime() {
    _sub = _signalr.onNotification.listen((_) {
      emit(state.copyWith(unreadCount: state.unreadCount + 1));
    });
  }

  /// Call this when the user opens the Notifications page so the badge clears.
  void markAllSeen() {
    emit(state.copyWith(unreadCount: 0));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    if (_instance == this) _instance = null;
    return super.close();
  }
}

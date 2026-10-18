import 'package:equatable/equatable.dart';

class NotificationBadgeState extends Equatable {
  final int unreadCount;

  const NotificationBadgeState({this.unreadCount = 0});

  NotificationBadgeState copyWith({int? unreadCount}) {
    return NotificationBadgeState(
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [unreadCount];
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:renty/main.dart';

/// Notification payload received from SignalR hub.
class SignalrNotification {
  final String? id;
  final String? title;
  final String? message;
  final String? type;
  final String? actionUrl;
  final bool isRead;
  final DateTime? createdAt;

  SignalrNotification({
    this.id,
    this.title,
    this.message,
    this.type,
    this.actionUrl,
    this.isRead = false,
    this.createdAt,
  });

  factory SignalrNotification.fromJson(Map<String, dynamic> json) {
    return SignalrNotification(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      type: json['type']?.toString(),
      actionUrl: json['actionUrl']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

/// SignalR-based real-time notification service.
/// Connects to /hubs/notifications and listens for ReceiveNotification.
class NotificationSignalrService {
  static const String _hubPath = '/hubs/notifications';
  // 🔧 LOCAL DEV: change back to 'https://renty.runasp.net' before pushing
  static const String _baseUrl = 'https://renty.runasp.net';

  HubConnection? _hubConnection;
  bool _isConnected = false;

  final _notificationController = StreamController<SignalrNotification>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  /// Stream of incoming real-time notifications.
  Stream<SignalrNotification> get onNotification => _notificationController.stream;

  /// Stream of connection state changes.
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool get isConnected => _isConnected;

  /// Start the SignalR connection.
  Future<void> startConnection() async {
    if (_isConnected) return;

    final token = sharedPref.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            '$_baseUrl$_hubPath',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              skipNegotiation: true,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _hubConnection!.on('ReceiveNotification', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final payload = arguments[0];
            final Map<String, dynamic> data;
            if (payload is Map<String, dynamic>) {
              data = payload;
            } else if (payload is String) {
              data = jsonDecode(payload);
            } else {
              return;
            }
            _notificationController.add(SignalrNotification.fromJson(data));
          } catch (e) {
            debugPrint('Notification SignalR parse error: $e');
          }
        }
      });

      _hubConnection!.onclose(({error}) {
        _isConnected = false;
        _connectionController.add(false);
      });

      _hubConnection!.onreconnected(({connectionId}) {
        _isConnected = true;
        _connectionController.add(true);
      });

      await _hubConnection!.start();
      _isConnected = true;
      _connectionController.add(true);
      debugPrint('Notification SignalR connected');
    } catch (e) {
      debugPrint('Notification SignalR error: $e');
      _isConnected = false;
      Future.delayed(const Duration(seconds: 5), () => startConnection());
    }
  }

  Future<void> stopConnection() async {
    try {
      await _hubConnection?.stop();
    } catch (_) {}
    _isConnected = false;
    _connectionController.add(false);
  }

  void dispose() {
    stopConnection();
    _notificationController.close();
    _connectionController.close();
  }
}

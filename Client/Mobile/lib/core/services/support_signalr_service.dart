import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:renty/main.dart';

/// Real-time support message from SignalR hub.
class SupportSignalrMessage {
  final String? id;
  final String? ticketId;
  final int? senderId;
  final String? senderName;
  final String? senderRole; // 'User', 'Support', 'Admin'
  final String? message;
  final String? createdAt;

  SupportSignalrMessage({
    this.id,
    this.ticketId,
    this.senderId,
    this.senderName,
    this.senderRole,
    this.message,
    this.createdAt,
  });

  factory SupportSignalrMessage.fromJson(Map<String, dynamic> json) {
    return SupportSignalrMessage(
      id: (json['id'] ?? json['Id'])?.toString(),
      ticketId: (json['ticketId'] ?? json['TicketId'])?.toString(),
      senderId: _parseInt(json['senderId'] ?? json['SenderId']),
      senderName: (json['senderName'] ?? json['SenderName'])?.toString(),
      senderRole: (json['senderRole'] ?? json['SenderRole'])?.toString(),
      message: (json['message'] ?? json['Message'])?.toString(),
      createdAt: (json['createdAt'] ?? json['CreatedAt'])?.toString(),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}

/// SignalR-based real-time support service.
/// Mirrors the Web's SupportSignalrService:
/// - Connects to /hubs/support with Bearer token
/// - Listens for ReceiveSupportMessage, UserTyping
/// - Exposes joinTicket, leaveTicket, sendTyping
class SupportSignalrService {
  static const String _hubPath = '/hubs/support';
  static const String _baseUrl = 'https://renty.runasp.net';

  HubConnection? _hubConnection;
  bool _isConnected = false;

  final _messageController = StreamController<SupportSignalrMessage>.broadcast();
  final _typingController = StreamController<String>.broadcast(); // senderName
  final _connectionController = StreamController<bool>.broadcast();

  Stream<SupportSignalrMessage> get onMessage => _messageController.stream;
  Stream<String> get onTyping => _typingController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;
  bool get isConnected => _isConnected;

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

      _hubConnection!.on('ReceiveSupportMessage', (arguments) {
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
            _messageController.add(SupportSignalrMessage.fromJson(data));
          } catch (e) {
            debugPrint('SupportSignalR parse error: $e');
          }
        }
      });

      _hubConnection!.on('UserTyping', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final name = arguments[0]?.toString() ?? '';
          if (name.isNotEmpty) _typingController.add(name);
        }
      });

      _hubConnection!.onclose(({error}) {
        _isConnected = false;
        _connectionController.add(false);
      });

      _hubConnection!.onreconnecting(({error}) {
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
      debugPrint('SupportSignalR connected');
    } catch (e) {
      debugPrint('SupportSignalR connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
      Future.delayed(const Duration(seconds: 5), () => startConnection());
    }
  }

  Future<void> joinTicket(String ticketId) async {
    if (_hubConnection != null && _isConnected) {
      try {
        await _hubConnection!.invoke('JoinTicket', args: [ticketId]);
      } catch (e) {
        debugPrint('SupportSignalR joinTicket error: $e');
      }
    }
  }

  Future<void> leaveTicket(String ticketId) async {
    if (_hubConnection != null && _isConnected) {
      try {
        await _hubConnection!.invoke('LeaveTicket', args: [ticketId]);
      } catch (e) {
        debugPrint('SupportSignalR leaveTicket error: $e');
      }
    }
  }

  Future<void> sendTyping(String ticketId, String senderName) async {
    if (_hubConnection != null && _isConnected) {
      try {
        await _hubConnection!.invoke('TypingIndicator', args: [ticketId, senderName]);
      } catch (e) {
        debugPrint('SupportSignalR sendTyping error: $e');
      }
    }
  }

  Future<void> stopConnection() async {
    try { await _hubConnection?.stop(); } catch (_) {}
    _isConnected = false;
    _connectionController.add(false);
  }

  void dispose() {
    stopConnection();
    _messageController.close();
    _typingController.close();
    _connectionController.close();
  }
}

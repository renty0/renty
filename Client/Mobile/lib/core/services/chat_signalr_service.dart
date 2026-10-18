import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:renty/main.dart';

/// Real-time chat message received from SignalR hub.
class SignalrChatMessage {
  final String? id;
  final String? chatId;
  final int? senderId;
  final String? message;
  final String? mediaUrl;
  final int? messageType; // 0=text, 1=image, 2=video, 3=audio
  final String? contextItemId;
  final DateTime? createdAt;

  SignalrChatMessage({
    this.id,
    this.chatId,
    this.senderId,
    this.message,
    this.mediaUrl,
    this.messageType,
    this.contextItemId,
    this.createdAt,
  });

  factory SignalrChatMessage.fromJson(Map<String, dynamic> json) {
    return SignalrChatMessage(
      id: json['id']?.toString(),
      chatId: json['chatId']?.toString(),
      senderId: json['senderId'] is int
          ? json['senderId']
          : int.tryParse(json['senderId']?.toString() ?? ''),
      message: json['message']?.toString(),
      mediaUrl: json['mediaUrl']?.toString(),
      messageType: json['messageType'] is int
          ? json['messageType']
          : int.tryParse(json['messageType']?.toString() ?? '0'),
      contextItemId: json['contextItemId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

/// Typing indicator event.
class TypingEvent {
  final String chatId;
  final int userId;
  TypingEvent({required this.chatId, required this.userId});
}

/// SignalR-based real-time chat service.
/// Mirrors the Web's ChatSignalrService exactly:
/// - Connects to /hubs/chat with Bearer token
/// - Listens for ReceiveMessage, UserTyping
/// - Exposes joinChat, leaveChat, sendTypingIndicator
class ChatSignalrService {
  static const String _hubPath = '/hubs/chat';
  // 🔧 LOCAL DEV: change back to 'https://starfish-app-vavqt.ondigitalocean.app' before pushing
  static const String _baseUrl =
      'https://starfish-app-vavqt.ondigitalocean.app';

  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Stream controllers for reactive updates
  final _messageController = StreamController<SignalrChatMessage>.broadcast();
  final _typingController = StreamController<TypingEvent>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  /// Stream of incoming messages from SignalR.
  Stream<SignalrChatMessage> get onMessage => _messageController.stream;

  /// Stream of typing indicators.
  Stream<TypingEvent> get onTyping => _typingController.stream;

  /// Stream of connection state changes.
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool get isConnected => _isConnected;

  /// Start the SignalR connection with the current auth token.
  Future<void> startConnection() async {
    if (_isConnected) return;

    final token = cachedToken; // SECURITY: in-memory cache from Keystore/Keychain
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

      // Listen for ReceiveMessage
      _hubConnection!.on('ReceiveMessage', (arguments) {
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
            final msg = SignalrChatMessage.fromJson(data);
            _messageController.add(msg);
          } catch (e) {
            debugPrint('SignalR ReceiveMessage parse error: $e');
          }
        }
      });

      // Listen for UserTyping
      _hubConnection!.on('UserTyping', (arguments) {
        if (arguments != null && arguments.length >= 2) {
          try {
            final userId = arguments[0] is int
                ? arguments[0] as int
                : int.tryParse(arguments[0].toString()) ?? 0;
            final chatId = arguments[1].toString();
            _typingController.add(TypingEvent(chatId: chatId, userId: userId));
          } catch (e) {
            debugPrint('SignalR UserTyping parse error: $e');
          }
        }
      });

      // Connection state handlers
      _hubConnection!.onclose(({error}) {
        _isConnected = false;
        _connectionController.add(false);
        debugPrint('SignalR disconnected: $error');
      });

      _hubConnection!.onreconnecting(({error}) {
        _isConnected = false;
        _connectionController.add(false);
        debugPrint('SignalR reconnecting: $error');
      });

      _hubConnection!.onreconnected(({connectionId}) {
        _isConnected = true;
        _connectionController.add(true);
        debugPrint('SignalR reconnected: $connectionId');
      });

      await _hubConnection!.start();
      _isConnected = true;
      _connectionController.add(true);
      debugPrint('SignalR connected to $_baseUrl$_hubPath');
    } catch (e) {
      debugPrint('SignalR connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
      // Retry after 5 seconds
      Future.delayed(const Duration(seconds: 5), () => startConnection());
    }
  }

  /// Join a specific chat room to receive messages.
  Future<void> joinChat(String chatId) async {
    if (_hubConnection != null && _isConnected) {
      try {
        await _hubConnection!.invoke('JoinChat', args: [chatId]);
      } catch (e) {
        debugPrint('SignalR joinChat error: $e');
      }
    }
  }

  /// Leave a specific chat room.
  Future<void> leaveChat(String chatId) async {
    if (_hubConnection != null && _isConnected) {
      try {
        await _hubConnection!.invoke('LeaveChat', args: [chatId]);
      } catch (e) {
        debugPrint('SignalR leaveChat error: $e');
      }
    }
  }

  /// Send a typing indicator to the chat room.
  Future<void> sendTypingIndicator(String chatId) async {
    if (_hubConnection != null && _isConnected) {
      try {
        await _hubConnection!.invoke('TypingIndicator', args: [chatId]);
      } catch (e) {
        debugPrint('SignalR typingIndicator error: $e');
      }
    }
  }

  /// Stop the SignalR connection.
  Future<void> stopConnection() async {
    try {
      await _hubConnection?.stop();
    } catch (_) {}
    _isConnected = false;
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
  }

  /// Dispose all stream controllers.
  void dispose() {
    stopConnection();
    _messageController.close();
    _typingController.close();
    _connectionController.close();
  }
}

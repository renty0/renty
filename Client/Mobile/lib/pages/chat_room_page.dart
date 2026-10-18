import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/chat_signalr_service.dart';
import 'package:renty/main.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local message model
// ─────────────────────────────────────────────────────────────────────────────
class _ChatMsg {
  String id;
  final int? senderId;
  final String? message;
  final String? mediaUrl;
  final int messageType; // 0=text, 1=image, 2=video, 3=audio, 4=document
  final DateTime? createdAt;
  bool isOptimistic;

  _ChatMsg({
    required this.id,
    this.senderId,
    this.message,
    this.mediaUrl,
    this.messageType = 0,
    this.createdAt,
    this.isOptimistic = false,
  });

  factory _ChatMsg.fromDto(ChatMessageDto dto) => _ChatMsg(
    id: dto.id ?? '',
    senderId: dto.senderId,
    message: dto.message,
    mediaUrl: dto.mediaUrl,
    messageType: _resolveType(dto.messageType),
    createdAt: dto.createdAt,
  );

  /// Resolve typed enum or raw int to an int.
  static int _resolveType(dynamic t) {
    if (t == null) return 0;
    if (t is int) return t;
    // MessageType enum — read its index or name
    final s = t.toString().toLowerCase();
    if (s.contains('image') || s == '1') return 1;
    if (s.contains('video') || s == '2') return 2;
    if (s.contains('audio') || s == '3') return 3;
    if (s.contains('document') || s.contains('pdf') || s == '4') return 4;
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChatRoomPage
// ─────────────────────────────────────────────────────────────────────────────
class ChatRoomPage extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String? otherUserImage;
  final String? contextItemId;
  final String? contextItemTitle;
  final bool isSupport;

  const ChatRoomPage({
    super.key,
    required this.chatId,
    required this.otherUserName,
    this.otherUserImage,
    this.contextItemId,
    this.contextItemTitle,
    this.isSupport = false,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _signalr = ChatSignalrService();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();

  List<_ChatMsg> _messages = [];
  GetChatMessagesResponseChatMetadata? _chatMetadata;

  bool _isLoading = true;
  bool _isSending = false;
  int? _currentUserId;
  StreamSubscription? _msgSub;

  // Voice
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordingPath;

  // Queued images
  List<XFile> _queuedImages = [];

  // Full-screen preview
  String? _previewUrl;

  // Support ticket state
  String? _activeSupportTicketId;
  final List<String> _activeSupportTicketIds = [];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _currentUserId = int.tryParse(cachedUserId ?? ''); // SECURITY: in-memory cache from Keystore/Keychain
    if (!widget.isSupport) {
      _initSignalR();
    }
    _loadMessages();
  }

  Future<void> _initSignalR() async {
    await _signalr.startConnection();
    await _signalr.joinChat(widget.chatId);
    _msgSub = _signalr.onMessage.listen((msg) {
      if (msg.chatId == widget.chatId && mounted) {
        setState(() {
          // Deduplicate by real ID first
          if (_messages.any((m) => m.id == (msg.id ?? '') && !m.isOptimistic))
            return;

          // Upgrade matching optimistic message
          final optIdx = _messages.indexWhere(
            (m) =>
                m.isOptimistic &&
                m.messageType == (msg.messageType ?? 0) &&
                m.message == msg.message,
          );

          final incoming = _ChatMsg(
            id: msg.id ?? 'sr_${DateTime.now().millisecondsSinceEpoch}',
            senderId: msg.senderId,
            message: msg.message,
            mediaUrl: _resolveMediaUrl(msg.mediaUrl),
            messageType: msg.messageType ?? 0,
            createdAt: msg.createdAt ?? DateTime.now(),
          );

          if (optIdx >= 0) {
            _messages[optIdx] = incoming;
          } else {
            _messages.add(incoming);
          }
        });
        _scrollToBottom();

        // Play default notification sound if message is from the other user
        if (msg.senderId != _currentUserId) {
          FlutterRingtonePlayer().playNotification();
        }
      }
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    if (!widget.isSupport) {
      _signalr.leaveChat(widget.chatId);
      _signalr.dispose();
    }
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _recordingTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  Future<void> _loadMessages() async {
    if (widget.isSupport) {
      await _loadSupportMessages();
    } else {
      await _loadChatMessages();
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      final resp = await ApiService.chat.getChatMessages(widget.chatId);
      if (!mounted) return;
      setState(() {
        _messages = (resp?.data?.messages ?? [])
            .map((m) => _ChatMsg.fromDto(m))
            .toList();
        _chatMetadata = resp?.data?.chatMetadata;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSupportMessages() async {
    try {
      final resp = await ApiService.support.getSupportTickets();
      final tickets = resp?.data?.tickets ?? [];

      _activeSupportTicketIds.clear();

      // Identify valid ticket IDs and pick the active one
      final validTickets = <({String id, String status})>[];
      for (final t in tickets) {
        final ticketId = t.id;
        if (ticketId == null) continue;
        _activeSupportTicketIds.add(ticketId);
        final status = (t.status ?? '').toLowerCase();
        validTickets.add((id: ticketId, status: status));
        if (_activeSupportTicketId == null &&
            status != 'resolved' && status != 'closed') {
          _activeSupportTicketId = ticketId;
        }
      }

      // Load all ticket details in PARALLEL instead of sequentially
      final detailResults = await Future.wait(
        validTickets.map((t) async {
          try {
            return await ApiService.support.getSupportTicketDetails(t.id);
          } catch (_) {
            return null; // skip failed tickets
          }
        }),
      );

      final List<_ChatMsg> allMessages = [];
      for (final detail in detailResults) {
        final msgs = detail?.data?.ticket?.messages ?? [];
        for (final m in msgs) {
          allMessages.add(_ChatMsg(
            id:          m.id ?? 'sup_${DateTime.now().millisecondsSinceEpoch}',
            senderId:    m.senderId,
            message:     m.message,
            mediaUrl:    _resolveMediaUrl(m.mediaUrl),
            messageType: m.messageType?.value ?? 0,
            createdAt:   m.createdAt ?? DateTime.now(),
          ));
        }
      }

      allMessages.sort((a, b) =>
          (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));

      if (mounted) {
        setState(() {
          _messages = allMessages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Online status ──────────────────────────────────────────────────────────

  /// Online status: approximate from lastMessageAt on the metadata
  /// (otherUserLastLoginAt is not in the generated typed model; we use
  /// lastMessageAt as a proxy — active if last message was within 5 min).
  bool _isOnline() {
    final dt = _chatMetadata?.lastMessageAt;
    if (dt == null) return false;
    return DateTime.now().difference(dt).inMinutes <= 5;
  }

  String _lastSeenText() {
    final dt = _chatMetadata?.lastMessageAt;
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Active now'.tr;
    if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Last seen ${diff.inHours} hrs ago';
    return 'Last seen ${DateFormat('MMM d').format(dt)}';
  }

  // ── Send Text Message ──────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text   = _msgCtrl.text.trim();
    final images = List<XFile>.from(_queuedImages);

    if (text.isEmpty && images.isEmpty) return;
    if (_isSending) return;

    setState(() => _isSending = true);
    _msgCtrl.clear();
    _queuedImages.clear();

    try {
      if (widget.isSupport) {
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++) {
            final caption = (i == 0 && text.isNotEmpty) ? text : null;
            await _uploadAndSendMedia(images[i], 1, caption);
          }
        } else {
          await _sendSupportMessage(text: text);
        }
      } else {
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++) {
            final caption = (i == 0 && text.isNotEmpty) ? text : null;
            await _uploadAndSendMedia(images[i], 1, caption);
          }
        } else {
          await _sendRegularText(text);
        }
      }
    } catch (_) {
      AppNavigator.showSnackBar(
        'Error'.tr, 'Failed to send message'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        textColor: Colors.white,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendRegularText(String text) async {
    final optId = 'opt_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _messages.add(_ChatMsg(
        id: optId, senderId: _currentUserId,
        message: text, createdAt: DateTime.now(), isOptimistic: true,
      ));
    });
    _scrollToBottom();

    final response = await ApiService.client.invokeAPI(
      '/api/v1/chats/${widget.chatId}/messages',
      'POST',
      <QueryParam>[],
      {
        'chatId': widget.chatId,
        'message': text,
        'mediaUrl': null,
        'messageType': 0,
      },
      <String, String>{},
      <String, String>{},
      'application/json',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final messageId = decoded['data']?['messageId'] as String?;
      if (mounted && messageId != null) {
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == optId);
          if (idx >= 0) {
            _messages[idx].id          = messageId;
            _messages[idx].isOptimistic = false;
          }
        });
      }
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  Future<String?> _createSupportTicket(String subject, String description) async {
    try {
      final response = await ApiService.client.invokeAPI(
        '/api/v1/support/tickets',
        'POST',
        <QueryParam>[],
        {
          'type': 'General',
          'subject': subject,
          'message': description,
          'isAutoGenerated': false,
        },
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        return body['data']?['ticketId'] as String?;
      }
    } catch (e) {
      print('Error creating support ticket: $e');
    }
    return null;
  }

  /// Support-mode send: creates ticket if none active, then posts message.
  Future<void> _sendSupportMessage({required String text, List<XFile> images = const []}) async {
    // Ensure there is an active support ticket
    if (_activeSupportTicketId == null) {
      _activeSupportTicketId = await _createSupportTicket(
        'Support Request',
        text.isNotEmpty ? text : '[Media Attachment]',
      );
    }

    final ticketId = _activeSupportTicketId;
    if (ticketId == null) return;

    // Optimistic update
    final optId = 'opt_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _messages.add(_ChatMsg(
        id: optId, senderId: _currentUserId,
        message: text, createdAt: DateTime.now(), isOptimistic: true,
      ));
    });
    _scrollToBottom();

    final response = await ApiService.client.invokeAPI(
      '/api/v1/support/tickets/$ticketId/messages',
      'POST',
      <QueryParam>[],
      {
        'ticketId': ticketId,
        'message': text,
        'mediaUrl': null,
        'messageType': 0,
        'isSupportAgent': false,
      },
      <String, String>{},
      <String, String>{},
      'application/json',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _loadSupportMessages();
    } else {
      throw Exception('Failed to send support message: ${response.statusCode}');
    }
  }

  // ── Upload + Send Media ────────────────────────────────────────────────────

  Future<void> _uploadAndSendMedia(
    XFile file,
    int msgType,
    String? caption,
  ) async {
    final optId = 'opt_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final localPath = file.path;

    setState(() {
      _messages.add(
        _ChatMsg(
          id: optId,
          senderId: _currentUserId,
          message: caption,
          mediaUrl: localPath,
          messageType: msgType,
          createdAt: DateTime.now(),
          isOptimistic: true,
        ),
      );
    });
    _scrollToBottom();

    try {
      print('--- UPLOADING MEDIA ---');
      print('Uploading file path: ${file.path}');
      
      // Resolve content type from file extension (backend rejects application/octet-stream)
      final ext = file.name.split('.').last.toLowerCase();
      final mimeMap = {
        'jpg': MediaType('image', 'jpeg'),
        'jpeg': MediaType('image', 'jpeg'),
        'png': MediaType('image', 'png'),
        'gif': MediaType('image', 'gif'),
        'webp': MediaType('image', 'webp'),
        'heic': MediaType('image', 'heic'),
        'm4a': MediaType('audio', 'mp4'),
        'aac': MediaType('audio', 'aac'),
        'mp3': MediaType('audio', 'mpeg'),
        'wav': MediaType('audio', 'wav'),
        'ogg': MediaType('audio', 'ogg'),
        'mp4': MediaType('video', 'mp4'),
        'mov': MediaType('video', 'quicktime'),
      };
      final contentType = mimeMap[ext] ?? MediaType('application', 'octet-stream');
      print('File ext: $ext, contentType: $contentType');
      
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.name,
        contentType: contentType,
      );
      
      final response = await ApiService.media.uploadMedia(file: multipartFile);
      print('Upload response data: ${response?.toJson()}');
      
      final url = response?.data?.url;

      if (url != null) {
        final resolvedUrl = _resolveMediaUrl(url)!;
        print('Resolved Media URL: $resolvedUrl');
        if (widget.isSupport) {
          if (_activeSupportTicketId == null) {
            _activeSupportTicketId = await _createSupportTicket(
              'Support Request',
              caption ?? '[Media Attachment]',
            );
          }
          final ticketId = _activeSupportTicketId;
          if (ticketId != null) {
            final response = await ApiService.client.invokeAPI(
              '/api/v1/support/tickets/$ticketId/messages',
              'POST',
              <QueryParam>[],
              {
                'ticketId': ticketId,
                'message': caption,
                'mediaUrl': resolvedUrl,
                'messageType': msgType,
                'isSupportAgent': false,
              },
              <String, String>{},
              <String, String>{},
              'application/json',
            );
            print('Send Support Media response: ${response.statusCode} - ${response.body}');
            if (response.statusCode >= 200 && response.statusCode < 300) {
              await _loadSupportMessages();
            } else {
              throw Exception('Failed to send support media message: ${response.statusCode}');
            }
          }
        } else {
          final response = await ApiService.client.invokeAPI(
            '/api/v1/chats/${widget.chatId}/messages',
            'POST',
            <QueryParam>[],
            {
              'chatId': widget.chatId,
              'message': caption,
              'mediaUrl': resolvedUrl,
              'messageType': msgType,
            },
            <String, String>{},
            <String, String>{},
            'application/json',
          );
          print('Send Chat Media response: ${response.statusCode} - ${response.body}');
          if (response.statusCode < 200 || response.statusCode >= 300) {
            throw Exception('Failed to send chat media message: ${response.statusCode}');
          }
        }
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.id == optId);
            if (idx >= 0) {
              _messages[idx] = _ChatMsg(
                id: 'sent_${DateTime.now().millisecondsSinceEpoch}',
                senderId: _currentUserId,
                message: caption,
                mediaUrl: resolvedUrl,
                messageType: msgType,
                createdAt: DateTime.now(),
              );
            }
          });
        }
      } else {
        print('Upload failed or returned null URL.');
        if (mounted)
          setState(() => _messages.removeWhere((m) => m.id == optId));
      }
    } catch (e, stack) {
      print('Error in _uploadAndSendMedia: $e');
      print(stack);
      if (mounted) setState(() => _messages.removeWhere((m) => m.id == optId));
    }
  }

  // ── Image Picking ──────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty && mounted)
      setState(() => _queuedImages.addAll(files));
  }

  // ── Voice Recording ────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    if (_isRecording) return;
    final ok = await _recorder.hasPermission();
    if (!ok) return;
    final dir = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _recordingPath!,
    );
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordingSeconds++);
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path != null) await _uploadAndSendMedia(XFile(path), 3, null);
  }

  // ── Delete Chat ────────────────────────────────────────────────────────────

  Future<void> _deleteChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Conversation'.tr),
        content: Text(
          'Are you sure you want to delete this conversation? This cannot be undone.'
              .tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ApiService.client.invokeAPI(
          '/api/v1/chats/${widget.chatId}',
          'DELETE',
          [],
          null,
          {},
          {},
          null,
        );
        if (mounted) Navigator.pop(context);
      } catch (_) {
        AppNavigator.showSnackBar('Error'.tr, 'Failed to delete chat'.tr, isError: true);
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatDuration(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  /// Ensures media URL is always absolute and fixes double-URL patterns
  /// from backend (e.g. "http://base/https://cloudinary..." → "https://cloudinary...")
  String? _resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Fix double-URL: backend sometimes prepends its base to already-absolute URLs
    final idx = url.indexOf('/http');
    if (idx > 0) {
      final inner = url.substring(idx + 1);
      if (inner.startsWith('http://') || inner.startsWith('https://')) {
        return inner;
      }
    }

    if (url.startsWith('/') || (!url.startsWith('http'))) {
      return 'https://starfish-app-vavqt.ondigitalocean.app/${url.replaceAll(RegExp(r'^/+'), '')}';
    }
    return url;
  }

  /// Open URL in system player / browser
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Format message timestamp
  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('HH:mm').format(dt.toLocal());
  }

  /// Format date separator
  String _formatDateSeparator(DateTime dt) {
    final now = DateTime.now();
    final local = dt.toLocal();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return 'Today'.tr;
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day) {
      return 'Yesterday'.tr;
    }
    return DateFormat('MMM d, y').format(local);
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          if (_chatMetadata?.itemId != null) _buildItemBanner(isDark),
          Expanded(child: _buildMessageArea(isDark)),
          if (_queuedImages.isNotEmpty) _buildImageQueue(isDark),
          _buildInputArea(isDark),
        ],
      ),
      // Full-screen preview
      floatingActionButton: null,
    );
  }

  // ── AppBar with online status ──────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool isDark) {
    // ── Support mode AppBar ──────────────────────────────────────────────────
    if (widget.isSupport) {
      return AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Support Team'.tr,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('We\'ll reply as soon as possible'.tr,
                  style: const TextStyle(fontSize: 11, color: Colors.white60)),
            ],
          )),
        ]),
      );
    }

    // ── Regular chat AppBar ──────────────────────────────────────────────────
    final online     = _isOnline();
    final statusText = _lastSeenText();
    final firstName  = _chatMetadata?.otherUserFirstName ?? widget.otherUserName;
    final lastName   = _chatMetadata?.otherUserLastName ?? '';
    final fullName   = '$firstName $lastName'.trim();
    final avatarUrl  = _resolveMediaUrl(
      _chatMetadata?.otherUserProfileImage ?? widget.otherUserImage,
    );

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: online ? AppColor.successColor : Colors.transparent, width: 2,
            ),
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: avatarUrl, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _buildInitialsAvatar(fullName),
                  )
                : _buildInitialsAvatar(fullName),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            if (statusText.isNotEmpty)
              Text(statusText, style: TextStyle(
                fontSize: 11,
                color: online ? AppColor.successColor : Colors.white60,
                fontWeight: FontWeight.w400,
              )),
          ],
        )),
      ]),
      actions: [
        IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteChat),
      ],
    );
  }

  Widget _buildInitialsAvatar(String name) => Container(
    color: AppColor.fourthColor,
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );

  // ── Item Banner ────────────────────────────────────────────────────────────

  Widget _buildItemBanner(bool isDark) {
    final meta = _chatMetadata!;
    final imageUrl = _resolveMediaUrl(meta.itemImage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : AppColor.primaryColor.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          // Item thumbnail
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  color: AppColor.borderGray,
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          if (imageUrl != null) const SizedBox(width: 10),
          if (imageUrl == null)
            const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: AppColor.primaryColor,
            ),
          if (imageUrl == null) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.itemTitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColor.darkText,
                  ),
                ),
                Text(
                  'View Item'.tr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColor.fourthColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColor.fourthColor,
          ),
        ],
      ),
    );
  }

  // ── Message List with date separators ─────────────────────────────────────

  Widget _buildMessageArea(bool isDark) {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: AppColor.fourthColor),
      );
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: isDark ? Colors.white24 : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet. Say hello!'.tr,
              style: TextStyle(
                color: isDark ? Colors.white30 : AppColor.lightText,
              ),
            ),
          ],
        ),
      );
    }

    // Build flat list with date separators
    final items = <dynamic>[];
    DateTime? lastDate;
    for (final msg in _messages) {
      if (!_isSameDay(lastDate, msg.createdAt)) {
        items.add(msg.createdAt); // date separator marker
        lastDate = msg.createdAt;
      }
      items.add(msg);
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            if (item is DateTime) return _buildDateSeparator(item, isDark);
            return _buildBubble(item as _ChatMsg, isDark);
          },
        ),
        // Full-screen image overlay
        if (_previewUrl != null)
          GestureDetector(
            onTap: () => setState(() => _previewUrl = null),
            child: Container(
              color: Colors.black.withValues(alpha: 0.9),
              child: SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => setState(() => _previewUrl = null),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InteractiveViewer(
                        child: _previewUrl!.startsWith('/')
                            ? Image.file(
                                File(_previewUrl!),
                                fit: BoxFit.contain,
                              )
                            : CachedNetworkImage(
                                imageUrl: _previewUrl!,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSeparator(DateTime dt, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _formatDateSeparator(dt),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white38 : AppColor.lightText,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  // ── Message Bubble ─────────────────────────────────────────────────────────

  Widget _buildBubble(_ChatMsg msg, bool isDark) {
    final isMine = msg.senderId == _currentUserId;
    final bubbleColor = isMine
        ? AppColor.primaryColor
        : (isDark ? const Color(0xFF2C2C2C) : Colors.white);
    final textColor = isMine
        ? Colors.white
        : (isDark ? Colors.white : AppColor.darkText);
    final timeStr = _formatTime(msg.createdAt);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsetsDirectional.only(
          bottom: 6,
          start: isMine ? 60 : 0,
          end: isMine ? 0 : 60,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(16),
            topEnd: const Radius.circular(16),
            bottomStart: Radius.circular(isMine ? 16 : 4),
            bottomEnd: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── type 1: Image ─────────────────────────────────────────────────
            if (msg.messageType == 1 && msg.mediaUrl != null)
              GestureDetector(
                onTap: () => setState(() => _previewUrl = msg.mediaUrl),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Opacity(
                    opacity: msg.isOptimistic ? 0.6 : 1.0,
                    child: _buildNetworkOrLocalImage(msg.mediaUrl!, 200),
                  ),
                ),
              ),

            // ── type 2: Video ─────────────────────────────────────────────────
            if (msg.messageType == 2 && msg.mediaUrl != null)
              GestureDetector(
                onTap: () => _openUrl(msg.mediaUrl!),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Opacity(
                    opacity: msg.isOptimistic ? 0.6 : 1.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildNetworkOrLocalImage(msg.mediaUrl!, 180),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VIDEO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── type 3: Audio ─────────────────────────────────────────────────
            if (msg.messageType == 3 && msg.mediaUrl != null)
              GestureDetector(
                onTap: () => _openUrl(msg.mediaUrl!),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isMine ? Colors.white : AppColor.primaryColor)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: isMine ? Colors.white : AppColor.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color:
                                    (isMine
                                            ? Colors.white
                                            : AppColor.primaryColor)
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Voice message'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                color: isMine
                                    ? Colors.white70
                                    : AppColor.mediumText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: isMine ? Colors.white54 : AppColor.grey,
                      ),
                    ],
                  ),
                ),
              ),

            // ── type 4: Document / PDF ────────────────────────────────────────
            if (msg.messageType == 4 && msg.mediaUrl != null)
              GestureDetector(
                onTap: () => _openUrl(msg.mediaUrl!),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.red,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Document.pdf',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Tap to view'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                color: isMine
                                    ? Colors.white60
                                    : AppColor.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: isMine ? Colors.white54 : AppColor.grey,
                      ),
                    ],
                  ),
                ),
              ),

            // ── Text content ──────────────────────────────────────────────────
            if (msg.message != null && msg.message!.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  msg.messageType != 0 ? 6 : 10,
                  14,
                  4,
                ),
                child: _buildMessageText(
                  msg.message!,
                  TextStyle(fontSize: 14, color: textColor, height: 1.4),
                ),
              ),

            // ── Timestamp + pending indicator ─────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (timeStr.isNotEmpty)
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMine
                              ? Colors.white60
                              : (isDark ? Colors.white38 : AppColor.lightText),
                        ),
                      ),
                    if (msg.isOptimistic) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.schedule,
                        size: 10,
                        color: isMine ? Colors.white60 : AppColor.lightText,
                      ),
                    ] else if (isMine) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all, size: 12, color: Colors.white60),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOrLocalImage(String url, double height) {
    if (url.startsWith('/') || (!url.startsWith('http') && url.contains('/'))) {
      return Image.file(
        File(url),
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => Container(
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 40),
      ),
    );
  }

  // ── Image Queue ────────────────────────────────────────────────────────────

  Widget _buildImageQueue(bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _queuedImages.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_queuedImages[i].path),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: () => setState(() => _queuedImages.removeAt(i)),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Input Area ─────────────────────────────────────────────────────────────

  Widget _buildInputArea(bool isDark) {
    final inputBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF2C2C2C) : AppColor.backgroundcolor;

    if (_isRecording) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        color: Colors.red.shade50,
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatDuration(_recordingSeconds),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Recording...'.tr,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        10,
        8,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: inputBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add_photo_alternate_outlined,
              color: isDark ? Colors.white54 : AppColor.mediumText,
            ),
            onPressed: _pickImages,
          ),
          IconButton(
            icon: Icon(
              Icons.mic_none_outlined,
              color: isDark ? Colors.white54 : AppColor.mediumText,
            ),
            onPressed: _startRecording,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgCtrl,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColor.darkText,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...'.tr,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColor.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  /// Renders the text content of a chat message with the given [style].
  Widget _buildMessageText(String text, TextStyle style) {
    if (!text.contains('**')) {
      return Text(text, style: style);
    }
    final parts = text.split('**');
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(
        TextSpan(
          text: parts[i],
          style: i % 2 == 1
              ? style.copyWith(fontWeight: FontWeight.bold)
              : style,
        ),
      );
    }
    return Text.rich(
      TextSpan(children: spans),
      style: style,
    );
  }
}

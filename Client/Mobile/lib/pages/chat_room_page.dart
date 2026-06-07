import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/chat_signalr_service.dart';
import 'package:renty/main.dart';

/// A local message model that supports optimistic updates and media types.
class _ChatMsg {
  String id;
  final int? senderId;
  final String? message;
  final String? mediaUrl;
  final int messageType; // 0=text, 1=image, 2=video, 3=audio
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
        createdAt: dto.createdAt,
      );
}

class ChatRoomPage extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String? otherUserImage;
  final String? contextItemId;
  final String? contextItemTitle;

  const ChatRoomPage({
    super.key,
    required this.chatId,
    required this.otherUserName,
    this.otherUserImage,
    this.contextItemId,
    this.contextItemTitle,
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
  bool _isLoading = true;
  bool _isSending = false;
  int? _currentUserId;
  StreamSubscription? _msgSub;

  // Voice recording state
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordingPath;

  // Image queue
  List<XFile> _queuedImages = [];

  // Fullscreen image preview
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _currentUserId = int.tryParse(sharedPref.getString('user_id') ?? '');
    _initSignalR();
    _loadMessages();
  }

  Future<void> _initSignalR() async {
    await _signalr.startConnection();
    await _signalr.joinChat(widget.chatId);
    _msgSub = _signalr.onMessage.listen((msg) {
      if (msg.chatId == widget.chatId && mounted) {
        setState(() {
          // Remove matching optimistic message
          _messages.removeWhere((m) =>
              m.isOptimistic &&
              m.message == msg.message &&
              m.mediaUrl == msg.mediaUrl);
          _messages.add(_ChatMsg(
            id: msg.id ?? 'sr_${DateTime.now().millisecondsSinceEpoch}',
            senderId: msg.senderId,
            message: msg.message,
            mediaUrl: msg.mediaUrl,
            messageType: msg.messageType ?? 0,
            createdAt: msg.createdAt ?? DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _signalr.leaveChat(widget.chatId);
    _signalr.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _recordingTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final resp = await ApiService.chat.getChatMessages(widget.chatId);
      if (!mounted) return;
      setState(() {
        _messages = (resp?.data?.messages ?? []).map((m) => _ChatMsg.fromDto(m)).toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
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

  // ── Send Text Message ──
  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    final images = List<XFile>.from(_queuedImages);

    if (text.isEmpty && images.isEmpty) return;
    if (_isSending) return;

    setState(() => _isSending = true);
    _msgCtrl.clear();
    _queuedImages.clear();

    try {
      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final caption = (i == 0 && text.isNotEmpty) ? text : null;
          await _uploadAndSendMedia(images[i], 1, caption);
        }
      } else {
        // Text-only with optimistic update
        final optId = 'opt_${DateTime.now().millisecondsSinceEpoch}';
        setState(() {
          _messages.add(_ChatMsg(
            id: optId,
            senderId: _currentUserId,
            message: text,
            createdAt: DateTime.now(),
            isOptimistic: true,
          ));
        });
        _scrollToBottom();

        final resp = await ApiService.chat.postChatMessage(
          widget.chatId,
          PostChatMessageCommand(chatId: widget.chatId, message: text),
        );
        if (mounted && resp?.data?.messageId != null) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.id == optId);
            if (idx >= 0) {
              _messages[idx].id = resp!.data!.messageId ?? optId;
              _messages[idx].isOptimistic = false;
            }
          });
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message',
          backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ── Upload Media & Send ──
  Future<void> _uploadAndSendMedia(XFile file, int msgType, String? caption) async {
    final optId = 'opt_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final localPath = file.path;

    setState(() {
      _messages.add(_ChatMsg(
        id: optId,
        senderId: _currentUserId,
        message: caption,
        mediaUrl: localPath,
        messageType: msgType,
        createdAt: DateTime.now(),
        isOptimistic: true,
      ));
    });
    _scrollToBottom();

    try {
      // Upload via raw http.MultipartRequest to avoid MultipartFile type issues
      final token = sharedPref.getString('token') ?? '';
      final uri = Uri.parse('${ApiService.client.basePath}/api/v1/media');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: file.name));

      final streamResp = await request.send();
      final respBody = await streamResp.stream.bytesToString();
      String? url;
      if (streamResp.statusCode >= 200 && streamResp.statusCode < 300) {
        final json = jsonDecode(respBody);
        url = json['data']?['url'];
      }

      if (url != null) {
        await ApiService.chat.postChatMessage(
          widget.chatId,
          PostChatMessageCommand(chatId: widget.chatId, message: caption ?? url),
        );
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.id == optId);
            if (idx >= 0) {
              _messages[idx] = _ChatMsg(
                id: 'sent_${DateTime.now().millisecondsSinceEpoch}',
                senderId: _currentUserId,
                message: caption,
                mediaUrl: url,
                messageType: msgType,
                createdAt: DateTime.now(),
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _messages.removeWhere((m) => m.id == optId));
    }
  }

  // ── Image Picking ──
  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty && mounted) {
      setState(() => _queuedImages.addAll(files));
    }
  }

  // ── Voice Recording ──
  Future<void> _startRecording() async {
    if (_isRecording) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    _recordingPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: _recordingPath!);
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

    if (path != null) {
      await _uploadAndSendMedia(XFile(path), 3, null);
    }
  }

  // ── Delete Chat ──
  Future<void> _deleteChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        // Use raw API since deleteChat may not be in generated client
        await ApiService.client.invokeAPI('/api/v1/chats/${widget.chatId}', 'DELETE', [], null, {}, {}, null);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete chat');
      }
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(isDark),
      body: Column(children: [
        // Product context header
        if (widget.contextItemTitle != null) _buildProductContext(isDark),
        // Messages
        Expanded(child: _buildMessageArea(isDark)),
        // Image queue
        if (_queuedImages.isNotEmpty) _buildImageQueue(isDark),
        // Input area
        _buildInputArea(isDark),
      ]),
      // Full-screen image preview
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white24,
          backgroundImage: widget.otherUserImage != null ? NetworkImage(widget.otherUserImage!) : null,
          child: widget.otherUserImage == null
              ? Text(widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(widget.otherUserName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
      actions: [
        IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteChat, tooltip: 'Delete Chat'),
      ],
    );
  }

  Widget _buildProductContext(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColor.primaryColor.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: Row(children: [
        Icon(Icons.inventory_2_outlined, size: 18, color: AppColor.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(widget.contextItemTitle ?? '',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColor.darkText),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Text('View Item', style: TextStyle(fontSize: 12, color: AppColor.fourthColor, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildMessageArea(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColor.fourthColor));
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: isDark ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No messages yet. Say hello!',
              style: TextStyle(color: isDark ? Colors.white30 : AppColor.lightText)),
        ]),
      );
    }
    return Stack(children: [
      ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (ctx, i) => _buildBubble(_messages[i], isDark),
      ),
      // Fullscreen preview overlay
      if (_previewUrl != null)
        GestureDetector(
          onTap: () => setState(() => _previewUrl = null),
          child: Container(
            color: Colors.black87,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => setState(() => _previewUrl = null),
                    ),
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    child: _previewUrl!.startsWith('/')
                        ? Image.file(File(_previewUrl!), fit: BoxFit.contain)
                        : Image.network(_previewUrl!, fit: BoxFit.contain),
                  ),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }

  Widget _buildBubble(_ChatMsg msg, bool isDark) {
    final isMine = msg.senderId == _currentUserId;
    final bubbleColor = isMine ? AppColor.primaryColor : (isDark ? const Color(0xFF2C2C2C) : Colors.white);
    final textColor = isMine ? Colors.white : (isDark ? Colors.white : AppColor.darkText);
    final time = msg.createdAt;
    final timeStr = time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8, left: isMine ? 60 : 0, right: isMine ? 0 : 60),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          // Image message
          if (msg.messageType == 1 && msg.mediaUrl != null)
            GestureDetector(
              onTap: () => setState(() => _previewUrl = msg.mediaUrl),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Opacity(
                  opacity: msg.isOptimistic ? 0.6 : 1.0,
                  child: msg.mediaUrl!.startsWith('/')
                      ? Image.file(File(msg.mediaUrl!), width: double.infinity, height: 200, fit: BoxFit.cover)
                      : Image.network(msg.mediaUrl!, width: double.infinity, height: 200, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(height: 100, color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 40))),
                ),
              ),
            ),
          // Audio message
          if (msg.messageType == 3 && msg.mediaUrl != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Icon(Icons.audiotrack_rounded, color: isMine ? Colors.white70 : AppColor.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(height: 4, decoration: BoxDecoration(
                    color: (isMine ? Colors.white : AppColor.primaryColor).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  )),
                ),
                const SizedBox(width: 8),
                Text('Voice', style: TextStyle(fontSize: 12, color: isMine ? Colors.white60 : AppColor.mediumText)),
              ]),
            ),
          // Text content
          if (msg.message != null && msg.message!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16, msg.messageType == 1 ? 8 : 10, 16, 4),
              child: Text(msg.message!, style: TextStyle(fontSize: 14, color: textColor, height: 1.4)),
            ),
          // Timestamp + optimistic indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (timeStr.isNotEmpty)
                Text(timeStr, style: TextStyle(fontSize: 10, color: isMine ? Colors.white60 : (isDark ? Colors.white38 : AppColor.lightText))),
              if (msg.isOptimistic) ...[
                const SizedBox(width: 4),
                Icon(Icons.schedule, size: 10, color: isMine ? Colors.white60 : AppColor.lightText),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildImageQueue(bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _queuedImages.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(File(_queuedImages[i].path), width: 60, height: 60, fit: BoxFit.cover),
            ),
            Positioned(top: -4, right: -4,
              child: GestureDetector(
                onTap: () => setState(() => _queuedImages.removeAt(i)),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    final inputBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF2C2C2C) : AppColor.backgroundcolor;

    if (_isRecording) {
      return Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        color: Colors.red.shade50,
        child: Row(children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(_formatDuration(_recordingSeconds),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red)),
          const SizedBox(width: 10),
          const Expanded(child: Text('Recording...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500))),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.stop, color: Colors.white, size: 22),
            ),
          ),
        ]),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(8, 10, 8, 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: inputBg,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        // Attach image
        IconButton(
          icon: Icon(Icons.add_photo_alternate_outlined, color: isDark ? Colors.white54 : AppColor.mediumText),
          onPressed: _pickImages,
        ),
        // Voice record
        IconButton(
          icon: Icon(Icons.mic_none_outlined, color: isDark ? Colors.white54 : AppColor.mediumText),
          onPressed: _startRecording,
        ),
        // Text field
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(24)),
            child: TextField(
              controller: _msgCtrl,
              style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: isDark ? Colors.white54 : AppColor.lightText),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Send button
        Container(
          decoration: const BoxDecoration(color: AppColor.primaryColor, shape: BoxShape.circle),
          child: IconButton(
            icon: _isSending
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send, color: Colors.white, size: 20),
            onPressed: _sendMessage,
          ),
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String _currentUserId = 'student-1';
  static const String _currentUserName = 'Zaferan Miftah';

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  int _messageIdCounter = 100;

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    final now = DateTime.now();
    _messages.addAll([
      MessageModel(
        id: '1',
        senderId: 'teacher-1',
        senderName: widget.receiverName,
        receiverId: _currentUserId,
        content: 'Hi Zaferan, do you have any questions about the database assignment?',
        sentAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        isRead: true,
      ),
      MessageModel(
        id: '2',
        senderId: _currentUserId,
        senderName: _currentUserName,
        receiverId: 'teacher-1',
        content: 'Hello! Yes, should we include ER diagrams in the report?',
        sentAt: now.subtract(const Duration(hours: 2, minutes: 10)),
        isRead: true,
      ),
      MessageModel(
        id: '3',
        senderId: 'teacher-1',
        senderName: widget.receiverName,
        receiverId: _currentUserId,
        content:
            'Yes, include ER diagrams and a short explanation of your normalization steps.',
        sentAt: now.subtract(const Duration(hours: 2, minutes: 5)),
        isRead: true,
      ),
      MessageModel(
        id: '4',
        senderId: _currentUserId,
        senderName: _currentUserName,
        receiverId: 'teacher-1',
        content: 'Got it, thank you! I will submit before Friday.',
        sentAt: now.subtract(const Duration(hours: 1, minutes: 50)),
        isRead: true,
      ),
      MessageModel(
        id: '5',
        senderId: 'teacher-1',
        senderName: widget.receiverName,
        receiverId: _currentUserId,
        content: 'Great. Let me know if you need help during office hours.',
        sentAt: now.subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSentByMe(MessageModel message) => message.senderId == _currentUserId;

  String _formatMessageTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messageIdCounter++;
      _messages.add(
        MessageModel(
          id: '$_messageIdCounter',
          senderId: _currentUserId,
          senderName: _currentUserName,
          receiverId: 'teacher-1',
          content: text,
          sentAt: DateTime.now(),
          isRead: false,
        ),
      );
      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.receiverName,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSent = _isSentByMe(message);
                return _MessageBubble(
                  message: message,
                  isSent: isSent,
                  formattedTime: _formatMessageTime(message.sentAt),
                );
              },
            ),
          ),
          _MessageInputBar(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSent;
  final String formattedTime;

  const _MessageBubble({
    required this.message,
    required this.isSent,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSent ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSent ? 16 : 4),
            bottomRight: Radius.circular(isSent ? 4 : 16),
          ),
          border: isSent
              ? null
              : Border.all(color: AppColors.divider),
          boxShadow: isSent
              ? null
              : [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isSent ? AppColors.card : AppColors.textDark,
                fontSize: 15,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    color: isSent
                        ? AppColors.card.withValues(alpha: 0.85)
                        : AppColors.textGrey,
                    fontSize: 11,
                  ),
                ),
                if (isSent) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: message.isRead
                        ? AppColors.success
                        : AppColors.card.withValues(alpha: 0.85),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: const Color(0xFF1A73E8),
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(24),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.send_rounded,
                  color: AppColors.card,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

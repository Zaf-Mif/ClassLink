import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../data/models/message_model.dart';
import '../../presentation/bloc/message_bloc.dart';
import '../../presentation/bloc/message_event.dart';
import '../../presentation/bloc/message_state.dart';

final sl = GetIt.instance;

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final UserModel currentUser;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSentByMe(MessageModel message) => message.senderId == widget.currentUser.id;

  String _formatMessageTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    context.read<MessageBloc>().add(SendMessage(
      receiverId: widget.receiverId,
      content: text,
    ));
    _messageController.clear();
  }

  void _scrollToBottom() {
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
      body: BlocProvider<MessageBloc>(
        create: (_) => sl<MessageBloc>()..add(LoadConversation(widget.receiverId)),
        child: BlocBuilder<MessageBloc, MessageState>(
          builder: (context, state) {
            if (state is MessageLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MessageError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (state is MessageLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                }
              });
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
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
              );
            }
            return const SizedBox.shrink();
          },
        ),
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

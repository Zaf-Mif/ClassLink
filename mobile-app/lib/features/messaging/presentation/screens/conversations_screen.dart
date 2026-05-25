import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/data/models/user_model.dart';
import 'chat_screen.dart';

class _ConversationItem {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const _ConversationItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });
}

class ConversationsScreen extends StatelessWidget {
  final UserModel? currentUser;

  const ConversationsScreen({super.key, this.currentUser});

  static final List<_ConversationItem> _conversations = [
    _ConversationItem(
      id: '1',
      name: 'Dr. Abebe Kebede',
      lastMessage: 'The assignment deadline is extended to Friday.',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
      unreadCount: 2,
    ),
    _ConversationItem(
      id: '2',
      name: 'Sara Mohammed',
      lastMessage: 'Thanks! I will submit the lab report tonight.',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
    ),
    _ConversationItem(
      id: '3',
      name: 'Course Rep — DB Systems',
      lastMessage: 'Reminder: quiz on Chapter 4 this Thursday.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
    ),
    _ConversationItem(
      id: '4',
      name: 'Prof. Helen Tadesse',
      lastMessage: 'Your project proposal looks good. See you in office hours.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
    ),
  ];

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 76,
          color: AppColors.divider,
        ),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _ConversationTile(
            conversation: conversation,
            formattedTime: _formatTime(conversation.lastMessageAt),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: conversation.id,
                    receiverName: conversation.name,
                    currentUser: widget.currentUser ?? UserModel(id: '', name: '', email: '', role: ''),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _ConversationItem conversation;
  final String formattedTime;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = conversation.name.isNotEmpty
        ? conversation.name.trim()[0].toUpperCase()
        : '?';

    return Material(
      color: AppColors.card,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.name,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: conversation.unreadCount > 0
                                ? AppColors.primary
                                : AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            style: TextStyle(
                              color: conversation.unreadCount > 0
                                  ? AppColors.textDark
                                  : AppColors.textGrey,
                              fontSize: 14,
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              conversation.unreadCount > 9
                                  ? '9+'
                                  : '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: AppColors.card,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

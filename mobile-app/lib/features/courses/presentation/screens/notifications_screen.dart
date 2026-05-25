import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum NotificationType {
  announcement,
  assignment,
  file,
  message,
  qaAnswer,
}

class AppNotification {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'New Announcement',
      subtitle: 'Dr. Ahmed posted in Database Systems',
      timeAgo: '5m ago',
      type: NotificationType.announcement,
    ),
    AppNotification(
      id: '2',
      title: 'Assignment Due Soon',
      subtitle: 'ER Diagram due in 2 days',
      timeAgo: '1h ago',
      type: NotificationType.assignment,
    ),
    AppNotification(
      id: '3',
      title: 'Question Answered',
      subtitle: 'Dr. Ahmed answered your question',
      timeAgo: '3h ago',
      type: NotificationType.qaAnswer,
    ),
    AppNotification(
      id: '4',
      title: 'New File Uploaded',
      subtitle: 'Chapter 2 Notes added to Mobile Dev',
      timeAgo: '1d ago',
      type: NotificationType.file,
      isRead: true,
    ),
    AppNotification(
      id: '5',
      title: 'New Message',
      subtitle: 'Dr. Sara sent you a message',
      timeAgo: '2d ago',
      type: NotificationType.message,
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markAsRead(AppNotification notification) {
    setState(() => notification.isRead = true);
  }

  ({Color bg, Color icon, IconData iconData}) _styleForType(
      NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return (
          bg: AppColors.primary.withValues(alpha: 0.12),
          icon: AppColors.primary,
          iconData: Icons.campaign_rounded,
        );
      case NotificationType.assignment:
        return (
          bg: AppColors.accent.withValues(alpha: 0.12),
          icon: AppColors.accent,
          iconData: Icons.assignment_rounded,
        );
      case NotificationType.file:
        return (
          bg: AppColors.success.withValues(alpha: 0.12),
          icon: AppColors.success,
          iconData: Icons.upload_file_rounded,
        );
      case NotificationType.message:
        return (
          bg: AppColors.primary.withValues(alpha: 0.12),
          icon: AppColors.primary,
          iconData: Icons.chat_bubble_rounded,
        );
      case NotificationType.qaAnswer:
        return (
          bg: AppColors.success.withValues(alpha: 0.12),
          icon: AppColors.success,
          iconData: Icons.check_circle_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final n = _notifications[index];
          final style = _styleForType(n.type);
          return _NotificationTile(
            notification: n,
            iconBg: style.bg,
            iconColor: style.icon,
            iconData: style.iconData,
            onTap: () => _markAsRead(n),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final Color iconBg;
  final Color iconColor;
  final IconData iconData;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.iconBg,
    required this.iconColor,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return Material(
      color: unread
          ? AppColors.primary.withValues(alpha: 0.06)
          : AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: unread
                ? null
                : [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            unread ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notification.timeAgo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (unread) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../../injection/injection_container.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    sl<NotificationBloc>().add(LoadNotifications());
  }

  void _markAllAsRead() {
    context.read<NotificationBloc>().add(MarkAllNotificationsRead());
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'announcement': return Icons.campaign_rounded;
      case 'assignment': return Icons.assignment_rounded;
      case 'file': return Icons.upload_file_rounded;
      case 'message': return Icons.chat_bubble_rounded;
      case 'forum': return Icons.help_outline_rounded;
      case 'answer': return Icons.check_circle_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'announcement': return AppColors.primary;
      case 'assignment': return AppColors.accent;
      case 'file': return AppColors.success;
      case 'message': return AppColors.primary;
      case 'forum': return AppColors.accent;
      case 'answer': return AppColors.success;
      default: return AppColors.textGrey;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'announcement': return 'Announcement';
      case 'assignment': return 'Assignment';
      case 'file': return 'File';
      case 'message': return 'Message';
      case 'forum': return 'Question';
      case 'answer': return 'Answer';
      default: return type;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
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
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => sl<NotificationBloc>().add(LoadNotifications()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is NotificationLoaded) {
            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications yet',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = notifications[index];
                final iconColor = _colorForType(n.type);
                final displayTitle = n.title.isNotEmpty ? n.title : _typeLabel(n.type);
                final displayMessage = n.message.isNotEmpty ? n.message : '';
                return _NotificationTile(
                  title: displayTitle,
                  subtitle: displayMessage,
                  typeLabel: _typeLabel(n.type),
                  timeAgo: _timeAgo(n.createdAt),
                  isRead: n.isRead,
                  iconBg: iconColor.withValues(alpha: 0.12),
                  iconColor: iconColor,
                  iconData: _iconForType(n.type),
                  onTap: () {
                    if (!n.isRead) {
                      context.read<NotificationBloc>().add(MarkNotificationRead(n.id));
                    }
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String typeLabel;
  final String timeAgo;
  final bool isRead;
  final Color iconBg;
  final Color iconColor;
  final IconData iconData;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.typeLabel,
    required this.timeAgo,
    required this.isRead,
    required this.iconBg,
    required this.iconColor,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: !isRead
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
            boxShadow: isRead
                ? [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: !isRead ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
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
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (!isRead) ...[
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

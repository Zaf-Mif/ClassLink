abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  MarkNotificationRead(this.notificationId);
}

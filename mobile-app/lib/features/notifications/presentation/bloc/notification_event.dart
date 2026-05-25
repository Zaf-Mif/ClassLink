abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  MarkNotificationRead(this.notificationId);
}

class MarkAllNotificationsRead extends NotificationEvent {}

class RegisterFcmToken extends NotificationEvent {
  final String token;
  RegisterFcmToken(this.token);
}

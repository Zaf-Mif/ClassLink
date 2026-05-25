import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
  }

  Future<void> _onLoad(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications = await _repository.getNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onMarkRead(MarkNotificationRead event, Emitter<NotificationState> emit) async {
    try {
      await _repository.markAsRead(event.notificationId);
      if (state is NotificationLoaded) {
        final current = (state as NotificationLoaded).notifications;
        final updated = current.map((n) =>
          n.id == event.notificationId
              ? NotificationModel(id: n.id, userId: n.userId, type: n.type, referenceId: n.referenceId, title: n.title, message: n.message, isRead: true, createdAt: n.createdAt)
              : n
        ).toList();
        emit(NotificationLoaded(updated));
      }
    } catch (_) {}
  }

  Future<void> _onMarkAllRead(MarkAllNotificationsRead event, Emitter<NotificationState> emit) async {
    try {
      await _repository.markAllAsRead();
      if (state is NotificationLoaded) {
        final current = (state as NotificationLoaded).notifications;
        final updated = current.map((n) =>
          NotificationModel(id: n.id, userId: n.userId, type: n.type, referenceId: n.referenceId, title: n.title, message: n.message, isRead: true, createdAt: n.createdAt)
        ).toList();
        emit(NotificationLoaded(updated));
      }
    } catch (_) {}
  }
}

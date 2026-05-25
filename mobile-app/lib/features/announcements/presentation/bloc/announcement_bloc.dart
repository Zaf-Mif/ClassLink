import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository _repository;

  AnnouncementBloc(this._repository) : super(AnnouncementInitial()) {
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<MarkAnnouncementRead>(_onMarkRead);
    on<CreateAnnouncement>(_onCreate);
  }

  Future<void> _onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      final announcements = await _repository.getAnnouncements(event.courseId);
      emit(AnnouncementLoaded(announcements));
    } catch (e) {
      emit(AnnouncementError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onMarkRead(
    MarkAnnouncementRead event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.announcementId);
      if (state is AnnouncementLoaded) {
        final current = (state as AnnouncementLoaded).announcements;
        final updated = current.map((a) {
          if (a.id == event.announcementId) {
            return AnnouncementModel(
              id: a.id,
              title: a.title,
              content: a.content,
              teacherName: a.teacherName,
              createdAt: a.createdAt,
              isRead: true,
            );
          }
          return a;
        }).toList();
        emit(AnnouncementLoaded(updated));
      }
    } catch (_) {}
  }

  Future<void> _onCreate(
    CreateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      final announcement = await _repository.createAnnouncement(
        title: event.title,
        content: event.content,
        courseId: event.courseId,
        sectionIds: event.sectionIds,
      );
      emit(AnnouncementCreated(announcement));
      // Reload after creation
      add(LoadAnnouncements(event.courseId));
    } catch (e) {
      emit(AnnouncementError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/announcement_repository.dart';
import '../../data/models/read_receipt_model.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository _repository;

  AnnouncementBloc(this._repository) : super(AnnouncementInitial()) {
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<MarkAnnouncementRead>(_onMarkRead);
    on<CreateAnnouncement>(_onCreate);
    on<LoadReadStats>(_onLoadReadStats);
  }

  Future<void> _onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      final announcements = await _repository.getAnnouncements(
        event.courseId,
        query: event.query,
      );
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
            return a.copyWith(isRead: true);
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
        scheduledAt: event.scheduledAt,
      );
      emit(AnnouncementCreated(announcement));
      add(LoadAnnouncements(event.courseId));
    } catch (e) {
      emit(AnnouncementError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadReadStats(
    LoadReadStats event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      final data = await _repository.getReadReceipts(event.announcementId);
      final reads = (data['reads'] as List)
          .map((json) => ReadReceiptModel.fromJson(json as Map<String, dynamic>))
          .toList();
      emit(AnnouncementReadStatsLoaded(
        announcementId: event.announcementId,
        readCount: reads.length,
        totalCount: data['total'] as int,
        receipts: reads,
      ));
    } catch (_) {}
  }
}

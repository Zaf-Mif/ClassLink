abstract class AnnouncementEvent {}

class LoadAnnouncements extends AnnouncementEvent {
  final String courseId;
  final String? query;
  LoadAnnouncements(this.courseId, {this.query});
}

class MarkAnnouncementRead extends AnnouncementEvent {
  final String announcementId;
  MarkAnnouncementRead(this.announcementId);
}

class CreateAnnouncement extends AnnouncementEvent {
  final String title;
  final String content;
  final String courseId;
  final List<String>? sectionIds;
  final DateTime? scheduledAt;
  CreateAnnouncement({
    required this.title,
    required this.content,
    required this.courseId,
    this.sectionIds,
    this.scheduledAt,
  });
}

class LoadReadStats extends AnnouncementEvent {
  final String announcementId;
  LoadReadStats(this.announcementId);
}

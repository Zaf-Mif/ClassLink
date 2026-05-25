abstract class AnnouncementEvent {}

class LoadAnnouncements extends AnnouncementEvent {
  final String courseId;
  LoadAnnouncements(this.courseId);
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
  CreateAnnouncement({
    required this.title,
    required this.content,
    required this.courseId,
    this.sectionIds,
  });
}

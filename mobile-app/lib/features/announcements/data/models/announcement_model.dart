class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String teacherName;
  final DateTime createdAt;
  final bool isRead;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.teacherName,
    required this.createdAt,
    this.isRead = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      teacherName: json['teacherName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}
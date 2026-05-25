class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String teacherName;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? scheduledAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.teacherName,
    required this.createdAt,
    this.isRead = false,
    this.scheduledAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      teacherName: json['teacherName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
    );
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    String? teacherName,
    DateTime? createdAt,
    bool? isRead,
    DateTime? scheduledAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      teacherName: teacherName ?? this.teacherName,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }
}

class ForumAnswerModel {
  final String id;
  final String content;
  final String teacherName;
  final bool isPinned;
  final DateTime createdAt;

  const ForumAnswerModel({
    required this.id,
    required this.content,
    required this.teacherName,
    this.isPinned = false,
    required this.createdAt,
  });

  factory ForumAnswerModel.fromJson(Map<String, dynamic> json) {
    return ForumAnswerModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      teacherName: json['teacherName'] ?? '',
      isPinned: json['isPinned'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'teacherName': teacherName,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

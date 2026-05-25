class FileItemModel {
  final String id;
  final String title;
  final String fileUrl;
  final String? topic;
  final String courseId;
  final String teacherName;
  final int versionNumber;
  final DateTime uploadedAt;

  const FileItemModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.topic,
    required this.courseId,
    required this.teacherName,
    required this.versionNumber,
    required this.uploadedAt,
  });

  factory FileItemModel.fromJson(Map<String, dynamic> json) {
    return FileItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      topic: json['topic'] as String?,
      courseId: json['courseId'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? '',
      versionNumber: json['versionNumber'] as int? ?? 1,
      uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileUrl': fileUrl,
      'topic': topic,
      'courseId': courseId,
      'teacherName': teacherName,
      'versionNumber': versionNumber,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  FileItemModel copyWith({
    String? id,
    String? title,
    String? fileUrl,
    String? topic,
    String? courseId,
    String? teacherName,
    int? versionNumber,
    DateTime? uploadedAt,
    bool clearTopic = false,
  }) {
    return FileItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fileUrl: fileUrl ?? this.fileUrl,
      topic: clearTopic ? null : (topic ?? this.topic),
      courseId: courseId ?? this.courseId,
      teacherName: teacherName ?? this.teacherName,
      versionNumber: versionNumber ?? this.versionNumber,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

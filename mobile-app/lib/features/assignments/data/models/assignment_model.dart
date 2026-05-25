class AssignmentModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final String courseId;
  final String teacherName;
  final DateTime createdAt;
  final bool? submitted;
  final String? submittedFile;
  final DateTime? submittedAt;
  final int? submissionCount;
  final int? totalStudents;

  const AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    this.deadline,
    required this.courseId,
    required this.teacherName,
    required this.createdAt,
    this.submitted,
    this.submittedFile,
    this.submittedAt,
    this.submissionCount,
    this.totalStudents,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      courseId: json['courseId'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      submitted: json['submitted'] as bool?,
      submittedFile: json['submittedFile'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String)
          : null,
      submissionCount: json['submissionCount'] as int?,
      totalStudents: json['totalStudents'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'courseId': courseId,
      'teacherName': teacherName,
      'createdAt': createdAt.toIso8601String(),
      'submitted': submitted,
      'submittedFile': submittedFile,
      'submittedAt': submittedAt?.toIso8601String(),
      'submissionCount': submissionCount,
      'totalStudents': totalStudents,
    };
  }

  AssignmentModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    String? courseId,
    String? teacherName,
    DateTime? createdAt,
    bool? submitted,
    String? submittedFile,
    DateTime? submittedAt,
    int? submissionCount,
    int? totalStudents,
    bool clearDeadline = false,
    bool clearDescription = false,
    bool clearSubmitted = false,
    bool clearSubmittedFile = false,
    bool clearSubmittedAt = false,
    bool clearSubmissionCount = false,
    bool clearTotalStudents = false,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      courseId: courseId ?? this.courseId,
      teacherName: teacherName ?? this.teacherName,
      createdAt: createdAt ?? this.createdAt,
      submitted: clearSubmitted ? null : (submitted ?? this.submitted),
      submittedFile:
          clearSubmittedFile ? null : (submittedFile ?? this.submittedFile),
      submittedAt:
          clearSubmittedAt ? null : (submittedAt ?? this.submittedAt),
      submissionCount: clearSubmissionCount
          ? null
          : (submissionCount ?? this.submissionCount),
      totalStudents:
          clearTotalStudents ? null : (totalStudents ?? this.totalStudents),
    );
  }
}

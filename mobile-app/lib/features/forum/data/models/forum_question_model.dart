import 'forum_answer_model.dart';

class ForumQuestionModel {
  final String id;
  final String content;
  final String studentName;
  final bool isAnswered;
  final List<ForumAnswerModel> answers;
  final DateTime createdAt;

  const ForumQuestionModel({
    required this.id,
    required this.content,
    required this.studentName,
    this.isAnswered = false,
    this.answers = const [],
    required this.createdAt,
  });

  factory ForumQuestionModel.fromJson(Map<String, dynamic> json) {
    return ForumQuestionModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      studentName: json['studentName'] ?? '',
      isAnswered: json['isAnswered'] ?? false,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((a) => ForumAnswerModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'studentName': studentName,
      'isAnswered': isAnswered,
      'answers': answers.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

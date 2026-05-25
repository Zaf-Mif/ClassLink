abstract class ForumEvent {}

class LoadQuestions extends ForumEvent {
  final String courseId;
  LoadQuestions(this.courseId);
}

class AskQuestion extends ForumEvent {
  final String courseId;
  final String content;
  AskQuestion({required this.courseId, required this.content});
}

class AnswerQuestion extends ForumEvent {
  final String questionId;
  final String content;
  AnswerQuestion({required this.questionId, required this.content});
}

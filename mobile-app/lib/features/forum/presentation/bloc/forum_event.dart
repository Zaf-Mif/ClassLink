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
  final bool isPinned;
  AnswerQuestion({required this.questionId, required this.content, this.isPinned = false});
}

class TogglePin extends ForumEvent {
  final String questionId;
  final String answerId;
  TogglePin({required this.questionId, required this.answerId});
}

class ToggleAnswered extends ForumEvent {
  final String questionId;
  ToggleAnswered(this.questionId);
}

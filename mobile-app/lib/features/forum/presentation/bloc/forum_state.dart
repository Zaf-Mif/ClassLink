import 'package:equatable/equatable.dart';
import '../../data/models/forum_question_model.dart';

abstract class ForumState extends Equatable {
  const ForumState();
  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {}

class ForumLoading extends ForumState {}

class ForumLoaded extends ForumState {
  final List<ForumQuestionModel> questions;
  const ForumLoaded(this.questions);
  @override
  List<Object?> get props => [questions];
}

class ForumError extends ForumState {
  final String message;
  const ForumError(this.message);
  @override
  List<Object?> get props => [message];
}

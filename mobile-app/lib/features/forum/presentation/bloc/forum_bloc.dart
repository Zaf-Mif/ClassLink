import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/forum_repository.dart';
import 'forum_event.dart';
import 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final ForumRepository _repository;

  ForumBloc(this._repository) : super(ForumInitial()) {
    on<LoadQuestions>(_onLoadQuestions);
    on<AskQuestion>(_onAsk);
    on<AnswerQuestion>(_onAnswer);
  }

  Future<void> _onLoadQuestions(LoadQuestions event, Emitter<ForumState> emit) async {
    emit(ForumLoading());
    try {
      final questions = await _repository.getQuestions(event.courseId);
      emit(ForumLoaded(questions));
    } catch (e) {
      emit(ForumError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAsk(AskQuestion event, Emitter<ForumState> emit) async {
    try {
      await _repository.createQuestion(event.courseId, event.content);
      add(LoadQuestions(event.courseId));
    } catch (e) {
      emit(ForumError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAnswer(AnswerQuestion event, Emitter<ForumState> emit) async {
    try {
      await _repository.answerQuestion(event.questionId, event.content);
    } catch (e) {
      emit(ForumError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

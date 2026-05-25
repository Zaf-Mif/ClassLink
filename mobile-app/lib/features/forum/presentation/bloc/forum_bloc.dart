import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/forum_repository.dart';
import 'forum_event.dart';
import 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final ForumRepository _repository;
  String? _currentCourseId;

  ForumBloc(this._repository) : super(ForumInitial()) {
    on<LoadQuestions>(_onLoadQuestions);
    on<AskQuestion>(_onAsk);
    on<AnswerQuestion>(_onAnswer);
    on<TogglePin>(_onTogglePin);
    on<ToggleAnswered>(_onToggleAnswered);
  }

  Future<void> _onLoadQuestions(LoadQuestions event, Emitter<ForumState> emit) async {
    _currentCourseId = event.courseId;
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
      await _repository.answerQuestion(event.questionId, event.content, isPinned: event.isPinned);
      if (_currentCourseId != null) {
        add(LoadQuestions(_currentCourseId!));
      }
    } catch (e) {
      emit(ForumError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onTogglePin(TogglePin event, Emitter<ForumState> emit) async {
    try {
      await _repository.pinAnswer(event.questionId, event.answerId);
      if (_currentCourseId != null) {
        add(LoadQuestions(_currentCourseId!));
      }
    } catch (e) {
      emit(ForumError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onToggleAnswered(ToggleAnswered event, Emitter<ForumState> emit) async {
    try {
      await _repository.toggleAnswered(event.questionId);
      if (_currentCourseId != null) {
        add(LoadQuestions(_currentCourseId!));
      }
    } catch (e) {
      emit(ForumError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

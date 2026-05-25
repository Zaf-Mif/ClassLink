import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _repository;

  CourseBloc(this._repository) : super(CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<RefreshCourses>(_onRefreshCourses);
  }

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final courses = await _repository.getCourses();
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshCourses(RefreshCourses event, Emitter<CourseState> emit) async {
    try {
      final courses = await _repository.getCourses();
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/assignment_repository.dart';
import 'assignment_event.dart';
import 'assignment_state.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentRepository _repository;

  AssignmentBloc(this._repository) : super(AssignmentInitial()) {
    on<LoadAssignments>(_onLoad);
    on<SubmitAssignment>(_onSubmit);
    on<CreateAssignment>(_onCreate);
    on<RefreshAssignments>(_onRefresh);
  }

  Future<void> _onLoad(LoadAssignments event, Emitter<AssignmentState> emit) async {
    emit(AssignmentLoading());
    try {
      final assignments = await _repository.getAssignments(event.courseId);
      emit(AssignmentLoaded(assignments));
    } catch (e) {
      emit(AssignmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(RefreshAssignments event, Emitter<AssignmentState> emit) async {
    try {
      final assignments = await _repository.getAssignments(event.courseId);
      emit(AssignmentLoaded(assignments));
    } catch (e) {
      emit(AssignmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSubmit(SubmitAssignment event, Emitter<AssignmentState> emit) async {
    try {
      await _repository.submitAssignment(event.assignmentId, event.fileUrl);
    } catch (e) {
      emit(AssignmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreate(CreateAssignment event, Emitter<AssignmentState> emit) async {
    try {
      await _repository.createAssignment(
        title: event.title,
        description: event.description,
        deadline: event.deadline,
        courseId: event.courseId,
        sectionIds: event.sectionIds,
      );
    } catch (e) {
      emit(AssignmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

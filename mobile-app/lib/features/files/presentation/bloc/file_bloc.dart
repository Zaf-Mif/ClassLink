import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/file_repository.dart';
import 'file_event.dart';
import 'file_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final FileRepository _repository;

  FileBloc(this._repository) : super(FileInitial()) {
    on<LoadFiles>(_onLoad);
    on<UploadFile>(_onUpload);
    on<RefreshFiles>(_onRefresh);
  }

  Future<void> _onLoad(LoadFiles event, Emitter<FileState> emit) async {
    emit(FileLoading());
    try {
      final files = await _repository.getFiles(event.courseId);
      emit(FileLoaded(files));
    } catch (e) {
      emit(FileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(RefreshFiles event, Emitter<FileState> emit) async {
    try {
      final files = await _repository.getFiles(event.courseId);
      emit(FileLoaded(files));
    } catch (e) {
      emit(FileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpload(UploadFile event, Emitter<FileState> emit) async {
    try {
      await _repository.uploadFile(
        title: event.title,
        topic: event.topic,
        courseId: event.courseId,
        file: event.file,
      );
    } catch (e) {
      emit(FileError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

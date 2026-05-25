import 'package:equatable/equatable.dart';
import '../../data/models/file_item_model.dart';

abstract class FileState extends Equatable {
  const FileState();
  @override
  List<Object?> get props => [];
}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FileLoaded extends FileState {
  final List<FileItemModel> files;
  const FileLoaded(this.files);
  @override
  List<Object?> get props => [files];
}

class FileError extends FileState {
  final String message;
  const FileError(this.message);
  @override
  List<Object?> get props => [message];
}

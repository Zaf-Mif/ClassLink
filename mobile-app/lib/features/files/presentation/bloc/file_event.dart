import 'dart:io';

abstract class FileEvent {}

class LoadFiles extends FileEvent {
  final String courseId;
  LoadFiles(this.courseId);
}

class UploadFile extends FileEvent {
  final String title;
  final String? topic;
  final String courseId;
  final File file;
  UploadFile({
    required this.title,
    this.topic,
    required this.courseId,
    required this.file,
  });
}

class RefreshFiles extends FileEvent {
  final String courseId;
  RefreshFiles(this.courseId);
}

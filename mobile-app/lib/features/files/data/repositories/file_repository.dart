import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/file_item_model.dart';

class FileRepository {
  final ApiClient _apiClient;

  FileRepository(this._apiClient);

  Future<List<FileItemModel>> getFiles(String courseId) async {
    try {
      final response = await _apiClient.dio.get('/files/$courseId');
      return (response.data as List)
          .map((json) => FileItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<FileItemModel> uploadFile({
    required String title,
    String? topic,
    required String courseId,
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        if (topic != null) 'topic': topic,
        'courseId': courseId,
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });
      final response = await _apiClient.dio.post('/files/upload', data: formData);
      return FileItemModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  String _mapError(DioException e) {
    if (e.response?.data is Map) {
      return (e.response!.data as Map)['message']?.toString() ?? 'Server error';
    }
    if (e.type == DioExceptionType.connectionTimeout) return 'Connection timeout';
    if (e.type == DioExceptionType.connectionError) return 'No internet connection';
    return 'An unexpected error occurred';
  }
}

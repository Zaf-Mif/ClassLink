import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/course_model.dart';

class CourseRepository {
  final ApiClient _apiClient;

  CourseRepository(this._apiClient);

  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await _apiClient.dio.get('/courses');
      return (response.data as List)
          .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<Map<String, dynamic>> getCourseDetail(String courseId) async {
    try {
      final response = await _apiClient.dio.get('/courses/$courseId');
      return response.data as Map<String, dynamic>;
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

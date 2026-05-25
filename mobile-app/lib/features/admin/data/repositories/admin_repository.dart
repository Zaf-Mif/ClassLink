import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/department_model.dart';
import '../models/section_model.dart';

class AdminRepository {
  final ApiClient apiClient;

  AdminRepository(this.apiClient);

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await apiClient.dio.get('/admin/users');
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/admin/users', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.put('/admin/users/$id', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<List<DepartmentModel>> getDepartments() async {
    try {
      final response = await apiClient.dio.get('/admin/departments');
      return (response.data as List)
          .map((j) => DepartmentModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<List<SectionModel>> getSections({String? departmentId}) async {
    try {
      final query = departmentId != null ? {'departmentId': departmentId} : null;
      final response = await apiClient.dio.get('/admin/sections', queryParameters: query);
      return (response.data as List)
          .map((j) => SectionModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> assignTeacher(String courseId, String teacherId, String sectionId) async {
    try {
      await apiClient.dio.post('/admin/course-teacher-section', data: {
        'courseId': courseId,
        'teacherId': teacherId,
        'sectionId': sectionId,
      });
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

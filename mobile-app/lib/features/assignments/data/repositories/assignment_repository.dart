import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/assignment_model.dart';

class AssignmentRepository {
  final ApiClient _apiClient;

  AssignmentRepository(this._apiClient);

  Future<List<AssignmentModel>> getAssignments(String courseId) async {
    try {
      final response = await _apiClient.dio.get('/assignments/$courseId');
      return (response.data as List)
          .map((json) => AssignmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<AssignmentModel> createAssignment({
    required String title,
    String? description,
    DateTime? deadline,
    required String courseId,
    List<String>? sectionIds,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'courseId': courseId,
      };
      if (description != null && description.isNotEmpty) data['description'] = description;
      if (deadline != null) data['deadline'] = deadline.toIso8601String();
      if (sectionIds != null && sectionIds.isNotEmpty) data['sectionIds'] = sectionIds;
      final response = await _apiClient.dio.post('/assignments', data: data);
      return AssignmentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> submitAssignment(String assignmentId, String fileUrl) async {
    try {
      await _apiClient.dio.post(
        '/assignments/$assignmentId/submit',
        data: {'fileUrl': fileUrl},
      );
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

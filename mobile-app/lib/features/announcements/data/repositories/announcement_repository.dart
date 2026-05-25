import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/announcement_model.dart';

class AnnouncementRepository {
  final ApiClient _apiClient;

  AnnouncementRepository(this._apiClient);

  Future<List<AnnouncementModel>> getAnnouncements(String courseId) async {
    try {
      final response = await _apiClient.dio.get('/announcements/$courseId');
      return (response.data as List)
          .map((json) => AnnouncementModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String content,
    required String courseId,
    List<String>? sectionIds,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/announcements',
        data: {
          'title': title,
          'content': content,
          'courseId': courseId,
          if (sectionIds != null && sectionIds.isNotEmpty) 'sectionIds': sectionIds,
        },
      );
      return AnnouncementModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> markAsRead(String announcementId) async {
    try {
      await _apiClient.dio.post('/announcements/$announcementId/read');
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<Map<String, dynamic>> getReadReceipts(String announcementId) async {
    try {
      final response = await _apiClient.dio.get('/announcements/$announcementId/reads');
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

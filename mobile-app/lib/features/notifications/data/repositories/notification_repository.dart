import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('/notifications');
      return (response.data as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.dio.put('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.put('/notifications/read-all');
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

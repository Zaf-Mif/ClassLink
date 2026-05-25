import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/message_model.dart';

class MessageRepository {
  final ApiClient _apiClient;

  MessageRepository(this._apiClient);

  Future<List<MessageModel>> getConversation(String userId) async {
    try {
      final response = await _apiClient.dio.get('/messages/conversation/$userId');
      return (response.data as List)
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<MessageModel> sendMessage(String receiverId, String content) async {
    try {
      final response = await _apiClient.dio.post(
        '/messages',
        data: {
          'receiverId': receiverId,
          'content': content,
        },
      );
      return MessageModel.fromJson(response.data);
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

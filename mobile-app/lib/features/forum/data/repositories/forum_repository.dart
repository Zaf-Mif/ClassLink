import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/forum_question_model.dart';

class ForumRepository {
  final ApiClient _apiClient;

  ForumRepository(this._apiClient);

  Future<List<ForumQuestionModel>> getQuestions(String courseId) async {
    try {
      final response = await _apiClient.dio.get('/forum/$courseId/questions');
      return (response.data as List)
          .map((json) => ForumQuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<ForumQuestionModel> createQuestion(String courseId, String content) async {
    try {
      final response = await _apiClient.dio.post(
        '/forum/$courseId/questions',
        data: {'content': content},
      );
      return ForumQuestionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> answerQuestion(String questionId, String content, {bool isPinned = false}) async {
    try {
      await _apiClient.dio.post(
        '/forum/questions/$questionId/answers',
        data: {'content': content, 'isPinned': isPinned},
      );
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> pinAnswer(String questionId, String answerId) async {
    try {
      await _apiClient.dio.patch('/forum/questions/$questionId/answers/$answerId/pin');
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> toggleAnswered(String questionId) async {
    try {
      await _apiClient.dio.patch('/forum/questions/$questionId/toggle-answered');
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

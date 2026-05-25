import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor());
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final _secureStorage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.deleteAll();
    }
    handler.next(err);
  }
}

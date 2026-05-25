import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  static String? _token;

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

  static void setToken(String? token) => _token = token;
  static String? get token => _token;
}

class _AuthInterceptor extends Interceptor {
  final _secureStorage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? token = ApiClient._token;
    if (token == null) {
      try {
        token = await _secureStorage.read(key: AppConstants.tokenKey);
      } catch (_) {}
    }
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      ApiClient._token = null;
      try {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.deleteAll();
      } catch (_) {}
    }
    handler.next(err);
  }
}

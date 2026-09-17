import 'package:dio/dio.dart';
import 'constants.dart';
import 'token_storage.dart';

/// Thin wrapper around Dio: attaches the Sanctum bearer token to every
/// request and normalizes error handling into ApiException so the rest of
/// the app doesn't deal with Dio's exception types directly.
class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.instance.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  static final instance = ApiClient._();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    return _unwrap(() => _dio.get(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    return _unwrap(() => _dio.post(path, data: data));
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async {
    return _unwrap(() => _dio.patch(path, data: data));
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _unwrap(() => _dio.delete(path));
  }

  Future<Map<String, dynamic>> _unwrap(Future<Response> Function() call) async {
    try {
      final response = await call();
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {'data': data};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isNetworkError = false, this.errors});

  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final Map<String, dynamic>? errors; // Laravel validation error bag, if any

  factory ApiException.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException('No connection to the server. Your report will be saved and sent automatically once you\'re back online.', isNetworkError: true);
    }

    final data = e.response?.data;
    final message = (data is Map && data['error'] is String) ? data['error'] as String : 'Something went wrong. Please try again.';
    final errors = (data is Map && data['errors'] is Map) ? Map<String, dynamic>.from(data['errors']) : null;

    return ApiException(message, statusCode: e.response?.statusCode, errors: errors);
  }

  @override
  String toString() => message;
}

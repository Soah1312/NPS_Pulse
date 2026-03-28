import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Typed exception for API errors
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException({required this.message, this.statusCode, this.code});

  @override
  String toString() => 'AppException($statusCode): $message';
}

/// Singleton Dio HTTP client with auth, logging, and error interceptors
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor — attaches Supabase JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          handler.next(options);
        },
      ),
    );

    // Logging interceptor — debug mode only
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    // Error interceptor — converts HTTP errors to AppException
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final appException = AppException(
            message: _extractErrorMessage(error),
            statusCode: error.response?.statusCode,
            code: error.response?.data?['code']?.toString(),
          );
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: appException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  String _extractErrorMessage(DioException error) {
    if (error.response?.data is Map) {
      final data = error.response!.data as Map;
      return data['message']?.toString() ??
          data['detail']?.toString() ??
          'Something went wrong';
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return error.message ?? 'Something went wrong';
    }
  }

  // Convenience methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}

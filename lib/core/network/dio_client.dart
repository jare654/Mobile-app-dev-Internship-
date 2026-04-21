import 'package:dio/dio.dart';

class DioClient {
  DioClient()
    : dio =
          Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
              ),
            )
            ..interceptors.add(
              LogInterceptor(
                requestBody: false,
                responseBody: false,
                requestHeader: false,
                responseHeader: false,
              ),
            );

  final Dio dio;
}

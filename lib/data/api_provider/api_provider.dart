import 'package:dio/dio.dart';
import '../injector.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';

class ApiProvider {
  late final Dio _dio;

  ApiProvider() {
    _dio = Injector().getDio();
  }

  Future<DataResponse<T>> request<T>({
    required String endpoint,
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final requestOptions = options ?? Injector.getHeaderToken();
      late Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(
            endpoint,
            queryParameters: queryParams,
            options: requestOptions,
          );
          break;
        case 'POST':
          response = await _dio.post(
            endpoint,
            data: data,
            queryParameters: queryParams,
            options: requestOptions,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            endpoint,
            data: data,
            queryParameters: queryParams,
            options: requestOptions,
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            endpoint,
            data: data,
            queryParameters: queryParams,
            options: requestOptions,
          );
          break;
        default:
          throw UnsupportedError('Method $method not supported');
      }

      final body = response.data;
      if (body is Map<String, dynamic>) {
        return DataResponse<T>.fromJson(body, fromJson);
      } else {
        return DataResponse<T>(
          isSuccess: true,
          data: fromJson != null ? fromJson(body) : body as T?,
        );
      }
    } on DioException catch (dioError) {
      final msg = NetworkHandling.getDioException(dioError);
      return DataResponse<T>(
        isSuccess: false,
        error: msg,
        message: msg,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<T>(
        isSuccess: false,
        error: msg,
        message: msg,
      );
    }
  }
}

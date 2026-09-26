import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../utils/helper/storage_helper.dart';
import 'api_provider/api_constant.dart';

class Injector {
  static final Injector _singleton = Injector._internal();
  late final Dio dio;

  factory Injector() => _singleton;

  Injector._internal() {
    String? token = StorageHelper().getAccessToken();
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          if (token != null && token.isNotEmpty)
            "Authorization": "Bearer $token",
        },
      ),
    );

    if (!kIsWeb) {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
      }
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageHelper().getAccessToken();
          if (token != null &&
              token.isNotEmpty &&
              !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(LoggingInterceptors());
  }

  static Options getHeaderToken({Map<String, dynamic>? extraHeaders}) {
    String? token = StorageHelper().getAccessToken();
    final headers = <String, dynamic>{
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      ...?extraHeaders,
    };
    return Options(headers: headers);
  }

  Dio getDio() => dio;
}

class LoggingInterceptors extends Interceptor {
  String printObject(Object object) {
    try {
      Map jsonMapped = json.decode(json.encode(object));
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(jsonMapped);
    } catch (e) {
      return object.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String? token = StorageHelper().getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }

    if (kDebugMode) {
      debugPrint(
        "--> ${options.method.toUpperCase()} ${"${options.baseUrl}${options.path}"}",
      );
      if (options.headers.isNotEmpty) {
        debugPrint("Headers: ${options.headers}");
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint("queryParameters: ${options.queryParameters}");
      }
      if (options.data != null) {
        if (options.data is FormData) {
          final formData = options.data as FormData;
          final fields = formData.fields.map((e) => "${e.key}: ${e.value}").toList();
          final files = formData.files.map((e) => "${e.key}: ${e.value.filename}").toList();
          debugPrint("Body FormData Fields: $fields");
          debugPrint("Body FormData Files: $files");
        } else {
          debugPrint("Body: ${printObject(options.data)}");
        }
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        "<-- ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}",
      );
      debugPrint("Response: ${printObject(response.data)}");
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        "<-- ERROR ${err.response?.statusCode} ${err.requestOptions.baseUrl}${err.requestOptions.path}",
      );
      debugPrint("Error message: ${err.message}");
      if (err.response?.data != null) {
        debugPrint("Error data: ${err.response?.data}");
      }
    }
    super.onError(err, handler);
  }
}

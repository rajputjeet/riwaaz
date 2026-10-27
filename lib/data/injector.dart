import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../utils/helper/storage_helper.dart';
import 'api_provider/api_constant.dart';

class Injector {
  static final Injector _singleton = Injector._internal();
  static Future<void> Function(String message)? onAccountRevoked;
  static bool _handlingAccountRevocation = false;
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
        onResponse: (response, handler) {
          final message = _revokedAccountMessage(response.data);
          final path = response.requestOptions.path.toLowerCase();
          final isProfileResponse =
              path.contains('/users/profile') || path.contains('/user/profile');
          final responseData = response.data;
          final isApiFailure =
              responseData is Map &&
              (responseData['success'] == false ||
                  responseData['isSuccess'] == false);
          if (message != null && (isProfileResponse || isApiFailure)) {
            _triggerAccountRevocation(message);
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: message,
              ),
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          final message = _revokedAccountErrorMessage(error);
          if (message != null) _triggerAccountRevocation(message);
          return handler.next(error);
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

  static String? _revokedAccountErrorMessage(DioException error) {
    final path = error.requestOptions.path.toLowerCase();
    if (path.contains('/auth/login') ||
        path.contains('/auth/sign-up') ||
        path.contains('/auth/verify-otp') ||
        path.contains('/auth/refresh-token') ||
        path.contains('/auth/logout')) {
      return null;
    }
    final statusCode = error.response?.statusCode;
    final token = StorageHelper().getAccessToken();
    final hasSession = token != null && token.isNotEmpty;
    if (!hasSession) return null;

    if (statusCode == 403 || statusCode == 404) {
      final message = _revokedAccountMessage(error.response?.data);
      if (message != null) return message;
    }

    // A 401 means the current authenticated session is no longer valid.
    // Do not log out for unrelated authorization failures such as vendor
    // verification or subscription restrictions.
    if (statusCode == 401) {
      return 'Your session is no longer active. Please sign in again.';
    }
    return null;
  }

  static String? _revokedAccountMessage(dynamic data) {
    if (data is! Map) return null;

    final nestedData = data['data'];
    final profile = nestedData is Map ? nestedData : data;
    final deleted =
        profile['isDeleted'] == true ||
        profile['isDeactivated'] == true ||
        profile['isDisabled'] == true ||
        profile['isBlocked'] == true;
    final active = profile['isActive'] ?? profile['isAccountActive'];
    final status = (profile['accountStatus'] ?? profile['accountState'] ?? '')
        .toString()
        .toLowerCase();
    if (deleted ||
        active == false ||
        const {
          'deleted',
          'deactivated',
          'disabled',
          'inactive',
          'suspended',
          'blocked',
        }.contains(status)) {
      final message = data['message'] ?? data['error'];
      return message?.toString().trim().isNotEmpty == true
          ? message.toString()
          : 'This account is no longer active. Please contact support if you need help.';
    }

    final serverMessage = (data['message'] ?? data['error'] ?? '')
        .toString()
        .trim();
    final details = [
      serverMessage,
      data['code']?.toString() ?? '',
      data['reason']?.toString() ?? '',
    ].join(' ').trim();
    final normalized = details.toLowerCase();
    final mentionsAccount =
        normalized.contains('account') ||
        normalized.contains('user') ||
        normalized.contains('vendor');
    final accountRevoked =
        normalized.contains('deactivat') ||
        normalized.contains('deleted') ||
        normalized.contains('disabled') ||
        normalized.contains('suspend') ||
        normalized.contains('blocked') ||
        normalized.contains('inactive') ||
        normalized.contains('not active');
    final accountNotFound =
        normalized.contains('account not found') ||
        normalized.contains('user not found') ||
        normalized.contains('current user not found') ||
        normalized.contains('account does not exist') ||
        normalized.contains('user does not exist');
    return mentionsAccount && (accountRevoked || accountNotFound)
        ? (serverMessage.isNotEmpty
              ? serverMessage
              : 'This account is no longer active. Please sign in again.')
        : null;
  }

  static void _triggerAccountRevocation(String message) {
    if (_handlingAccountRevocation) return;
    _handlingAccountRevocation = true;
    final handler = onAccountRevoked;
    if (handler == null) {
      unawaited(
        StorageHelper().clearAllData().whenComplete(() {
          _handlingAccountRevocation = false;
        }),
      );
      return;
    }
    unawaited(() async {
      try {
        await handler(message);
      } catch (error) {
        if (kDebugMode) {
          debugPrint('Failed to handle account revocation: $error');
        }
      } finally {
        _handlingAccountRevocation = false;
      }
    }());
  }
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

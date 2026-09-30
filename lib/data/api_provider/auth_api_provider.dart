import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/user_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class AuthApiProvider {
  late final Dio _dio;

  AuthApiProvider() {
    _dio = Injector().getDio();
  }

  // 1. Sign Up (POST /api/auth/sign-up)
  Future<DataResponse<UserModel>> signUp(Map<String, dynamic> requestData) async {
    try {
      final response = await _dio.post(
        ApiConstants.signUp,
        data: requestData,
      );

      return DataResponse<UserModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<UserModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // 2. Verify OTP (POST /api/auth/verify-otp)
  Future<DataResponse<UserModel>> verifyOtp({
    required String identifier,
    required int otp,
    int? roleId,
    String? name,
  }) async {
    final isEmail = identifier.contains('@');
    final payload = {
      if (isEmail) 'email': identifier else 'phone': identifier,
      'otp': otp,
    };

    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: payload,
      );

      return DataResponse<UserModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<UserModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // 3. Resend OTP (POST /api/auth/resend-otp)
  Future<DataResponse<UserModel>> resendOtp({
    required String identifier,
  }) async {
    final isEmail = identifier.contains('@');
    final payload = {
      if (isEmail) 'email': identifier else 'phone': identifier,
    };

    try {
      final response = await _dio.post(
        ApiConstants.resendOtp,
        data: payload,
      );

      return DataResponse<UserModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<UserModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // 4. User / Vendor Login (POST /api/auth/login)
  Future<DataResponse<UserModel>> logIn({
    required String identifier,
    required String password,
  }) async {
    final isEmail = identifier.contains('@');
    final payload = {
      if (isEmail) 'email': identifier else 'phone': identifier,
      'password': password,
    };

    try {
      final response = await _dio.post(
        ApiConstants.logIn,
        data: payload,
      );

      return DataResponse<UserModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<UserModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // 5. Forgot Password (PUT /api/auth/forgot-password)
  Future<DataResponse<dynamic>> forgotPassword({
    required String identifier,
    required String newPassword,
  }) async {
    final isEmail = identifier.contains('@');
    final payload = {
      if (isEmail) 'email': identifier else 'phone': identifier,
      'newPassword': newPassword,
    };

    try {
      final response = await _dio.put(
        ApiConstants.forgotPassword,
        data: payload,
      );

      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // 6. Refresh Token (POST /api/auth/refresh-token)
  Future<DataResponse<UserModel>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      return DataResponse<UserModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<UserModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // 7. Logout (POST /api/auth/logout)
  Future<DataResponse<dynamic>> logOut() async {
    try {
      final response = await _dio.post(
        ApiConstants.logout,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }
}

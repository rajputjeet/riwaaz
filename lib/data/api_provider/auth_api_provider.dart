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
}

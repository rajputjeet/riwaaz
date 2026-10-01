import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/user_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class UserApiProvider {
  late final Dio _dio;

  UserApiProvider() {
    _dio = Injector().getDio();
  }

  // GET /api/users/profile
  Future<DataResponse<UserModel>> getProfile() async {
    try {
      final response = await _dio.get(
        ApiConstants.userProfile,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<UserModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<UserModel>(isSuccess: false, message: msg, error: msg);
    }
  }

  // PUT /api/users/edit-profile (multipart/form-data)
  Future<DataResponse<UserModel>> editProfile(FormData formData) async {
    try {
      final response = await _dio.put(
        ApiConstants.editProfile,
        data: formData,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<UserModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<UserModel>(isSuccess: false, message: msg, error: msg);
    }
  }

  // PUT /api/users/change-password
  Future<DataResponse<dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.changePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
        options: Injector.getHeaderToken(),
      );

      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }

  // DELETE /api/users/delete-account
  Future<DataResponse<dynamic>> deleteAccount({
    String? reason,
    String? description,
  }) async {
    try {
      final response = await _dio.delete(
        ApiConstants.deleteAccount,
        data: {
          'reason': reason,
          'description': description,
        },
        options: Injector.getHeaderToken(),
      );

      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }
}

import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/user_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import '../../utils/helper/storage_helper.dart';
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
      return DataResponse<UserModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // PUT /api/users/edit-profile (multipart/form-data or application/json)
  Future<DataResponse<UserModel>> editProfile(dynamic data) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.put(
        ApiConstants.editProfile,
        data: data,
        options: data is FormData
            ? Options(
                contentType: null,
                headers: {
                  if (token != null && token.isNotEmpty)
                    'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
              )
            : Options(
                contentType: 'application/json',
                headers: {
                  if (token != null && token.isNotEmpty)
                    'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
              ),
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

  // PUT /api/users/change-password
  Future<DataResponse<dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.changePassword,
        data: {
          'oldPassword': oldPassword,
          'currentPassword': oldPassword,
          'newPassword': newPassword,
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

  // POST /api/users/delete-account
  Future<DataResponse<dynamic>> deleteAccount({
    required String reason,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{'reason': reason};
      if (description != null && description.trim().isNotEmpty) {
        body['description'] = description.trim();
      }
      final response = await _dio.post(
        ApiConstants.deleteAccount,
        data: body,
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

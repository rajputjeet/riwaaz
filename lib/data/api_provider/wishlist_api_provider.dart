import 'package:dio/dio.dart';

import '../injector.dart';
import '../models/user_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class WishlistApiProvider {
  late final Dio _dio;

  WishlistApiProvider() {
    _dio = Injector().getDio();
  }

  Future<DataResponse<List<UserModel>>> getSavedVendors() async {
    try {
      final response = await _dio.get(
        ApiConstants.savedVendors,
        options: Injector.getHeaderToken(),
      );
      return DataResponse<List<UserModel>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(UserModel.fromJson)
            .toList(),
      );
    } catch (e) {
      final message = NetworkHandling.getDioException(e);
      return DataResponse<List<UserModel>>(
        isSuccess: false,
        message: message,
        error: message,
      );
    }
  }

  Future<DataResponse<bool>> toggleSavedVendor(String vendorId) async {
    try {
      final response = await _dio.post(
        ApiConstants.toggleSavedVendor(vendorId),
        options: Injector.getHeaderToken(),
      );
      return DataResponse<bool>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data is Map && data['isSaved'] == true,
      );
    } catch (e) {
      final message = NetworkHandling.getDioException(e);
      return DataResponse<bool>(
        isSuccess: false,
        message: message,
        error: message,
      );
    }
  }

  Future<DataResponse<dynamic>> clearSavedVendors() async {
    try {
      final response = await _dio.delete(
        ApiConstants.clearSavedVendors,
        options: Injector.getHeaderToken(),
      );
      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data,
      );
    } catch (e) {
      final message = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(
        isSuccess: false,
        message: message,
        error: message,
      );
    }
  }
}

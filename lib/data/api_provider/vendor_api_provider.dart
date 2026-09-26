import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/vendor_application_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import '../../utils/helper/storage_helper.dart';
import 'api_constant.dart';

class VendorApiProvider {
  late final Dio _dio;

  VendorApiProvider() {
    _dio = Injector().getDio();
  }

  // 6. Submit Vendor Application (POST /api/users/vendor/application/submit)
  Future<DataResponse<VendorApplicationModel>> submitVendorApplication(
    FormData formData,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.vendorApplicationSubmit,
        data: formData,
        options: Injector.getHeaderToken(
          extraHeaders: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final result = DataResponse<VendorApplicationModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => VendorApplicationModel.fromJson(json as Map<String, dynamic>),
      );

      // Persist session on success
      if (result.isSuccess == true && result.data != null) {
        final data = result.data!;
        await StorageHelper().saveApplicationId(data.applicationId);
        await StorageHelper().saveApplicationStatus(data.applicationStatus);
        await StorageHelper().saveIsVerified(data.isVerified);
      }

      return result;
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<VendorApplicationModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // 7. Track Vendor Application Status (GET /api/users/vendor/application/status)
  Future<DataResponse<VendorApplicationModel>> getVendorApplicationStatus() async {
    try {
      final response = await _dio.get(
        ApiConstants.vendorApplicationStatus,
        options: Injector.getHeaderToken(),
      );

      final result = DataResponse<VendorApplicationModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => VendorApplicationModel.fromJson(json as Map<String, dynamic>),
      );

      // Keep local session in sync
      if (result.isSuccess == true && result.data != null) {
        final data = result.data!;
        await StorageHelper().saveApplicationId(data.applicationId);
        await StorageHelper().saveApplicationStatus(data.applicationStatus);
        await StorageHelper().saveIsVerified(data.isVerified);
      }

      return result;
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<VendorApplicationModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }
}

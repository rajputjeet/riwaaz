import 'package:dio/dio.dart';
import '../../utils/helper/storage_helper.dart';
import '../injector.dart';
import '../models/setting_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class SettingApiProvider {
  late final Dio _dio;

  SettingApiProvider() {
    _dio = Injector().getDio();
  }

  /// Get Platform Settings & Support Info (GET /api/setting/check)
  /// Automatically saves the returned settings to SharedPreferences.
  Future<DataResponse<SettingModel>> getSettings() async {
    try {
      final response = await _dio.get(ApiConstants.settingCheck);
      final resData = response.data;
      if (resData is Map<String, dynamic>) {
        final copyright = resData['copyright']?.toString();
        final dataMap = resData['data'] is Map<String, dynamic>
            ? resData['data'] as Map<String, dynamic>
            : resData;
        final model = SettingModel.fromJson(dataMap, copyright: copyright);

        // Persist settings in SharedPreferences
        await StorageHelper().saveSettings(model);

        return DataResponse<SettingModel>(
          isSuccess: resData['success'] == true,
          message: resData['message']?.toString() ?? 'Settings found successfully',
          data: model,
        );
      }
      return DataResponse<SettingModel>(
        isSuccess: false,
        message: 'Invalid response format',
        data: StorageHelper().getSettings(),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<SettingModel>(
        isSuccess: false,
        message: msg,
        data: StorageHelper().getSettings(),
        error: msg,
      );
    }
  }

  /// Silently fetch settings from the server in background and cache into SharedPreferences.
  Future<SettingModel> fetchAndCacheSettings() async {
    try {
      final res = await getSettings();
      if (res.isSuccess == true && res.data != null) {
        return res.data!;
      }
    } catch (_) {}
    return StorageHelper().getSettings();
  }
}

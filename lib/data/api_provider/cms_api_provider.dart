import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/cms_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class CmsApiProvider {
  late final Dio _dio;

  CmsApiProvider() {
    _dio = Injector().getDio();
  }

  /// 1. Get All CMS Pages (GET /api/cms/list)
  Future<DataResponse<List<CmsModel>>> getCmsList() async {
    try {
      final response = await _dio.get(ApiConstants.cmsList);
      return DataResponse<List<CmsModel>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) {
          if (json is List) {
            return json
                .map((e) => CmsModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<CmsModel>>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: [],
      );
    }
  }

  String _normalizeTypeId(String type) {
    final lower = type.trim().toLowerCase();
    switch (lower) {
      case 'terms':
      case 'terms-of-service':
      case 'terms_of_service':
      case 'terms-and-conditions':
      case 'terms_and_conditions':
        return '1';
      case 'privacy':
      case 'privacy-policy':
      case 'privacy_policy':
        return '2';
      case 'about':
      case 'about-us':
      case 'about_us':
        return '3';
      case 'refund':
      case 'refund-policy':
      case 'refund_policy':
      case 'cancellation':
      case 'cancellation-policy':
      case 'cancellation_policy':
        return '4';
      default:
        return type;
    }
  }

  /// 2. Get CMS Data by Type (GET /api/cms/data/:typeId)
  /// Accepts 'terms', 'privacy', 'about', 'refund' or numeric strings '1', '2', '3', '4'
  Future<DataResponse<CmsModel>> getCmsData(String type) async {
    final typeId = _normalizeTypeId(type);

    // 1. Try with normalized numeric ID
    try {
      final response = await _dio.get(ApiConstants.cmsData(typeId));
      final res = DataResponse<CmsModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CmsModel.fromJson(json as Map<String, dynamic>),
      );
      if (res.isSuccess == true && (res.data?.description?.isNotEmpty == true || res.data?.title?.isNotEmpty == true)) {
        return res;
      }
    } catch (_) {}

    // 2. Try with raw string type if different
    if (typeId != type) {
      try {
        final response = await _dio.get(ApiConstants.cmsData(type));
        final res = DataResponse<CmsModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => CmsModel.fromJson(json as Map<String, dynamic>),
        );
        if (res.isSuccess == true && (res.data?.description?.isNotEmpty == true || res.data?.title?.isNotEmpty == true)) {
          return res;
        }
      } catch (_) {}
    }

    // 3. Fallback: Search in GET /api/cms/list
    try {
      final listRes = await getCmsList();
      if (listRes.isSuccess == true && (listRes.data?.isNotEmpty == true)) {
        final list = listRes.data!;
        final target = type.trim().toLowerCase();
        for (final item in list) {
          final t = (item.type ?? '').toLowerCase();
          final title = (item.title ?? '').toLowerCase();
          final id = (item.id ?? '').toLowerCase();
          if (t == typeId || t == target || title.contains(target) || id == typeId) {
            return DataResponse<CmsModel>(
              isSuccess: true,
              message: 'CMS page loaded successfully',
              data: item,
            );
          }
        }
      }
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<CmsModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }

    return DataResponse<CmsModel>(
      isSuccess: false,
      message: 'No published content found for $type.',
    );
  }
}

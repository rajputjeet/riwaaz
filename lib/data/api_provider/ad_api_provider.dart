import 'package:dio/dio.dart';
import '../../utils/helper/storage_helper.dart';
import '../injector.dart';
import '../models/ad_plan_model.dart';
import '../models/user_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class AdApiProvider {
  late final Dio _dio;

  AdApiProvider() {
    _dio = Injector().getDio();
  }

  // 21.1 Get Ads Pricing Plans List (Public / Vendor)
  // GET /api/ad/list
  Future<DataResponse<List<AdPlanModel>>> getAdPlansList() async {
    try {
      final response = await _dio.get(ApiConstants.adList);
      if (response.data is Map<String, dynamic>) {
        return DataResponse<List<AdPlanModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) {
            if (json is List) {
              return json
                  .map((e) => AdPlanModel.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
            return [];
          },
        );
      } else if (response.data is List) {
        final list = (response.data as List)
            .map((e) => AdPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataResponse<List<AdPlanModel>>(
          isSuccess: true,
          message: 'Ad Plans retrieved successfully',
          data: list,
        );
      }
      return DataResponse<List<AdPlanModel>>(isSuccess: true, data: []);
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<AdPlanModel>>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: [],
      );
    }
  }

  // 21.2 Vendor Buy / Run Ad API (Vendor)
  // POST /api/ad/buy
  Future<DataResponse<ActiveAdDetailModel>> buyAdPlan(String adPlanId) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.post(
        ApiConstants.adBuy,
        data: {'adPlanId': adPlanId},
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final map = response.data as Map<String, dynamic>;
      final isSuccess = map['success'] == true;
      final message = map['message']?.toString();

      ActiveAdDetailModel? purchase;
      if (map['data'] != null && map['data'] is Map<String, dynamic>) {
        final dataMap = map['data'] as Map<String, dynamic>;
        if (dataMap['purchase'] != null && dataMap['purchase'] is Map<String, dynamic>) {
          purchase = ActiveAdDetailModel.fromJson(dataMap['purchase'] as Map<String, dynamic>);
        } else {
          purchase = ActiveAdDetailModel.fromJson(dataMap);
        }
      }

      return DataResponse<ActiveAdDetailModel>(
        isSuccess: isSuccess,
        message: message,
        data: purchase,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<ActiveAdDetailModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // 21.3 Vendor Check My Active Ad API (Vendor)
  // GET /api/ad/my-ad
  Future<DataResponse<VendorMyAdModel>> getMyAd() async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.get(
        ApiConstants.adMyAd,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return DataResponse<VendorMyAdModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => VendorMyAdModel.fromJson(json as Map<String, dynamic>),
        );
      }

      return DataResponse<VendorMyAdModel>(
        isSuccess: true,
        data: VendorMyAdModel(),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<VendorMyAdModel>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: VendorMyAdModel(),
      );
    }
  }

  // 21.4 Public User Side Active Sponsored Vendors / Ads List API (User Side)
  // GET /api/ad/active-vendors
  // Optional Query Params: ?categoryId=<CATEGORY_ID>
  Future<DataResponse<List<UserModel>>> getActiveSponsoredVendors({
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _dio.get(
        ApiConstants.adActiveVendors,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is Map<String, dynamic>) {
        final resMap = response.data as Map<String, dynamic>;
        return DataResponse<List<UserModel>>.fromJson(
          resMap,
          (data) {
            List<dynamic> rawList = [];
            if (data is List) {
              rawList = data;
            } else if (data is Map<String, dynamic>) {
              if (data['list'] is List) {
                rawList = data['list'] as List;
              } else if (data['vendors'] is List) {
                rawList = data['vendors'] as List;
              }
            }
            return rawList
                .whereType<Map<String, dynamic>>()
                .map((e) => UserModel.fromJson(e))
                .toList();
          },
        );
      } else if (response.data is List) {
        final list = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => UserModel.fromJson(e))
            .toList();
        return DataResponse<List<UserModel>>(
          isSuccess: true,
          message: 'Featured / Sponsored Vendors List',
          data: list,
        );
      }
      return DataResponse<List<UserModel>>(isSuccess: true, data: []);
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<UserModel>>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: [],
      );
    }
  }
}

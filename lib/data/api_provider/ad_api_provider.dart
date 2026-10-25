import 'dart:io';

import 'package:dio/dio.dart';
import '../../models/subscription_coupon_models.dart';
import '../../utils/helper/storage_helper.dart';
import '../injector.dart';
import '../models/ad_plan_model.dart';
import '../models/running_ad_banner_model.dart';
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
  Future<DataResponse<ActiveAdDetailModel>> buyAdPlan(
    String adPlanId, {
    required File bannerFile,
    String? couponCode,
    String paymentMethod = 'Razorpay',
    String? transactionId,
    String? adBannerUrl,
  }) async {
    try {
      final token = StorageHelper().getAccessToken();
      final formData = FormData.fromMap({
        'planId': adPlanId,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'couponCode': couponCode.trim().toUpperCase(),
        'paymentMethod': paymentMethod,
        if (transactionId != null && transactionId.isNotEmpty)
          'transactionId': transactionId,
        'banner': await MultipartFile.fromFile(
          bannerFile.path,
          filename: bannerFile.path.split(Platform.pathSeparator).last,
        ),
        if (adBannerUrl != null && adBannerUrl.isNotEmpty)
          'adBannerUrl': adBannerUrl,
      });
      final response = await _dio.post(
        ApiConstants.adBuy,
        data: formData,
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

  // 21.2.1 Fetch available coupons for Sponsored Ads (?applicableFor=ad)
  Future<DataResponse<List<CouponModel>>> getAvailableAdCoupons() async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.get(
        ApiConstants.discountCoupons,
        queryParameters: {'applicableFor': 'ad'},
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{'success': true, 'data': response.data};

      return DataResponse<List<CouponModel>>.fromJson(
        body,
        (raw) {
          final list = raw is List
              ? raw
              : (raw is Map && raw['data'] is List
                  ? raw['data'] as List
                  : (raw is Map && raw['coupons'] is List
                      ? raw['coupons'] as List
                      : const <dynamic>[]));
          return list
              .whereType<Map>()
              .map((item) =>
                  CouponModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        },
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<CouponModel>>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: [],
      );
    }
  }

  // 21.2.2 Validate coupon code against a Sponsored Ad plan
  Future<DataResponse<CouponValidationResult>> validateAdCoupon({
    required String couponCode,
    required String adPlanId,
  }) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.post(
        ApiConstants.discountValidate,
        data: {
          'couponCode': couponCode.trim(),
          'adPlanId': adPlanId,
          'type': 'ad',
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      return DataResponse<CouponValidationResult>.fromJson(
        body,
        (raw) {
          if (raw is! Map) {
            throw const FormatException('Invalid coupon response.');
          }
          final map = Map<String, dynamic>.from(raw);
          return CouponValidationResult.fromJson({
            ...map,
            'couponCode': map['couponCode']?.toString().trim().isNotEmpty == true
                ? map['couponCode']
                : couponCode.trim().toUpperCase(),
          });
        },
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<CouponValidationResult>(
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

  // 21.5 Post-Payment Ad Banner Upload API (Vendor)
  // POST /api/ad/upload-banner
  // Headers: Authorization: Bearer <token>, Content-Type: multipart/form-data
  // Form Field: adBanner (File)
  Future<DataResponse<ActiveAdDetailModel>> uploadAdBanner(dynamic bannerFile) async {
    try {
      final token = StorageHelper().getAccessToken();

      String filePath = '';
      if (bannerFile is File) {
        filePath = bannerFile.path;
      } else if (bannerFile is String) {
        filePath = bannerFile;
      }

      if (filePath.isEmpty) {
        return DataResponse<ActiveAdDetailModel>(
          isSuccess: false,
          message: 'Please provide a valid banner image file.',
        );
      }

      final fileName = filePath.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'adBanner': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiConstants.adUploadBanner,
        data: formData,
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
      final message = map['message']?.toString() ??
          (isSuccess
              ? 'Ad banner uploaded successfully and attached to your running ad campaign!'
              : 'Failed to upload ad banner.');

      ActiveAdDetailModel? activeAd;
      if (map['data'] != null && map['data'] is Map<String, dynamic>) {
        final dataMap = map['data'] as Map<String, dynamic>;
        activeAd = ActiveAdDetailModel.fromJson(dataMap);
      }

      return DataResponse<ActiveAdDetailModel>(
        isSuccess: isSuccess,
        message: message,
        data: activeAd,
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

  // 21.6 Customer Home Screen Running Ads Carousel API (Public)
  // GET /api/ad/running-ads (fallback to /api/banner/list)
  Future<DataResponse<List<RunningAdBannerModel>>> getRunningAds() async {
    try {
      final response = await _dio.get(ApiConstants.adRunningAds);
      List<dynamic> rawList = [];

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['data'] is List) {
          rawList = map['data'] as List;
        } else if (map['runningAds'] is List) {
          rawList = map['runningAds'] as List;
        } else if (map['banners'] is List) {
          rawList = map['banners'] as List;
        }
      } else if (response.data is List) {
        rawList = response.data as List;
      }

      // If primary endpoint returned empty, check /api/banner/list compatibility
      if (rawList.isEmpty) {
        try {
          final bannerRes = await _dio.get(ApiConstants.bannerList);
          if (bannerRes.data is Map<String, dynamic> &&
              bannerRes.data['data'] is List) {
            rawList = bannerRes.data['data'] as List;
          } else if (bannerRes.data is List) {
            rawList = bannerRes.data as List;
          }
        } catch (_) {}
      }

      final ads = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => RunningAdBannerModel.fromJson(json))
          .where((item) => item.effectiveImageUrl.isNotEmpty)
          .toList();

      return DataResponse<List<RunningAdBannerModel>>(
        isSuccess: true,
        message: 'Running ads found successfully',
        data: ads,
      );
    } catch (e) {
      // Fallback attempt to /api/banner/list
      try {
        final bannerRes = await _dio.get(ApiConstants.bannerList);
        List<dynamic> rawList = [];
        if (bannerRes.data is Map<String, dynamic> &&
            bannerRes.data['data'] is List) {
          rawList = bannerRes.data['data'] as List;
        } else if (bannerRes.data is List) {
          rawList = bannerRes.data as List;
        }
        final ads = rawList
            .whereType<Map<String, dynamic>>()
            .map((json) => RunningAdBannerModel.fromJson(json))
            .where((item) => item.effectiveImageUrl.isNotEmpty)
            .toList();
        if (ads.isNotEmpty) {
          return DataResponse<List<RunningAdBannerModel>>(
            isSuccess: true,
            data: ads,
          );
        }
      } catch (_) {}

      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<RunningAdBannerModel>>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: [],
      );
    }
  }
}

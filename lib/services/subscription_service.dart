// ignore_for_file: use_null_aware_elements

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/api_provider/api_constant.dart';
import '../../utils/helper/storage_helper.dart';
import '../models/subscription_coupon_models.dart';

class SubscriptionService {
  final String baseUrl;
  final Future<String?> Function() getAuthToken;

  SubscriptionService({
    required this.baseUrl,
    required this.getAuthToken,
  });

  /// Factory helper providing default configured service instance
  factory SubscriptionService.defaultInstance() {
    final base = ApiConstants.baseUrl.endsWith('/api')
        ? ApiConstants.baseUrl
        : '${ApiConstants.baseUrl}/api';
    return SubscriptionService(
      baseUrl: base,
      getAuthToken: () async => StorageHelper().getAccessToken(),
    );
  }

  String _url(String path) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    if (!cleanBase.endsWith('/api') && !cleanPath.startsWith('/api')) {
      return '$cleanBase/api$cleanPath';
    }
    return '$cleanBase$cleanPath';
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  /// 1. Fetch all subscription plans
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    final response = await http.get(
      Uri.parse(_url('/subscription/list')),
      headers: _headers(null),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];
      return list.map((e) => SubscriptionPlanModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load subscription plans: ${response.body}');
    }
  }

  /// 2. Fetch available coupons for subscription
  Future<List<CouponModel>> getAvailableCoupons() async {
    final token = await getAuthToken();
    final response = await http.get(
      Uri.parse(_url('/discount/coupons?applicableFor=subscription')),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];
      return list.map((e) => CouponModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load coupons: ${response.body}');
    }
  }

  /// 3. Validate coupon code against a subscription plan
  Future<CouponValidationResult> validateCoupon({
    required String couponCode,
    required String subscriptionPlanId,
  }) async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(_url('/discount/validate')),
      headers: _headers(token),
      body: jsonEncode({
        'couponCode': couponCode.trim(),
        'subscriptionPlanId': subscriptionPlanId,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return CouponValidationResult.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Invalid coupon code');
    }
  }

  /// 4. Buy / Activate subscription plan
  Future<Map<String, dynamic>> buySubscriptionPlan({
    required String subscriptionPlanId,
    String? couponCode,
    String paymentMethod = 'In-App',
    String? transactionId,
  }) async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(_url('/user/vendor/plan/buy')),
      headers: _headers(token),
      body: jsonEncode({
        'subscriptionPlanId': subscriptionPlanId,
        if (couponCode != null && couponCode.isNotEmpty)
          'couponCode': couponCode.trim(),
        'paymentMethod': paymentMethod,
        if (transactionId != null) 'transactionId': transactionId,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return body['data'];
    } else if (response.statusCode == 403) {
      throw Exception(body['message'] ?? 'Account pending verification.');
    } else {
      throw Exception(body['message'] ?? 'Failed to buy subscription');
    }
  }

  /// 5. Get vendor active subscription plan details & history
  Future<VendorActivePlanModel> getVendorActivePlan() async {
    final token = await getAuthToken();
    final response = await http.get(
      Uri.parse(_url('/user/vendor/plan/active')),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return VendorActivePlanModel.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch active plan');
    }
  }

  /// 6. Fetch available coupons for Sponsored Ads (?applicableFor=ad)
  Future<List<CouponModel>> getAvailableAdCoupons() async {
    final token = await getAuthToken();
    final response = await http.get(
      Uri.parse(_url('/discount/coupons?applicableFor=ad')),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];
      return list.map((e) => CouponModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ad coupons: ${response.body}');
    }
  }

  /// 7. Validate coupon code against a Sponsored Ad plan
  Future<CouponValidationResult> validateAdCoupon({
    required String couponCode,
    required String adPlanId,
  }) async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(_url('/discount/validate')),
      headers: _headers(token),
      body: jsonEncode({
        'couponCode': couponCode.trim(),
        'adPlanId': adPlanId,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return CouponValidationResult.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Invalid coupon code for ad');
    }
  }

  /// 8. Buy / Boost Sponsored Ad with Coupon
  Future<Map<String, dynamic>> buyAdPlan({
    required String adPlanId,
    String? couponCode,
    String paymentMethod = 'In-App',
    String? transactionId,
    String? adBannerUrl,
  }) async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(_url('/ad/buy')),
      headers: _headers(token),
      body: jsonEncode({
        'adPlanId': adPlanId,
        if (couponCode != null && couponCode.isNotEmpty)
          'couponCode': couponCode.trim(),
        'paymentMethod': paymentMethod,
        if (transactionId != null) 'transactionId': transactionId,
        if (adBannerUrl != null) 'adBannerUrl': adBannerUrl,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return body['data'];
    } else {
      throw Exception(body['message'] ?? 'Failed to buy ad plan');
    }
  }
}

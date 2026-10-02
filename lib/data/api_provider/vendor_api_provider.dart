import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/active_plan_model.dart';
import '../models/booking_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/vendor_application_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import '../../utils/helper/storage_helper.dart';
import 'api_constant.dart';
import 'user_api_provider.dart';

// Unified Vendor API Provider for Services, Packages, Plans, Portfolio, and Bookings
class VendorApiProvider {
  late final Dio _dio;

  VendorApiProvider() {
    _dio = Injector().getDio();
  }

  // ─── Application ───────────────────────────────────────────────────────────

  // POST /api/users/vendor/application/submit
  Future<DataResponse<VendorApplicationModel>> submitVendorApplication(
    FormData formData,
  ) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.post(
        ApiConstants.vendorApplicationSubmit,
        data: formData,
        options: Options(
          contentType: null,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final result = DataResponse<VendorApplicationModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => VendorApplicationModel.fromJson(json as Map<String, dynamic>),
      );

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
        isSuccess: false, message: msg, error: msg,
      );
    }
  }

  // GET /api/users/vendor/application/status
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
        isSuccess: false, message: msg, error: msg,
      );
    }
  }

  // ─── Subscription Plans ────────────────────────────────────────────────────

  // GET /api/users/vendor/plan/active
  Future<DataResponse<ActivePlanModel>> getActivePlan() async {
    try {
      final response = await _dio.get(
        ApiConstants.vendorActivePlan,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<ActivePlanModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ActivePlanModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<ActivePlanModel>(
        isSuccess: false, message: msg, error: msg,
      );
    }
  }

  // POST /api/users/vendor/plan/buy
  Future<DataResponse<ActivePlanModel>> buyPlan({
    required String subscriptionPlanId,
    String paymentMethod = 'UPI',
    String? transactionId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.vendorBuyPlan,
        data: {
          'subscriptionPlanId': subscriptionPlanId,
          'paymentMethod': paymentMethod,
          if (transactionId != null && transactionId.isNotEmpty)
            'transactionId': transactionId,
        },
        options: Injector.getHeaderToken(),
      );

      return DataResponse<ActivePlanModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ActivePlanModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<ActivePlanModel>(
        isSuccess: false, message: msg, error: msg,
      );
    }
  }

  // ─── Portfolio ─────────────────────────────────────────────────────────────

  // POST /api/users/vendor/portfolio/add
  Future<DataResponse<dynamic>> addPortfolioItem(FormData formData) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.post(
        ApiConstants.vendorPortfolioAdd,
        data: formData,
        options: Options(
          // Must be null so Dio auto-sets multipart/form-data with boundary
          contentType: null,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>, (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }

  // PUT /api/users/vendor/portfolio/edit/:id
  Future<DataResponse<dynamic>> editPortfolioItem(
    String portfolioId,
    FormData formData,
  ) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.put(
        ApiConstants.vendorPortfolioEdit(portfolioId),
        data: formData,
        options: Options(
          contentType: null,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>, (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }

  // DELETE /api/users/vendor/portfolio/delete/:id
  Future<DataResponse<dynamic>> deletePortfolioItem(String portfolioId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.vendorPortfolioDelete(portfolioId),
        options: Injector.getHeaderToken(),
      );
      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>, (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }

  // ─── Packages ──────────────────────────────────────────────────────────────

  // ─── Vendor Services & Packages (Unified API) ─────────────────────────────

  // GET /api/users/vendor/service-package/list
  Future<DataResponse<List<dynamic>>> getServicePackageList() async {
    try {
      final response = await _dio.get(
        ApiConstants.vendorServicePackageList,
        options: Injector.getHeaderToken(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['data'];
        if (items is List) {
          return DataResponse<List<dynamic>>(
            isSuccess: data['success'] == true,
            message: data['message']?.toString(),
            data: items,
          );
        }
      }
      return DataResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json is List ? json : [],
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<dynamic>>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // POST /api/users/vendor/service-package/add
  Future<DataResponse<dynamic>> addServicePackage(dynamic data) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.post(
        ApiConstants.vendorServicePackageAdd,
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

      final resMap = response.data is Map<String, dynamic>
          ? (response.data as Map<String, dynamic>)
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : <String, dynamic>{});

      final bool isHttpOk =
          (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;
      final statusVal = resMap['status'];
      final bool isSuccess = resMap['success'] == true ||
          resMap['isSuccess'] == true ||
          statusVal == true ||
          statusVal == 200 ||
          statusVal == 201 ||
          statusVal == '200' ||
          statusVal == '201' ||
          statusVal == 'success' ||
          (isHttpOk && resMap['success'] != false);

      return DataResponse<dynamic>(
        isSuccess: isSuccess,
        message: resMap['message']?.toString(),
        data: resMap['data'] ?? resMap,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }

  // PUT /api/users/vendor/service-package/edit/:id
  Future<DataResponse<dynamic>> editServicePackage(
    String id,
    dynamic data,
  ) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.put(
        ApiConstants.vendorServicePackageEdit(id),
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

      final resMap = response.data is Map<String, dynamic>
          ? (response.data as Map<String, dynamic>)
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : <String, dynamic>{});

      final bool isHttpOk =
          (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;
      final statusVal = resMap['status'];
      final bool isSuccess = resMap['success'] == true ||
          resMap['isSuccess'] == true ||
          statusVal == true ||
          statusVal == 200 ||
          statusVal == 201 ||
          statusVal == '200' ||
          statusVal == '201' ||
          statusVal == 'success' ||
          (isHttpOk && resMap['success'] != false);

      return DataResponse<dynamic>(
        isSuccess: isSuccess,
        message: resMap['message']?.toString(),
        data: resMap['data'] ?? resMap,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }

  // DELETE /api/users/vendor/service-package/delete/:id
  Future<DataResponse<dynamic>> deleteServicePackage(String id) async {
    try {
      final token = StorageHelper().getAccessToken();
      final response = await _dio.delete(
        ApiConstants.vendorServicePackageDelete(id),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final resMap = response.data is Map<String, dynamic>
          ? (response.data as Map<String, dynamic>)
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : <String, dynamic>{});

      final bool isHttpOk =
          (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;
      final statusVal = resMap['status'];
      final bool isSuccess = resMap['success'] == true ||
          resMap['isSuccess'] == true ||
          statusVal == true ||
          statusVal == 200 ||
          statusVal == 201 ||
          statusVal == '200' ||
          statusVal == '201' ||
          statusVal == 'success' ||
          (isHttpOk && resMap['success'] != false);

      return DataResponse<dynamic>(
        isSuccess: isSuccess,
        message: resMap['message']?.toString(),
        data: resMap['data'] ?? resMap,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }

  // Aliases for backward compatibility
  Future<DataResponse<dynamic>> addPackage(Map<String, dynamic> data) =>
      addServicePackage(data);

  Future<DataResponse<dynamic>> editPackage(
    String packageId,
    Map<String, dynamic> data,
  ) =>
      editServicePackage(packageId, data);

  Future<DataResponse<dynamic>> deletePackage(String packageId) =>
      deleteServicePackage(packageId);

  Future<DataResponse<dynamic>> addService(FormData formData) =>
      addServicePackage(formData);

  Future<DataResponse<dynamic>> editService(
    String serviceId,
    FormData formData,
  ) =>
      editServicePackage(serviceId, formData);

  Future<DataResponse<dynamic>> deleteService(String serviceId) =>
      deleteServicePackage(serviceId);

  // ─── Bookings ──────────────────────────────────────────────────────────────

  // GET /api/booking/list
  Future<DataResponse<BookingsListResponse>> getBookings({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dio.get(
        ApiConstants.vendorBookingsList,
        queryParameters: queryParams,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<BookingsListResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => BookingsListResponse.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<BookingsListResponse>(
        isSuccess: false, message: msg, error: msg,
      );
    }
  }

  // PUT /api/users/vendor/booking/status/:bookingId
  Future<DataResponse<dynamic>> updateBookingStatus({
    required String bookingId,
    required bool accept,
    String? notes,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.vendorUpdateBookingStatus(bookingId),
        data: {
          'status': accept ? 'Confirmed' : 'Cancelled',
          'notes': notes ?? (accept ? 'Accepted by vendor' : 'Declined by vendor'),
        },
        options: Injector.getHeaderToken(),
      );
      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>, (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  // GET /api/users/vendor/dashboard-stats
  Future<DataResponse<DashboardStatsModel>> getDashboardStats() async {
    try {
      final response = await _dio.get(
        ApiConstants.vendorDashboardStats,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<DashboardStatsModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DashboardStatsModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<DashboardStatsModel>(
        isSuccess: false, message: msg, error: msg,
      );
    }
  }

  // ─── Account ───────────────────────────────────────────────────────────────

  // PUT /api/users/change-password
  Future<DataResponse<dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      UserApiProvider().changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
}

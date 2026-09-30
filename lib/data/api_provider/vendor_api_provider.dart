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
      final response = await _dio.post(
        ApiConstants.vendorPortfolioAdd,
        data: formData,
        options: Injector.getHeaderToken(
          extraHeaders: {'Content-Type': 'multipart/form-data'},
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
      final response = await _dio.put(
        ApiConstants.vendorPortfolioEdit(portfolioId),
        data: formData,
        options: Injector.getHeaderToken(
          extraHeaders: {'Content-Type': 'multipart/form-data'},
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

  // POST /api/users/vendor/package/add
  Future<DataResponse<dynamic>> addPackage(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.vendorPackageAdd,
        data: data,
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

  // PUT /api/users/vendor/package/edit/:id
  Future<DataResponse<dynamic>> editPackage(
    String packageId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.vendorPackageEdit(packageId),
        data: data,
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

  // DELETE /api/users/vendor/package/delete/:id
  Future<DataResponse<dynamic>> deletePackage(String packageId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.vendorPackageDelete(packageId),
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

  // ─── Services ──────────────────────────────────────────────────────────────

  // POST /api/users/vendor/service/add
  Future<DataResponse<dynamic>> addService(FormData formData) async {
    try {
      final response = await _dio.post(
        ApiConstants.vendorServiceAdd,
        data: formData,
        options: Injector.getHeaderToken(
          extraHeaders: {'Content-Type': 'multipart/form-data'},
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

  // PUT /api/users/vendor/service/edit/:id
  Future<DataResponse<dynamic>> editService(
    String serviceId,
    FormData formData,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.vendorServiceEdit(serviceId),
        data: formData,
        options: Injector.getHeaderToken(
          extraHeaders: {'Content-Type': 'multipart/form-data'},
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

  // DELETE /api/users/vendor/service/delete/:id
  Future<DataResponse<dynamic>> deleteService(String serviceId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.vendorServiceDelete(serviceId),
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
}

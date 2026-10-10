import 'package:dio/dio.dart';
import '../../utils/helper/storage_helper.dart';
import '../injector.dart';
import '../models/booking_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class BookingApiProvider {
  late final Dio _dio;

  BookingApiProvider() {
    _dio = Injector().getDio();
  }

  // POST /api/booking/create
  Future<DataResponse<BookingModel>> createBooking({
    required String serviceName,
    String? eventType,
    String? eventDate,
    String? eventTime,
    int? guestCount,
    String? venueLocation,
    String? city,
    num? totalAmount,
    num? advancePaid,
    String? paymentStatus,
    String? paymentMethod,
    String? notes,
    String? specialRequests,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? userId,
  }) async {
    try {
      final currentUserId = (userId != null && userId.isNotEmpty)
          ? userId
          : StorageHelper().getUserId();

      final currentName = (customerName != null && customerName.isNotEmpty)
          ? customerName
          : StorageHelper().getUserName();

      final currentEmail = (customerEmail != null && customerEmail.isNotEmpty)
          ? customerEmail
          : StorageHelper().getUserEmail();

      final currentPhone = (customerPhone != null && customerPhone.isNotEmpty)
          ? customerPhone
          : StorageHelper().getUserMobile();

      final payload = <String, dynamic>{
        if (currentUserId != null && currentUserId.isNotEmpty)
          'userId': currentUserId,
        if (currentName != null && currentName.isNotEmpty)
          'customerName': currentName,
        if (currentEmail != null && currentEmail.isNotEmpty)
          'customerEmail': currentEmail,
        if (currentPhone != null && currentPhone.isNotEmpty)
          'customerPhone': currentPhone,
        'serviceName': serviceName,
        'eventType': (eventType != null && eventType.isNotEmpty)
            ? eventType
            : 'Wedding',
        if (eventDate != null && eventDate.isNotEmpty)
          'eventDate': eventDate
        else
          'eventDate': DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String(),
        'eventTime': (eventTime != null && eventTime.isNotEmpty)
            ? eventTime
            : 'Full Day',
        'guestCount': guestCount ?? 100,
        'venueLocation': venueLocation ?? '',
        'city': (city != null && city.isNotEmpty) ? city : 'Chandigarh',
        'totalAmount': totalAmount ?? 0,
        'advancePaid': advancePaid ?? 0,
        'paymentStatus': paymentStatus ?? 'Pending',
        'paymentMethod': paymentMethod ?? 'Pay In Person',
        'status': 'Pending',
        'notes': notes ?? '',
        'specialRequests': specialRequests ?? '',
      };

      final response = await _dio.post(
        ApiConstants.bookingCreate,
        data: payload,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<BookingModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => BookingModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<BookingModel>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }

  // GET /api/booking/list
  Future<DataResponse<BookingsListResponse>> getBookings({
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dio.get(
        ApiConstants.bookingList,
        queryParameters: queryParams,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<BookingsListResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => BookingsListResponse.fromJson(json),
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<BookingsListResponse>(
        isSuccess: false,
        message: msg,
        error: msg,
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
          'notes':
              notes ?? (accept ? 'Accepted by vendor' : 'Declined by vendor'),
        },
        options: Injector.getHeaderToken(),
      );
      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(
        isSuccess: false,
        message: msg,
        error: msg,
      );
    }
  }
}

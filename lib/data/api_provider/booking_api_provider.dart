import 'package:dio/dio.dart';
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
    required String vendorId,
    required String serviceName,
    required String eventDate,
    required String eventTime,
    required String eventLocation,
    required num totalAmount,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.bookingCreate,
        data: {
          'vendorId': vendorId,
          'serviceName': serviceName,
          'eventDate': eventDate,
          'eventTime': eventTime,
          'eventLocation': eventLocation,
          'totalAmount': totalAmount,
        },
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

  // PUT /api/booking/cancel/:bookingId (customer)
  Future<DataResponse<BookingModel>> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.bookingCancel(bookingId),
        data: {'reason': reason ?? 'Cancelled by customer'},
        options: Injector.getHeaderToken(),
      );
      return DataResponse<BookingModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) {
          final payload = Map<String, dynamic>.from(json as Map);
          final booking = payload['booking'] ?? payload['data'];
          return BookingModel.fromJson(
            booking is Map ? Map<String, dynamic>.from(booking) : payload,
          );
        },
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

  // PUT /api/booking/status/:bookingId
  Future<DataResponse<dynamic>> updateBookingStatus({
    required String bookingId,
    required bool accept,
    String? notes,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.vendorUpdateBookingStatus(bookingId),
        data: {
          'status': accept ? 'Confirmed' : 'Rejected',
          'notes': notes ??
              (accept ? 'Booking confirmed by vendor' : 'Booking rejected by vendor'),
        },
        options: Injector.getHeaderToken(),
      );
      return DataResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<dynamic>(isSuccess: false, message: msg, error: msg);
    }
  }
}

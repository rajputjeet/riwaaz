import 'package:dio/dio.dart';

import '../injector.dart';
import '../models/notification_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class NotificationApiProvider {
  final Dio _dio = Injector().getDio();

  Future<DataResponse<bool>> registerDeviceToken({
    required String token,
    required String deviceId,
    required String platform,
    required String appVersion,
  }) => _mutate(
    () => _dio.post(
      ApiConstants.notificationRegisterToken,
      data: {
        'token': token,
        'deviceId': deviceId,
        'platform': platform,
        'appVersion': appVersion,
      },
      options: Injector.getHeaderToken(),
    ),
  );

  Future<DataResponse<bool>> removeDeviceToken({
    required String token,
    required String deviceId,
  }) => _mutate(
    () => _dio.post(
      ApiConstants.notificationRemoveToken,
      data: {'token': token, 'deviceId': deviceId},
      options: Injector.getHeaderToken(),
    ),
  );

  Future<DataResponse<NotificationPage>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
    String? type,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.notificationsList,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (isRead != null) 'isRead': isRead,
          if (type != null && type.isNotEmpty) 'type': type,
        },
        options: Injector.getHeaderToken(),
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final rawData = body['data'];
      final rawMeta = body['_meta'];
      if (body['success'] != true || rawData is! Map) {
        return DataResponse<NotificationPage>(
          isSuccess: false,
          message:
              body['message']?.toString() ?? 'Unable to load notifications.',
        );
      }

      return DataResponse<NotificationPage>(
        isSuccess: true,
        message: body['message']?.toString(),
        data: NotificationPage.fromJson(
          Map<String, dynamic>.from(rawData),
          meta: rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : null,
        ),
      );
    } catch (e) {
      final message = NetworkHandling.getDioException(e);
      return DataResponse<NotificationPage>(
        isSuccess: false,
        message: message,
        error: message,
      );
    }
  }

  Future<DataResponse<NotificationModel>> viewNotification(String id) async {
    try {
      final response = await _dio.get(
        ApiConstants.notificationView(id),
        options: Injector.getHeaderToken(),
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final rawData = body['data'];
      return DataResponse<NotificationModel>(
        isSuccess: body['success'] == true && rawData is Map,
        message: body['message']?.toString(),
        data: rawData is Map
            ? NotificationModel.fromJson(Map<String, dynamic>.from(rawData))
            : null,
      );
    } catch (e) {
      final message = NetworkHandling.getDioException(e);
      return DataResponse<NotificationModel>(
        isSuccess: false,
        message: message,
        error: message,
      );
    }
  }

  Future<DataResponse<bool>> markAsRead(String id) => _mutate(
    () => _dio.put(
      ApiConstants.notificationRead(id),
      options: Injector.getHeaderToken(),
    ),
  );

  Future<DataResponse<bool>> markAllAsRead() => _mutate(
    () => _dio.put(
      ApiConstants.notificationsReadAll,
      options: Injector.getHeaderToken(),
    ),
  );

  Future<DataResponse<bool>> deleteNotification(String id) => _mutate(
    () => _dio.delete(
      ApiConstants.notificationDelete(id),
      options: Injector.getHeaderToken(),
    ),
  );

  Future<DataResponse<bool>> deleteMultipleNotifications(List<String> ids) =>
      _mutate(
        () => _dio.post(
          ApiConstants.notificationsDeleteMultiple,
          data: {'ids': ids},
          options: Injector.getHeaderToken(),
        ),
      );

  Future<DataResponse<bool>> deleteAllNotifications() => _mutate(
    () => _dio.delete(
      ApiConstants.notificationsDeleteAll,
      options: Injector.getHeaderToken(),
    ),
  );

  Future<DataResponse<bool>> _mutate(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final response = await call();
      final body = Map<String, dynamic>.from(response.data as Map);
      return DataResponse<bool>(
        isSuccess: body['success'] == true,
        message: body['message']?.toString(),
        data: body['success'] == true,
      );
    } catch (e) {
      final message = NetworkHandling.getDioException(e);
      return DataResponse<bool>(
        isSuccess: false,
        message: message,
        error: message,
      );
    }
  }
}

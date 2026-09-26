import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/subscription_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class SubscriptionApiProvider {
  late final Dio _dio;

  SubscriptionApiProvider() {
    _dio = Injector().getDio();
  }

  // 5. Get Subscription Partner Plans (GET /api/subscription/list)
  Future<DataResponse<List<SubscriptionModel>>> getSubscriptionList() async {
    try {
      final response = await _dio.get(
        ApiConstants.subscriptionList,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<List<SubscriptionModel>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) {
          if (json is List) {
            return json
                .map((e) =>
                    SubscriptionModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<SubscriptionModel>>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: [],
      );
    }
  }
}

import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/faq_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class FaqApiProvider {
  late final Dio _dio;

  FaqApiProvider() {
    _dio = Injector().getDio();
  }

  /// Get FAQ List (GET /api/faq/list)
  Future<DataResponse<List<FaqModel>>> getFaqList() async {
    try {
      final response = await _dio.get(ApiConstants.faqList);
      return DataResponse<List<FaqModel>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) {
          if (json is List) {
            return json
                .map((e) => FaqModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<FaqModel>>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: [],
      );
    }
  }
}

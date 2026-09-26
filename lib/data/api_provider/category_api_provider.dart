import 'package:dio/dio.dart';
import '../injector.dart';
import '../models/category_model.dart';
import '../network_handling.dart';
import '../shared/data_response.dart';
import 'api_constant.dart';

class CategoryApiProvider {
  late final Dio _dio;

  CategoryApiProvider() {
    _dio = Injector().getDio();
  }

  // 4. Get Business Categories (GET /api/category/list)
  Future<DataResponse<List<CategoryModel>>> getCategoryList() async {
    try {
      final response = await _dio.get(
        ApiConstants.categoryList,
        options: Injector.getHeaderToken(),
      );

      return DataResponse<List<CategoryModel>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) {
          if (json is List) {
            return json
                .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );
    } catch (e) {
      final msg = NetworkHandling.getDioException(e);
      return DataResponse<List<CategoryModel>>(
        isSuccess: false,
        message: msg,
        error: msg,
        data: [],
      );
    }
  }
}

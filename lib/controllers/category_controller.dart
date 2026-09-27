import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/constants/service_categories.dart';
import '../data/api_provider/category_api_provider.dart';
import '../data/models/category_model.dart';

/// Global controller managing dynamic categories throughout the app for both
/// customer (User) and vendor sides.
class CategoryController extends GetxController {
  static CategoryController get to => Get.find<CategoryController>();

  final CategoryApiProvider _apiProvider = CategoryApiProvider();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ServiceCategoryItem> serviceCategories = <ServiceCategoryItem>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoaded = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCategory = ''.obs;

  bool get _isInTest {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Fetch fresh dynamic categories from API in real runtime
    if (!_isInTest) {
      fetchCategories();
    }
  }

  /// Fetches dynamic categories from GET /api/category/list
  Future<void> fetchCategories({bool forceRefresh = false, String? search}) async {
    if (isLoading.value && !forceRefresh) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiProvider.getCategoryList(search: search);

      if (response.isSuccess == true && response.data != null) {
        categories.assignAll(response.data!);

        final mapped = <ServiceCategoryItem>[];
        for (int i = 0; i < response.data!.length; i++) {
          final model = response.data![i];
          mapped.add(ServiceCategoryItem.fromCategoryModel(model, index: i));
        }

        serviceCategories.assignAll(mapped);
        isLoaded.value = true;

        if (kDebugMode) {
          debugPrint('Successfully loaded ${categories.length} dynamic categories from server.');
        }
      } else {
        if (response.error != null && response.error!.isNotEmpty) {
          errorMessage.value = response.error!;
        } else if (response.message != null && response.message!.isNotEmpty) {
          errorMessage.value = response.message!;
        }
        categories.clear();
        serviceCategories.clear();
        isLoaded.value = true;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      categories.clear();
      serviceCategories.clear();
      isLoaded.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Resolves category MongoDB ID from either name, title, or partial match
  String resolveCategoryId(String nameOrId) {
    if (nameOrId.trim().isEmpty) return '';

    final lower = nameOrId.toLowerCase().trim();

    // 1. Check exact or ID match in dynamic categories
    for (final cat in categories) {
      if (cat.id != null && cat.id!.toLowerCase() == lower) {
        return cat.id!;
      }
      final catName = cat.name?.toLowerCase().trim() ?? '';
      if (catName == lower) {
        return cat.id ?? '';
      }
    }

    // 2. Check contains match in dynamic categories
    for (final cat in categories) {
      final catName = cat.name?.toLowerCase().trim() ?? '';
      if (catName.isNotEmpty && (catName.contains(lower) || lower.contains(catName))) {
        return cat.id ?? '';
      }
    }

    // 3. Check serviceCategories match
    for (final item in serviceCategories) {
      if (item.title.toLowerCase().trim() == lower) {
        return item.serverId ?? item.id.toString();
      }
    }

    return nameOrId;
  }

  /// Resolves display name for a category ID or name
  String resolveCategoryName(String idOrName) {
    for (final cat in categories) {
      if (cat.id == idOrName) {
        return cat.name ?? idOrName;
      }
    }
    return idOrName;
  }

  /// Get ServiceCategoryItem by title
  ServiceCategoryItem? getCategoryByName(String title) {
    final lower = title.toLowerCase().trim();
    for (final item in serviceCategories) {
      if (item.title.toLowerCase().trim() == lower) {
        return item;
      }
    }
    return null;
  }

  /// Filter categories by search query
  List<ServiceCategoryItem> filterCategories(String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) return serviceCategories;
    return serviceCategories.where((c) {
      return c.title.toLowerCase().contains(cleanQuery) ||
          c.desc.toLowerCase().contains(cleanQuery);
    }).toList();
  }
}

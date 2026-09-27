import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shaadi_hub/controllers/category_controller.dart';
import 'package:shaadi_hub/core/constants/service_categories.dart';
import 'package:shaadi_hub/data/api_provider/api_constant.dart';
import 'package:shaadi_hub/data/models/category_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dynamic Category Model & Icon Tests (CATEGORY_API_DOCS.md)', () {
    test('1. Resolves relative icon URL with base URL', () {
      final json = {
        "_id": "673f8a9e1234567890abcdef",
        "name": "Banquet Halls & Hotels",
        "description": "Venues and banquet spaces for every event size.",
        "icon": {
          "url": "/uploads/categories/1727435000_icon.png",
          "public_id": "categories/1727435000_icon"
        },
        "stateId": 1,
        "createdAt": "2026-09-27T10:00:00.000Z",
        "updatedAt": "2026-09-27T10:00:00.000Z"
      };

      final model = CategoryModel.fromJson(json);

      expect(model.id, equals("673f8a9e1234567890abcdef"));
      expect(model.name, equals("Banquet Halls & Hotels"));
      expect(model.desc, equals("Venues and banquet spaces for every event size."));
      expect(model.stateId, equals(1));
      expect(model.iconUrl, equals("${ApiConstants.baseUrl}/uploads/categories/1727435000_icon.png"));
    });

    test('2. Preserves absolute icon URL as is', () {
      final json = {
        "_id": "673f8a9e1234567890abcdeg",
        "name": "Makeup & Hair",
        "description": "Professional styling for your special day.",
        "icon": {
          "url": "https://cdn.example.com/icons/makeup.png",
          "public_id": "categories/makeup"
        },
        "stateId": 1,
      };

      final model = CategoryModel.fromJson(json);

      expect(model.id, equals("673f8a9e1234567890abcdeg"));
      expect(model.iconUrl, equals("https://cdn.example.com/icons/makeup.png"));
    });

    test('3. Converts CategoryModel to ServiceCategoryItem with serverId and server icon', () {
      final model = CategoryModel(
        id: "673f8a9e1234567890abcdef",
        name: "Banquet Halls & Hotels",
        desc: "Venues and banquet spaces for every event size.",
        iconUrl: "https://wedora-pgc7.onrender.com/uploads/categories/banquet.png",
      );

      final item = ServiceCategoryItem.fromCategoryModel(model);

      expect(item.serverId, equals("673f8a9e1234567890abcdef"));
      expect(item.title, equals("Banquet Halls & Hotels"));
      expect(item.iconUrl, equals("https://wedora-pgc7.onrender.com/uploads/categories/banquet.png"));
      expect(item.hasServerIcon, isTrue);
    });

    test('4. CategoryController starts without static categories and strictly loads server categories', () {
      Get.reset();
      final controller = Get.put(CategoryController());

      // Should NOT have static categories seeded
      expect(controller.serviceCategories.isEmpty || controller.isLoading.value, isTrue);

      // Add a dynamic category with MongoDB ID from server
      controller.categories.assignAll([
        CategoryModel(
          id: "673f8a9e9999999999abcdef",
          name: "Luxury Caterers",
          desc: "Exquisite culinary experiences",
        )
      ]);
      controller.serviceCategories.assignAll([
        ServiceCategoryItem.fromCategoryModel(controller.categories.first)
      ]);

      expect(controller.serviceCategories.length, equals(1));
      expect(controller.serviceCategories.first.title, equals("Luxury Caterers"));

      final resolved = controller.resolveCategoryId("Luxury Caterers");
      expect(resolved, equals("673f8a9e9999999999abcdef"));
    });
  });
}

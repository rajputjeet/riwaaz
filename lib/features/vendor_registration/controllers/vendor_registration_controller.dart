import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../controllers/category_controller.dart';
import '../../../data/api_provider/subscription_api_provider.dart';
import '../../../data/api_provider/vendor_api_provider.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/models/vendor_application_model.dart';
import '../../../data/shared/data_response.dart';
import '../../../utils/helper/storage_helper.dart';
import '../../../utils/utils.dart';

class VendorRegistrationController extends GetxController {
  final SubscriptionApiProvider _subscriptionApiProvider =
      SubscriptionApiProvider();
  final VendorApiProvider _vendorApiProvider = VendorApiProvider();
  final StorageHelper _storageHelper = StorageHelper();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<SubscriptionModel> subscriptionPlans = <SubscriptionModel>[].obs;

  final RxString selectedCategoryId = ''.obs;
  final RxString selectedCategoryName = ''.obs;
  final RxString selectedSubscriptionPlanId = ''.obs;

  final Rxn<VendorApplicationModel> applicationData =
      Rxn<VendorApplicationModel>();
  final RxString currentStatus = 'Under Review'.obs;
  final RxBool isVerified = false.obs;
  final RxBool isDraftSavedOnServer = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchSubscriptions();
    final savedAppId = _storageHelper.getApplicationId();
    if (savedAppId != null) {
      fetchApplicationStatus();
    }
  }

  // 4. Get Business Categories (GET /api/category/list)
  Future<void> fetchCategories() async {
    isLoading.value = true;
    final categoryCtrl = Get.isRegistered<CategoryController>()
        ? CategoryController.to
        : Get.put(CategoryController(), permanent: true);

    if (categoryCtrl.categories.isEmpty) {
      await categoryCtrl.fetchCategories();
    }
    isLoading.value = false;

    categories.assignAll(categoryCtrl.categories);

    if (categories.isNotEmpty && selectedCategoryId.isEmpty) {
      selectedCategoryId.value = categories.first.id ?? '';
      selectedCategoryName.value = categories.first.name ?? '';
    }
  }

  // 5. Get Subscription Partner Plans (GET /api/subscription/list)
  Future<void> fetchSubscriptions({bool forceRefresh = false}) async {
    if (!forceRefresh && subscriptionPlans.isNotEmpty) return;
    isLoading.value = true;
    final response = await _subscriptionApiProvider.getSubscriptionList();
    isLoading.value = false;

    if (response.isSuccess == true &&
        response.data != null &&
        response.data!.isNotEmpty) {
      subscriptionPlans.assignAll(response.data!);
      if (selectedSubscriptionPlanId.isEmpty) {
        final preferred =
            subscriptionPlans.firstWhereOrNull(
              (p) => p.durationInMonths == 6 || p.type?.contains('6') == true,
            ) ??
            subscriptionPlans.first;
        selectedSubscriptionPlanId.value = preferred.id ?? '';
      }
    }
  }

  // 6. Submit Vendor Application (POST /api/users/vendor/application/submit)
  Future<DataResponse<VendorApplicationModel>> submitApplication({
    required String ownerName,
    required String businessName,
    required String yearsOfExperience,
    required String businessDescription,
    required String businessAddress,
    String? addressUrl,
    required String city,
    String? state,
    String? pincode,
    String? gstNumber,
    required String categoryId,
    String? categoryName,
    String? email,
    String? mobile,
    String? fullName,
    Set<String> existingDocuments = const {},
    dynamic aadharFile,
    dynamic aadharFrontFile,
    dynamic aadharBackFile,
    dynamic liveSelfieFile,
    dynamic panFile,
    dynamic businessCertFile,
    dynamic addressProofFile,
    dynamic gstDocFile,
    bool isPreliminaryUpload = false,
  }) async {
    isSubmitting.value = true;

    final actualFront = aadharFrontFile ?? aadharFile;
    final documents = <String, dynamic>{
      'aadharFront': actualFront,
      'aadharBack': aadharBackFile,
      'liveSelfie': liveSelfieFile,
      'pan': panFile,
      'businessCert': businessCertFile,
      'addressProof': addressProofFile,
      'gstDoc': gstDocFile,
    };
    bool hasDocument(String key) =>
        existingDocuments.contains(key) ||
        documents[key] is MultipartFile ||
        (documents[key] is String &&
            (documents[key] as String).trim().isNotEmpty &&
            !(documents[key] as String).startsWith('http'));
    if (![
      'aadharFront',
      'aadharBack',
      'liveSelfie',
      'pan',
    ].every(hasDocument)) {
      isSubmitting.value = false;
      return DataResponse<VendorApplicationModel>(
        isSuccess: false,
        message:
            'Aadhaar front and back, PAN Card and a live selfie are required.',
      );
    }
    try {
      final formDataMap = <String, dynamic>{
        'ownerName': ownerName.trim(),
        if (email?.trim().isNotEmpty == true) 'email': email!.trim(),
        if (mobile?.trim().isNotEmpty == true) 'mobile': mobile!.trim(),
        if (fullName?.trim().isNotEmpty == true) 'fullName': fullName!.trim(),
        'businessName': businessName.trim(),
        'yearsOfExperience': yearsOfExperience.trim(),
        'businessDescription': businessDescription.trim(),
        'businessAddress': businessAddress.trim(),
        'city': city.trim(),
        if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
        if (pincode != null && pincode.trim().isNotEmpty)
          'pincode': pincode.trim(),
        if (addressUrl != null && addressUrl.trim().isNotEmpty)
          'addressUrl': addressUrl.trim(),
        if (gstNumber != null && gstNumber.trim().isNotEmpty)
          'gstNumber': gstNumber.trim(),
        'categoryId': categoryId,
        if (categoryName != null && categoryName.trim().isNotEmpty) ...{
          'category': categoryName.trim(),
          'categoryName': categoryName.trim(),
        },
      };

      // Existing server documents are retained; upload only newly selected files.
      for (final entry in documents.entries) {
        final file = entry.value;
        if (file is MultipartFile) {
          formDataMap[entry.key] = file.clone();
        } else if (file is String &&
            file.trim().isNotEmpty &&
            !file.startsWith('http')) {
          formDataMap[entry.key] = await MultipartFile.fromFile(
            file,
            filename: file.split(RegExp(r'[\/]')).last,
          );
        }
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _vendorApiProvider.submitVendorApplication(
        formData,
      );
      isSubmitting.value = false;

      if (response.isSuccess == true && response.data != null) {
        applicationData.value = response.data!;
        currentStatus.value =
            response.data!.applicationStatus ?? 'Under Review';
        isVerified.value = response.data!.isVerified ?? false;
        isDraftSavedOnServer.value = true;

        await _storageHelper.saveApplicationId(response.data!.applicationId);
        await _storageHelper.saveApplicationStatus(
          response.data!.applicationStatus,
        );
        await _storageHelper.saveIsVerified(response.data!.isVerified);

        if (!isPreliminaryUpload) {
          Utils.showSnackBar(
            response.message ?? 'Application submitted successfully!',
            isError: false,
          );
        }
      } else {
        if (!isPreliminaryUpload) {
          Utils.showSnackBar(
            response.message ??
                response.error ??
                'Failed to submit application',
            isError: true,
          );
        }
      }

      return response;
    } catch (_) {
      return DataResponse<VendorApplicationModel>(
        isSuccess: false,
        message:
            'Could not submit your documents. Please select the files again and retry.',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Draft Helpers ──────────────────────────────────────────────────────────
  Future<void> saveLocalDraft(Map<String, dynamic> draft) async {
    await _storageHelper.saveVendorDraft(draft);
  }

  Map<String, dynamic>? getLocalDraft() {
    return _storageHelper.getVendorDraft();
  }

  Future<void> clearLocalDraft() async {
    await _storageHelper.clearVendorDraft();
  }

  // 7. Track Vendor Application Status (GET /api/users/vendor/application/status)
  Future<DataResponse<VendorApplicationModel>> fetchApplicationStatus() async {
    isLoading.value = true;
    final response = await _vendorApiProvider.getVendorApplicationStatus();
    isLoading.value = false;

    if (response.isSuccess == true && response.data != null) {
      applicationData.value = response.data!;
      currentStatus.value = response.data!.applicationStatus ?? 'Under Review';
      isVerified.value = response.data!.isVerified ?? false;

      await _storageHelper.saveApplicationId(response.data!.applicationId);
      await _storageHelper.saveApplicationStatus(
        response.data!.applicationStatus,
      );
      await _storageHelper.saveIsVerified(response.data!.isVerified);
    }

    return response;
  }
}

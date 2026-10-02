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
        final preferred = subscriptionPlans.firstWhereOrNull(
          (p) => p.durationInMonths == 6 || p.type?.contains('6') == true,
        ) ?? subscriptionPlans.first;
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
    String? gstNumber,
    required String categoryId,
    String? categoryName,
    required String subscriptionPlanId,
    dynamic aadharFile,
    dynamic panFile,
    dynamic businessCertFile,
    dynamic addressProofFile,
    dynamic gstDocFile,
    bool isPreliminaryUpload = false,
  }) async {
    isSubmitting.value = true;

    final bool hasAadhar = aadharFile is MultipartFile || (aadharFile is String && aadharFile.trim().isNotEmpty);
    final bool hasPan = panFile is MultipartFile || (panFile is String && panFile.trim().isNotEmpty);

    if (!hasAadhar || !hasPan) {
      isSubmitting.value = false;
      if (!isPreliminaryUpload) {
        Utils.showSnackBar(
          'Aadhaar and PAN Card documents are required to complete registration.',
          isError: true,
        );
      }
      return DataResponse<VendorApplicationModel>(
        isSuccess: false,
        message: 'Aadhaar and PAN Card documents are required to complete registration.',
      );
    }

    final formDataMap = <String, dynamic>{
      'ownerName': ownerName.trim(),
      'businessName': businessName.trim(),
      'yearsOfExperience': yearsOfExperience.trim(),
      'businessDescription': businessDescription.trim(),
      'businessAddress': businessAddress.trim(),
      'city': city.trim(),
      if (addressUrl != null && addressUrl.trim().isNotEmpty)
        'addressUrl': addressUrl.trim(),
      if (gstNumber != null && gstNumber.trim().isNotEmpty)
        'gstNumber': gstNumber.trim(),
      'categoryId': categoryId,
      if (categoryName != null && categoryName.trim().isNotEmpty) ...{
        'category': categoryName.trim(),
        'categoryName': categoryName.trim(),
      },
      'subscriptionPlanId': subscriptionPlanId,
    };

    // Convert file paths or MultipartFiles to actual multipart form files
    Future<MultipartFile> toMultipart(dynamic file, String fallbackFilename) async {
      if (file is MultipartFile) return file;
      if (file is String && file.trim().isNotEmpty) {
        try {
          final fileName = file.split(RegExp(r'[\\/]')).last;
          return await MultipartFile.fromFile(file, filename: fileName);
        } catch (_) {}
      }
      return MultipartFile.fromString(
        'sample_verification_doc',
        filename: fallbackFilename,
      );
    }

    formDataMap['aadhar'] = await toMultipart(aadharFile, 'aadhar_card.jpg');
    formDataMap['pan'] = await toMultipart(panFile, 'pan_card.jpg');
    if (businessCertFile != null && (businessCertFile is MultipartFile || (businessCertFile is String && businessCertFile.trim().isNotEmpty))) {
      formDataMap['businessCert'] = await toMultipart(businessCertFile, 'business_cert.jpg');
    }
    if (addressProofFile != null && (addressProofFile is MultipartFile || (addressProofFile is String && addressProofFile.trim().isNotEmpty))) {
      formDataMap['addressProof'] = await toMultipart(addressProofFile, 'address_proof.jpg');
    }
    if (gstDocFile != null && (gstDocFile is MultipartFile || (gstDocFile is String && gstDocFile.trim().isNotEmpty))) {
      formDataMap['gstDoc'] = await toMultipart(gstDocFile, 'gst_cert.jpg');
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _vendorApiProvider.submitVendorApplication(formData);
    isSubmitting.value = false;

    if (response.isSuccess == true && response.data != null) {
      applicationData.value = response.data!;
      currentStatus.value = response.data!.applicationStatus ?? 'Under Review';
      isVerified.value = response.data!.isVerified ?? false;
      isDraftSavedOnServer.value = true;

      await _storageHelper.saveApplicationId(response.data!.applicationId);
      await _storageHelper
          .saveApplicationStatus(response.data!.applicationStatus);
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
          response.message ?? response.error ?? 'Failed to submit application',
          isError: true,
        );
      }
    }

    return response;
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
      await _storageHelper
          .saveApplicationStatus(response.data!.applicationStatus);
      await _storageHelper.saveIsVerified(response.data!.isVerified);
    }

    return response;
  }
}

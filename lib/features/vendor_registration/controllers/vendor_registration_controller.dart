import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../data/api_provider/category_api_provider.dart';
import '../../../data/api_provider/subscription_api_provider.dart';
import '../../../data/api_provider/vendor_api_provider.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/models/vendor_application_model.dart';
import '../../../data/shared/data_response.dart';
import '../../../utils/helper/storage_helper.dart';
import '../../../utils/utils.dart';

class VendorRegistrationController extends GetxController {
  final CategoryApiProvider _categoryApiProvider = CategoryApiProvider();
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
    final response = await _categoryApiProvider.getCategoryList();
    isLoading.value = false;

    if (response.isSuccess == true && response.data != null) {
      categories.assignAll(response.data!);
      if (categories.isNotEmpty && selectedCategoryId.isEmpty) {
        selectedCategoryId.value = categories.first.id ?? '';
        selectedCategoryName.value = categories.first.name ?? '';
      }
    }
  }

  // 5. Get Subscription Partner Plans (GET /api/subscription/list)
  Future<void> fetchSubscriptions() async {
    isLoading.value = true;
    final response = await _subscriptionApiProvider.getSubscriptionList();
    isLoading.value = false;

    if (response.isSuccess == true && response.data != null) {
      subscriptionPlans.assignAll(response.data!);
      if (subscriptionPlans.isNotEmpty && selectedSubscriptionPlanId.isEmpty) {
        selectedSubscriptionPlanId.value = subscriptionPlans.first.id ?? '';
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
    required String city,
    String? gstNumber,
    required String categoryId,
    required String subscriptionPlanId,
    dynamic aadharFile,
    dynamic panFile,
    dynamic businessCertFile,
    dynamic addressProofFile,
    dynamic gstDocFile,
  }) async {
    isSubmitting.value = true;

    final formDataMap = <String, dynamic>{
      'ownerName': ownerName.trim(),
      'businessName': businessName.trim(),
      'yearsOfExperience': yearsOfExperience.trim(),
      'businessDescription': businessDescription.trim(),
      'businessAddress': businessAddress.trim(),
      'city': city.trim(),
      if (gstNumber != null && gstNumber.trim().isNotEmpty)
        'gstNumber': gstNumber.trim(),
      'categoryId': categoryId,
      'subscriptionPlanId': subscriptionPlanId,
    };

    // Attach multipart file fields if provided, otherwise provide dummy multipart filenames
    if (aadharFile is MultipartFile) {
      formDataMap['aadhar'] = aadharFile;
    } else {
      formDataMap['aadhar'] = MultipartFile.fromString(
        'aadhar_placeholder_content',
        filename: 'aadhar_card.pdf',
      );
    }

    if (panFile is MultipartFile) {
      formDataMap['pan'] = panFile;
    } else {
      formDataMap['pan'] = MultipartFile.fromString(
        'pan_placeholder_content',
        filename: 'pan_card.pdf',
      );
    }

    if (businessCertFile is MultipartFile) {
      formDataMap['businessCert'] = businessCertFile;
    } else {
      formDataMap['businessCert'] = MultipartFile.fromString(
        'business_cert_content',
        filename: 'business_cert.pdf',
      );
    }

    if (addressProofFile is MultipartFile) {
      formDataMap['addressProof'] = addressProofFile;
    } else {
      formDataMap['addressProof'] = MultipartFile.fromString(
        'address_proof_content',
        filename: 'address_proof.pdf',
      );
    }

    if (gstDocFile is MultipartFile) {
      formDataMap['gstDoc'] = gstDocFile;
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _vendorApiProvider.submitVendorApplication(formData);
    isSubmitting.value = false;

    if (response.isSuccess == true && response.data != null) {
      applicationData.value = response.data!;
      currentStatus.value = response.data!.applicationStatus ?? 'Under Review';
      isVerified.value = response.data!.isVerified ?? false;

      await _storageHelper.saveApplicationId(response.data!.applicationId);
      await _storageHelper
          .saveApplicationStatus(response.data!.applicationStatus);
      await _storageHelper.saveIsVerified(response.data!.isVerified);

      Utils.showSnackBar(
        response.message ?? 'Application submitted successfully!',
        isError: false,
      );
    } else {
      Utils.showSnackBar(
        response.message ?? response.error ?? 'Failed to submit application',
        isError: true,
      );
    }

    return response;
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

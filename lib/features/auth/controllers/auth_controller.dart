import 'package:get/get.dart';
import '../../../data/api_provider/auth_api_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/shared/data_response.dart';
import '../../../utils/helper/storage_helper.dart';
import '../../../utils/utils.dart';

class AuthController extends GetxController {
  final AuthApiProvider _authApiProvider = AuthApiProvider();
  final StorageHelper _storageHelper = StorageHelper();

  final RxBool isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxnInt generatedOtp = RxnInt(); // OTP returned by server, used to auto-fill

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    final cached = _storageHelper.getUserModel();
    if (cached != null) {
      currentUser.value = UserModel.fromJson(cached);
    }
  }

  // 1. Sign Up (POST /api/auth/sign-up)
  Future<DataResponse<UserModel>> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required int roleId, // 2 = Customer, 4 = Vendor Partner
  }) async {
    isLoading.value = true;

    final requestBody = {
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password': password,
      'roleId': roleId,
    };

    final response = await _authApiProvider.signUp(requestBody);
    isLoading.value = false;

    if (response.isSuccess == true && response.data != null) {
      final user = response.data!;
      // Save OTP from response for auto-fill in OTP screen
      if (user.otp != null) generatedOtp.value = user.otp;
      await _storageHelper.saveUserId(user.id);
      await _storageHelper.saveUserEmail(user.email);
      await _storageHelper.saveUserMobile(user.mobile);
      await _storageHelper.saveRoleId(roleId);
      await _storageHelper.saveUserName(user.fullName ?? fullName);
    } else {
      Utils.showSnackBar(
        response.message ?? response.error ?? 'Sign up failed',
        isError: true,
      );
    }

    return response;
  }

  // 2. Verify OTP (POST /api/auth/verify-otp)
  Future<DataResponse<UserModel>> verifyOtp({
    required String identifier,
    required int otp,
    int? roleId,
    String? name,
  }) async {
    isLoading.value = true;

    final response = await _authApiProvider.verifyOtp(
      identifier: identifier.trim(),
      otp: otp,
      roleId: roleId,
      name: name,
    );

    isLoading.value = false;

    if (response.isSuccess == true && response.data != null) {
      final user = response.data!;
      currentUser.value = user;

      // Persist full session
      if (user.bearerToken != null) {
        await _storageHelper.saveAccessToken(user.bearerToken);
      }
      if (user.refreshToken != null) {
        await _storageHelper.saveRefreshToken(user.refreshToken);
      }
      await _storageHelper.saveUserId(user.id);
      await _storageHelper.saveUserEmail(user.email);
      await _storageHelper.saveUserMobile(user.mobile);
      await _storageHelper.saveUserName(user.fullName ?? name);
      await _storageHelper.saveRoleId(user.roleId ?? roleId ?? 2);
      await _storageHelper.saveIsVerified(user.isVerified ?? false);
      await _storageHelper.saveIsLoggedIn(true);
      await _storageHelper.saveUserModel(user.toJson());

      if (user.vendorProfile != null) {
        await _storageHelper.saveApplicationId(user.vendorProfile?.applicationId);
        await _storageHelper.saveApplicationStatus(user.vendorProfile?.applicationStatus);
      }
    } else {
      Utils.showSnackBar(
        response.message ?? response.error ?? 'Invalid OTP code',
        isError: true,
      );
    }

    return response;
  }

  // 3. Resend OTP (POST /api/auth/resend-otp)
  Future<DataResponse<UserModel>> resendOtp({
    required String identifier,
  }) async {
    isLoading.value = true;
    final response = await _authApiProvider.resendOtp(identifier: identifier.trim());
    isLoading.value = false;

    if (response.isSuccess == true) {
      // Save new OTP for auto-fill if server returns one
      if (response.data?.otp != null) generatedOtp.value = response.data!.otp;
      Utils.showSnackBar(
        response.message ?? 'New OTP sent successfully',
        isError: false,
      );
    } else {
      Utils.showSnackBar(
        response.message ?? response.error ?? 'Failed to resend OTP',
        isError: true,
      );
    }

    return response;
  }

  // 8. User / Vendor Login (POST /api/auth/login)
  Future<DataResponse<UserModel>> login({
    required String identifier,
    required String password,
  }) async {
    isLoading.value = true;

    final response = await _authApiProvider.logIn(
      identifier: identifier.trim(),
      password: password,
    );

    isLoading.value = false;

    if (response.isSuccess == true && response.data != null) {
      final user = response.data!;
      currentUser.value = user;

      // Persist full session
      if (user.bearerToken != null) {
        await _storageHelper.saveAccessToken(user.bearerToken);
      }
      if (user.refreshToken != null) {
        await _storageHelper.saveRefreshToken(user.refreshToken);
      }
      await _storageHelper.saveUserId(user.id);
      await _storageHelper.saveUserEmail(user.email);
      await _storageHelper.saveUserMobile(user.mobile);
      await _storageHelper.saveUserName(user.fullName);
      await _storageHelper.saveRoleId(user.roleId ?? 2);
      await _storageHelper.saveIsVerified(user.isVerified ?? false);
      await _storageHelper.saveIsLoggedIn(true);
      await _storageHelper.saveUserModel(user.toJson());

      if (user.vendorProfile != null) {
        await _storageHelper.saveApplicationId(user.vendorProfile?.applicationId);
        await _storageHelper.saveApplicationStatus(user.vendorProfile?.applicationStatus);
      }
    } else {
      Utils.showSnackBar(
        response.message ?? response.error ?? 'Login failed. Please check credentials.',
        isError: true,
      );
    }

    return response;
  }

  Future<void> logout() async {
    await _storageHelper.clearSession();
    currentUser.value = null;
  }
}

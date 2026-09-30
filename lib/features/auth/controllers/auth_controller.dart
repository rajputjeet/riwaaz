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

  // 1. Sign Up & Seamless Direct Sign In without OTP
  Future<DataResponse<UserModel>> signUpAndSignIn({
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

    final signUpRes = await _authApiProvider.signUp(requestBody);

    if (signUpRes.isSuccess != true || signUpRes.data == null) {
      isLoading.value = false;
      Utils.showSnackBar(
        signUpRes.message ?? signUpRes.error ?? 'Sign up failed',
        isError: true,
      );
      return signUpRes;
    }

    final user = signUpRes.data!;
    final identifier = email.trim().isNotEmpty ? email.trim() : phone.trim();

    // 1. If backend returned an OTP, auto-verify it silently behind the scenes to activate account & retrieve tokens
    if (user.otp != null) {
      final verifyRes = await _authApiProvider.verifyOtp(
        identifier: identifier,
        otp: user.otp!,
        roleId: roleId,
        name: fullName,
      );

      if (verifyRes.isSuccess == true && verifyRes.data != null) {
        final verifiedUser = verifyRes.data!;
        currentUser.value = verifiedUser;

        if (verifiedUser.bearerToken != null) {
          await _storageHelper.saveAccessToken(verifiedUser.bearerToken);
        }
        if (verifiedUser.refreshToken != null) {
          await _storageHelper.saveRefreshToken(verifiedUser.refreshToken);
        }
        await _storageHelper.saveUserId(verifiedUser.id ?? user.id);
        await _storageHelper.saveUserEmail(verifiedUser.email ?? user.email);
        await _storageHelper.saveUserMobile(verifiedUser.mobile ?? user.mobile);
        await _storageHelper.saveUserName(verifiedUser.fullName ?? fullName);
        await _storageHelper.saveRoleId(verifiedUser.roleId ?? roleId);
        await _storageHelper.saveIsVerified(verifiedUser.isVerified ?? true);
        await _storageHelper.saveIsLoggedIn(true);
        await _storageHelper.saveUserModel(verifiedUser.toJson());

        if (verifiedUser.vendorProfile != null) {
          await _storageHelper.saveApplicationId(verifiedUser.vendorProfile?.applicationId);
          await _storageHelper.saveApplicationStatus(verifiedUser.vendorProfile?.applicationStatus);
        }

        isLoading.value = false;
        return verifyRes;
      }
    }

    // 2. If token already returned in sign-up response
    if (user.bearerToken != null && user.bearerToken!.isNotEmpty) {
      currentUser.value = user;
      await _storageHelper.saveAccessToken(user.bearerToken);
      if (user.refreshToken != null) {
        await _storageHelper.saveRefreshToken(user.refreshToken);
      }
      await _storageHelper.saveUserId(user.id);
      await _storageHelper.saveUserEmail(user.email);
      await _storageHelper.saveUserMobile(user.mobile);
      await _storageHelper.saveUserName(user.fullName ?? fullName);
      await _storageHelper.saveRoleId(roleId);
      await _storageHelper.saveIsVerified(true);
      await _storageHelper.saveIsLoggedIn(true);
      await _storageHelper.saveUserModel(user.toJson());

      if (user.vendorProfile != null) {
        await _storageHelper.saveApplicationId(user.vendorProfile?.applicationId);
        await _storageHelper.saveApplicationStatus(user.vendorProfile?.applicationStatus);
      }

      isLoading.value = false;
      return signUpRes;
    }

    // 3. Otherwise log in directly with identifier and password
    final loginRes = await _authApiProvider.logIn(
      identifier: identifier,
      password: password,
    );

    isLoading.value = false;

    if (loginRes.isSuccess == true && loginRes.data != null) {
      final loggedInUser = loginRes.data!;
      currentUser.value = loggedInUser;

      if (loggedInUser.bearerToken != null) {
        await _storageHelper.saveAccessToken(loggedInUser.bearerToken);
      }
      if (loggedInUser.refreshToken != null) {
        await _storageHelper.saveRefreshToken(loggedInUser.refreshToken);
      }
      await _storageHelper.saveUserId(loggedInUser.id ?? user.id);
      await _storageHelper.saveUserEmail(loggedInUser.email ?? user.email);
      await _storageHelper.saveUserMobile(loggedInUser.mobile ?? user.mobile);
      await _storageHelper.saveUserName(loggedInUser.fullName ?? fullName);
      await _storageHelper.saveRoleId(loggedInUser.roleId ?? roleId);
      await _storageHelper.saveIsVerified(loggedInUser.isVerified ?? true);
      await _storageHelper.saveIsLoggedIn(true);
      await _storageHelper.saveUserModel(loggedInUser.toJson());

      if (loggedInUser.vendorProfile != null) {
        await _storageHelper.saveApplicationId(loggedInUser.vendorProfile?.applicationId);
        await _storageHelper.saveApplicationStatus(loggedInUser.vendorProfile?.applicationStatus);
      }

      return loginRes;
    }

    // Fallback: save sign up profile
    currentUser.value = user;
    await _storageHelper.saveUserId(user.id);
    await _storageHelper.saveUserEmail(user.email);
    await _storageHelper.saveUserMobile(user.mobile);
    await _storageHelper.saveUserName(user.fullName ?? fullName);
    await _storageHelper.saveRoleId(roleId);
    await _storageHelper.saveIsVerified(true);
    await _storageHelper.saveIsLoggedIn(true);
    await _storageHelper.saveUserModel(user.toJson());

    return signUpRes;
  }

  // 1b. Legacy Sign Up (POST /api/auth/sign-up)
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

  // Forgot Password (PUT /api/auth/forgot-password)
  Future<DataResponse<dynamic>> forgotPassword({
    required String identifier,
    required String newPassword,
  }) async {
    isLoading.value = true;
    final res = await _authApiProvider.forgotPassword(
      identifier: identifier,
      newPassword: newPassword,
    );
    isLoading.value = false;

    if (res.isSuccess == true) {
      Utils.showSnackBar(res.message ?? 'Password reset successfully', isError: false);
    } else {
      Utils.showSnackBar(res.message ?? res.error ?? 'Failed to reset password', isError: true);
    }
    return res;
  }

  Future<void> logout() async {
    try {
      await _authApiProvider.logOut();
    } catch (_) {}
    await _storageHelper.clearSession();
    currentUser.value = null;
  }
}

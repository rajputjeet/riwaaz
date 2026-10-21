import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../core/services/booking_service.dart';
import '../../vendor_registration/controllers/vendor_registration_controller.dart';
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
    required int roleId, // 2 = Customer, 3 = Vendor Partner
    String? businessName,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? categoryId,
    dynamic aadharFront,
    dynamic aadharBack,
    dynamic liveSelfie,
    dynamic profileImg,
  }) async {
    isLoading.value = true;

    final bool hasFiles = aadharFront != null ||
        aadharBack != null ||
        liveSelfie != null ||
        profileImg != null;

    dynamic requestPayload;

    if (hasFiles) {
      final map = <String, dynamic>{
        'fullName': fullName.trim(),
        'ownerName': fullName.trim(),
        if (businessName != null && businessName.trim().isNotEmpty)
          'businessName': businessName.trim(),
        if (email.trim().isNotEmpty) 'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'mobile': phone.trim(),
        'password': password,
        'roleId': roleId,
        if (address != null && address.trim().isNotEmpty) ...{
          'address': address.trim(),
          'businessAddress': address.trim(),
        },
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
        if (pincode != null && pincode.trim().isNotEmpty) 'pincode': pincode.trim(),
        if (categoryId != null && categoryId.trim().isNotEmpty)
          'categoryId': categoryId.trim(),
      };

      Future<MultipartFile?> toMultipart(dynamic f, String fallbackName) async {
        if (f == null) return null;
        if (f is MultipartFile) return f;
        if (f is File) {
          final fileName = f.path.split(RegExp(r'[\\/]')).last;
          return await MultipartFile.fromFile(f.path, filename: fileName);
        }
        if (f is String && f.trim().isNotEmpty) {
          final fileName = f.split(RegExp(r'[\\/]')).last;
          return await MultipartFile.fromFile(f, filename: fileName);
        }
        return null;
      }

      final fFront = await toMultipart(aadharFront, 'aadhar_front.jpg');
      if (fFront != null) map['aadharFront'] = fFront;

      final fBack = await toMultipart(aadharBack, 'aadhar_back.jpg');
      if (fBack != null) map['aadharBack'] = fBack;

      final fSelfie = await toMultipart(liveSelfie, 'live_selfie.jpg');
      if (fSelfie != null) map['liveSelfie'] = fSelfie;

      final fProfile = await toMultipart(profileImg, 'profile_img.jpg');
      if (fProfile != null) {
        map['profileImgId'] = fProfile;
        map['profileImg'] = fProfile;
      }

      requestPayload = FormData.fromMap(map);
    } else {
      requestPayload = {
        'fullName': fullName.trim(),
        if (businessName != null && businessName.trim().isNotEmpty)
          'businessName': businessName.trim(),
        if (email.trim().isNotEmpty) 'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
        'roleId': roleId,
        if (address != null && address.trim().isNotEmpty) ...{
          'address': address.trim(),
          'businessAddress': address.trim(),
        },
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
        if (pincode != null && pincode.trim().isNotEmpty) 'pincode': pincode.trim(),
      };
    }

    final signUpRes = await _authApiProvider.signUp(requestPayload);

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

    // Helper to persist geographic details
    Future<void> persistLocationDetails() async {
      if (address != null && address.isNotEmpty) {
        await _storageHelper.saveUserAddress(address);
        await _storageHelper.saveWeddingLocation(address);
      }
      if (city != null && city.isNotEmpty) {
        await _storageHelper.saveUserCity(city);
      }
      if (state != null && state.isNotEmpty) {
        await _storageHelper.saveUserState(state);
      }
      if (pincode != null && pincode.isNotEmpty) {
        await _storageHelper.saveUserPincode(pincode);
      }
    }

    // 1. If backend returned an OTP, auto-verify it silently behind the scenes
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
        await _storageHelper.saveIsVerified(verifiedUser.isVerified ?? (roleId == 2));
        await _storageHelper.saveIsLoggedIn(true);
        await _storageHelper.saveUserModel(verifiedUser.toJson());
        await persistLocationDetails();

        if (verifiedUser.vendorProfile != null) {
          await _storageHelper.saveApplicationId(verifiedUser.vendorProfile?.applicationId);
          await _storageHelper.saveApplicationStatus(verifiedUser.vendorProfile?.applicationStatus ?? 'Pending');
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
      await _storageHelper.saveIsVerified(user.isVerified ?? (roleId == 2));
      await _storageHelper.saveIsLoggedIn(true);
      await _storageHelper.saveUserModel(user.toJson());
      await persistLocationDetails();

      if (user.vendorProfile != null) {
        await _storageHelper.saveApplicationId(user.vendorProfile?.applicationId);
        await _storageHelper.saveApplicationStatus(user.vendorProfile?.applicationStatus ?? 'Pending');
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
      await _storageHelper.saveIsVerified(loggedInUser.isVerified ?? (roleId == 2));
      await _storageHelper.saveIsLoggedIn(true);
      await _storageHelper.saveUserModel(loggedInUser.toJson());
      await persistLocationDetails();

      if (loggedInUser.vendorProfile != null) {
        await _storageHelper.saveApplicationId(loggedInUser.vendorProfile?.applicationId);
        await _storageHelper.saveApplicationStatus(loggedInUser.vendorProfile?.applicationStatus ?? 'Pending');
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
    await _storageHelper.saveIsVerified(user.isVerified ?? (roleId == 2));
    await _storageHelper.saveIsLoggedIn(true);
    await _storageHelper.saveUserModel(user.toJson());
    await persistLocationDetails();

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
      if (user.address != null && user.address!.trim().isNotEmpty) {
        await _storageHelper.saveUserAddress(user.address!.trim());
      }
      if (user.city != null && user.city!.trim().isNotEmpty) {
        await _storageHelper.saveUserCity(user.city!.trim());
      }
      if (user.state != null && user.state!.trim().isNotEmpty) {
        await _storageHelper.saveUserState(user.state!.trim());
      }
      if (user.pincode != null && user.pincode!.trim().isNotEmpty) {
        await _storageHelper.saveUserPincode(user.pincode!.trim());
      }

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
    await _storageHelper.clearAllData();
    currentUser.value = null;
    generatedOtp.value = null;
    isLoading.value = false;

    // Clear all booking state
    AppBookingService.instance.clearAll();

    // Reset vendor registration controller if registered
    if (Get.isRegistered<VendorRegistrationController>()) {
      Get.delete<VendorRegistrationController>(force: true);
    }
  }
}

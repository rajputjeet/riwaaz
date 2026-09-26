import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shaadi_hub/data/api_provider/category_api_provider.dart';
import 'package:shaadi_hub/data/api_provider/subscription_api_provider.dart';
import 'package:shaadi_hub/features/auth/controllers/auth_controller.dart';
import 'package:shaadi_hub/features/vendor_registration/controllers/vendor_registration_controller.dart';
import 'package:shaadi_hub/utils/helper/storage_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageHelper.init();
  });

  group('API Endpoints & GetX Controllers Test Suite', () {
    test('1. POST /api/auth/sign-up (Customer roleId: 2 & Vendor roleId: 3)', () async {
      final authController = AuthController();

      // Customer Sign-Up
      final customerRes = await authController.signUp(
        fullName: 'Priya Sharma',
        email: 'priya.sharma@gmail.com',
        phone: '+919876543210',
        password: 'Password123',
        roleId: 2,
      );

      expect(customerRes.isSuccess, isTrue);
      expect(customerRes.data?.roleId, equals(2));

      // Vendor Sign-Up
      final vendorRes = await authController.signUp(
        fullName: 'Aman Verma',
        email: 'contact@royalclick.com',
        phone: '+919876543210',
        password: 'Password123',
        roleId: 3,
      );

      expect(vendorRes.isSuccess, isTrue);
      expect(vendorRes.data?.roleId, equals(3));
    });

    test('2. POST /api/auth/verify-otp (Verify OTP for Customer & Vendor)', () async {
      final authController = AuthController();

      // Verify Customer OTP
      final verifyCustomerRes = await authController.verifyOtp(
        identifier: 'priya.sharma@gmail.com',
        otp: 1234,
        roleId: 2,
        name: 'Priya Sharma',
      );

      expect(verifyCustomerRes.isSuccess, isTrue);
      expect(verifyCustomerRes.data?.accessToken ?? verifyCustomerRes.data?.token, isNotNull);
      expect(verifyCustomerRes.data?.isVerified, isTrue);
      expect(StorageHelper().getAccessToken(), isNotNull);
      expect(StorageHelper().getIsLoggedIn(), isTrue);

      // Verify Vendor OTP
      final verifyVendorRes = await authController.verifyOtp(
        identifier: 'contact@royalclick.com',
        otp: 1234,
        roleId: 3,
        name: 'Royal Click Studio',
      );

      expect(verifyVendorRes.isSuccess, isTrue);
      expect(verifyVendorRes.data?.roleId, equals(3));
    });

    test('3. POST /api/auth/resend-otp (Resends OTP)', () async {
      final authController = AuthController();

      final resendRes = await authController.resendOtp(
        identifier: 'priya.sharma@gmail.com',
      );

      expect(resendRes.isSuccess, isTrue);
    });

    test('4. GET /api/category/list (Fetches Admin Categories)', () async {
      final categoryProvider = CategoryApiProvider();
      final res = await categoryProvider.getCategoryList();

      expect(res.isSuccess, isTrue);
      expect(res.data, isNotEmpty);
    });

    test('5. GET /api/subscription/list (Fetches Admin Subscription Packages)', () async {
      final subscriptionProvider = SubscriptionApiProvider();
      final res = await subscriptionProvider.getSubscriptionList();

      expect(res.isSuccess, isTrue);
      expect(res.data, isNotEmpty);
    });

    test('6. POST /api/users/vendor/application/submit (Submits Vendor Application)', () async {
      final vendorController = VendorRegistrationController();

      final res = await vendorController.submitApplication(
        ownerName: 'Aman Verma',
        businessName: 'Royal Click Studio',
        yearsOfExperience: '5+ Years',
        businessDescription: 'Award-winning wedding studio in Chandigarh...',
        businessAddress: 'SCO 142, Sector 70, Mohali, Punjab',
        city: 'Mohali',
        gstNumber: '03AABCR1234F1Z8',
        categoryId: '6701a2b3c4d5e6f7',
        subscriptionPlanId: '6702b3c4d5e6f7a8',
      );

      expect(res.isSuccess, isTrue);
    });

    test('7. GET /api/users/vendor/application/status (Tracks Real-time Status)', () async {
      final vendorController = VendorRegistrationController();
      final res = await vendorController.fetchApplicationStatus();

      expect(res.isSuccess, isTrue);
    });

    test('8. POST /api/auth/login (Authenticates User or Vendor)', () async {
      final authController = AuthController();

      // Vendor Login
      final vendorLoginRes = await authController.login(
        identifier: 'contact@royalclick.com',
        password: 'Password123',
      );

      expect(vendorLoginRes.isSuccess, isTrue);
      expect(StorageHelper().getAccessToken(), isNotNull);

      // Customer Login
      final customerLoginRes = await authController.login(
        identifier: 'priya.sharma@gmail.com',
        password: 'Password123',
      );

      expect(customerLoginRes.isSuccess, isTrue);
      expect(customerLoginRes.data?.roleId, equals(2));
    });
  });
}

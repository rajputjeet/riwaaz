const bool isProdMode = false;

abstract class ApiConstants {
  static const String _prodUrl = "http://192.168.1.8:5174";
  static const String _localUrl = "http://192.168.1.8:5174";

  static const String baseUrl = isProdMode ? _prodUrl : _localUrl;

  // 1. Auth APIs
  static const String signUp = "/api/auth/sign-up";
  static const String verifyOtp = "/api/auth/verify-otp";
  static const String resendOtp = "/api/auth/resend-otp";
  static const String logIn = "/api/auth/login";

  // 2. Category APIs
  static const String categoryList = "/api/category/list";

  // 3. Subscription Partner Plans APIs
  static const String subscriptionList = "/api/subscription/list";

  // 4. Vendor Application APIs
  static const String vendorApplicationSubmit =
      "/api/users/vendor/application/submit";
  static const String vendorApplicationStatus =
      "/api/users/vendor/application/status";
}

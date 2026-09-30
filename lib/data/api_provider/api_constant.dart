const bool isProdMode = false;

abstract class ApiConstants {
  static const String _prodUrl = "https://wedora-pgc7.onrender.com";
  static const String _localUrl = "http://192.168.1.100:5174";

  static const String baseUrl = isProdMode ? _prodUrl : _localUrl;

  // 1. Auth APIs
  static const String signUp = "/api/auth/sign-up";
  static const String verifyOtp = "/api/auth/verify-otp";
  static const String resendOtp = "/api/auth/resend-otp";
  static const String logIn = "/api/auth/login";
  static const String forgotPassword = "/api/auth/forgot-password";
  static const String refreshToken = "/api/auth/refresh-token";
  static const String logout = "/api/auth/logout";

  // 2. Category APIs
  static const String categoryList = "/api/category/list";

  // 3. Subscription Partner Plans APIs
  static const String subscriptionList = "/api/subscription/list";

  // 4. Vendor Application APIs
  static const String vendorApplicationSubmit =
      "/api/users/vendor/application/submit";
  static const String vendorApplicationStatus =
      "/api/users/vendor/application/status";

  // 5. User Profile APIs
  static const String userProfile = "/api/users/profile";
  static const String editProfile = "/api/users/edit-profile";
  static const String changePassword = "/api/users/change-password";
  static const String deleteAccount = "/api/users/delete-account";

  // 6. Vendor Subscription Plan APIs
  static const String vendorActivePlan = "/api/users/vendor/plan/active";
  static const String vendorBuyPlan = "/api/users/vendor/plan/buy";

  // 7. Vendor Portfolio APIs
  static const String vendorPortfolioAdd = "/api/users/vendor/portfolio/add";
  static String vendorPortfolioEdit(String id) =>
      "/api/users/vendor/portfolio/edit/$id";
  static String vendorPortfolioDelete(String id) =>
      "/api/users/vendor/portfolio/delete/$id";

  // 8. Vendor Package APIs
  static const String vendorPackageAdd = "/api/users/vendor/package/add";
  static String vendorPackageEdit(String id) =>
      "/api/users/vendor/package/edit/$id";
  static String vendorPackageDelete(String id) =>
      "/api/users/vendor/package/delete/$id";

  // 9. Vendor Service APIs
  static const String vendorServiceAdd = "/api/users/vendor/service/add";
  static String vendorServiceEdit(String id) =>
      "/api/users/vendor/service/edit/$id";
  static String vendorServiceDelete(String id) =>
      "/api/users/vendor/service/delete/$id";

  // 10. Vendor Bookings APIs
  static const String vendorBookingsList = "/api/booking/list";
  static String vendorUpdateBookingStatus(String bookingId) =>
      "/api/users/vendor/booking/status/$bookingId";

  // 11. Vendor Dashboard Stats API
  static const String vendorDashboardStats =
      "/api/users/vendor/dashboard-stats";

  // 12. FAQ & CMS APIs
  static const String faqList = "/api/faq/list";
  static const String cmsList = "/api/cms/list";
  static String cmsData(String type) => "/api/cms/data/$type";
}

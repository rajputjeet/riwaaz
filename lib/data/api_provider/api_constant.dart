const bool isProdMode = true;

abstract class ApiConstants {
  static const String _prodUrl = "https://widoora.com";
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
  static const String savedVendors = "/api/users/wishlist";
  static String toggleSavedVendor(String vendorId) =>
      "/api/users/wishlist/toggle/$vendorId";
  static const String clearSavedVendors = "/api/users/wishlist/clear";

  // 6. Vendor Subscription Plan APIs
  static const String vendorActivePlan = "/api/users/vendor/plan/active";
  static const String vendorActivePlanAlt = "/api/user/vendor/plan/active";
  static const String vendorBuyPlan = "/api/users/vendor/plan/buy";
  static const String vendorBuyPlanAlt = "/api/user/vendor/plan/buy";
  static const String vendorCoupons = "/api/vendor/coupons";
  static const String vendorCouponApply = "/api/vendor/coupon/apply";
  static const String discountCoupons = "/api/discount/coupons";
  static const String discountValidate = "/api/discount/validate";

  // 7. Vendor Portfolio APIs
  static const String vendorPortfolioAdd = "/api/users/vendor/portfolio/add";
  static String vendorPortfolioEdit(String id) =>
      "/api/users/vendor/portfolio/edit/$id";
  static String vendorPortfolioDelete(String id) =>
      "/api/users/vendor/portfolio/delete/$id";

  // 8. Vendor Services & Packages Unified APIs
  static const String vendorServicePackageAdd =
      "/api/users/vendor/service-package/add";
  static String vendorServicePackageEdit(String id) =>
      "/api/users/vendor/service-package/edit/$id";
  static String vendorServicePackageDelete(String id) =>
      "/api/users/vendor/service-package/delete/$id";
  static const String vendorServicePackageList =
      "/api/users/vendor/service-package/list";

  // Backward compatibility aliases
  static const String vendorPackageAdd = vendorServicePackageAdd;
  static String vendorPackageEdit(String id) => vendorServicePackageEdit(id);
  static String vendorPackageDelete(String id) =>
      vendorServicePackageDelete(id);

  // 9. Vendor Service APIs (Aliases to unified)
  static const String vendorServiceAdd = vendorServicePackageAdd;
  static String vendorServiceEdit(String id) => vendorServicePackageEdit(id);
  static String vendorServiceDelete(String id) =>
      vendorServicePackageDelete(id);

  // 10. Bookings APIs (Customer & Vendor)
  static const String bookingCreate = "/api/booking/create";
  static const String bookingList = "/api/booking/list";
  static String bookingDetail(String bookingId) => "/api/booking/$bookingId";
  static String bookingCancel(String bookingId) =>
      "/api/booking/cancel/$bookingId";
  static String bookingUpdateStatus(String bookingId) =>
      "/api/booking/status/$bookingId";
  static const String vendorBookingsList = "/api/booking/list";
  static String vendorUpdateBookingStatus(String bookingId) =>
      bookingUpdateStatus(bookingId);

  // 11. Vendor Dashboard Stats API
  static const String vendorDashboardStats =
      "/api/users/vendor/dashboard-stats";

  // 12. FAQ & CMS APIs
  static const String faqList = "/api/faq/list";
  static const String cmsList = "/api/cms/list";
  static String cmsData(String type) => "/api/cms/data/$type";

  // 13. System Settings API
  static const String settingCheck = "/api/setting/check";

  // 14. Ads & Vendor Sponsored Ads APIs
  static const String adList = "/api/ad/list";
  static const String adBuy = "/api/ad/buy";
  static const String adMyAd = "/api/ad/my-ad";
  static const String adActiveVendors = "/api/ad/active-vendors";
  static const String adUploadBanner = "/api/ad/upload-banner";
  static const String adRunningAds = "/api/ad/running-ads";
  static const String bannerList = "/api/banner/list";

  // 15. Public & Verified Vendors Discovery API
  static const String vendorList = "/api/vendor/list";
  static String vendorDetail(String id) => "/api/vendor/detail/$id";
  static const String vendorListAll = "/api/users/vendors";

  // 16. Customer & Vendor Notifications APIs
  static const String notificationsList = "/api/notifications/list";
  static String notificationView(String id) => "/api/notifications/view/$id";
  static String notificationRead(String id) => "/api/notifications/read/$id";
  static const String notificationsReadAll = "/api/notifications/read-all";
  static String notificationDelete(String id) => "/api/notifications/$id";
  static const String notificationsDeleteMultiple =
      "/api/notifications/delete-multiple";
  static const String notificationsDeleteAll = "/api/notifications/delete-all";
}

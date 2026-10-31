import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/setting_model.dart';

class StorageHelper {
  static SharedPreferences? _prefsInstance;

  static const String _accessToken = "accessToken";
  static const String _refreshToken = "refreshToken";
  static const String _userId = "userId";
  static const String _roleId = "roleId";
  static const String _isVerified = "isVerified";
  static const String _isLoggedIn = "isLoggedIn";
  static const String _userEmail = "userEmail";
  static const String _userMobile = "userMobile";
  static const String _userName = "userName";
  static const String _userProfileImg = "userProfileImg";
  static const String _vendorBannerImg = "vendorBannerImg";
  static const String _applicationId = "applicationId";
  static const String _applicationStatus = "applicationStatus";
  static const String _userModel = "userModel";
  static const String _vendorDraft = "vendorDraft";
  static const String _weddingDate = "weddingDate";
  static const String _weddingLocation = "weddingLocation";
  static const String _weddingEvents = "weddingEvents";
  static const String _userAddress = "userAddress";
  static const String _userCity = "userCity";
  static const String _userState = "userState";
  static const String _userPincode = "userPincode";
  static const String _userAbout = "userAbout";
  static const String _appSettings = "appSettings";
  static const String _contactEmail = "setting_contactEmail";
  static const String _contactPhone = "setting_contactPhone";
  static const String _instagramUrl = "setting_instagram";
  static const String _googleUrl = "setting_google";
  static const String _facebookUrl = "setting_facebook";
  static const String _copyrightText = "setting_copyright";
  static const String _vendorOnboardingCompleted = "vendorOnboardingCompleted";
  static const String _fcmToken = "fcmToken";
  static const String _fcmDeviceId = "fcmDeviceId";

  static final StorageHelper _singleton = StorageHelper._internal();

  StorageHelper._internal();

  factory StorageHelper() => _singleton;

  static Future<void> init() async {
    try {
      _prefsInstance = await SharedPreferences.getInstance();
    } catch (_) {}
  }

  Future<void> _savePref(String key, Object? value) async {
    if (_prefsInstance == null) await init();
    if (_prefsInstance == null) return;

    if (value == null) {
      await _prefsInstance!.remove(key);
      return;
    }
    if (value is bool) {
      await _prefsInstance!.setBool(key, value);
    } else if (value is int) {
      await _prefsInstance!.setInt(key, value);
    } else if (value is String) {
      await _prefsInstance!.setString(key, value);
    } else if (value is double) {
      await _prefsInstance!.setDouble(key, value);
    }
  }

  // ── Tokens ─────────────────────────────────────────────────────────────────

  /// Primary bearer token (accessToken from server)
  Future<void> saveAccessToken(String? token) async =>
      _savePref(_accessToken, token);
  String? getAccessToken() => _prefsInstance?.getString(_accessToken);

  /// Kept for backwards compatibility — delegates to accessToken
  Future<void> saveUserToken(String? token) => saveAccessToken(token);
  String? getUserToken() => getAccessToken();

  /// Refresh token — use to silently renew the accessToken
  Future<void> saveRefreshToken(String? token) async =>
      _savePref(_refreshToken, token);
  String? getRefreshToken() => _prefsInstance?.getString(_refreshToken);

  // ── Identity ───────────────────────────────────────────────────────────────

  Future<void> saveUserId(String? id) async => _savePref(_userId, id);
  String? getUserId() => _prefsInstance?.getString(_userId);

  /// 2 = Customer, 3 = Vendor Partner
  Future<void> saveRoleId(int? roleId) async => _savePref(_roleId, roleId);
  int? getRoleId() => _prefsInstance?.getInt(_roleId);

  Future<void> saveIsVerified(bool? verified) async =>
      _savePref(_isVerified, verified);
  bool getIsVerified() => _prefsInstance?.getBool(_isVerified) ?? false;

  Future<void> saveIsLoggedIn(bool? loggedIn) async =>
      _savePref(_isLoggedIn, loggedIn);
  bool getIsLoggedIn() => _prefsInstance?.getBool(_isLoggedIn) ?? false;

  Future<void> saveFcmToken(String? token) async => _savePref(_fcmToken, token);
  String? getFcmToken() => _prefsInstance?.getString(_fcmToken);

  Future<void> saveFcmDeviceId(String? deviceId) async =>
      _savePref(_fcmDeviceId, deviceId);
  String? getFcmDeviceId() => _prefsInstance?.getString(_fcmDeviceId);

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<void> saveUserEmail(String? email) async =>
      _savePref(_userEmail, email);
  String? getUserEmail() => _prefsInstance?.getString(_userEmail);

  Future<void> saveUserMobile(String? mobile) async =>
      _savePref(_userMobile, mobile);
  String? getUserMobile() => _prefsInstance?.getString(_userMobile);

  Future<void> saveUserName(String? name) async => _savePref(_userName, name);
  String? getUserName() => _prefsInstance?.getString(_userName);

  Future<void> saveUserProfileImg(String? img) async => _savePref(
    _userProfileImg,
    (img != null && img.trim().isNotEmpty) ? img.trim() : null,
  );
  String? getUserProfileImg() {
    final img = _prefsInstance?.getString(_userProfileImg);
    return (img != null && img.trim().isNotEmpty) ? img.trim() : null;
  }

  Future<void> saveVendorBannerImg(String? img) async => _savePref(
    _vendorBannerImg,
    (img != null && img.trim().isNotEmpty) ? img.trim() : null,
  );
  String? getVendorBannerImg() {
    final img = _prefsInstance?.getString(_vendorBannerImg);
    return (img != null && img.trim().isNotEmpty) ? img.trim() : null;
  }

  Future<void> saveUserAddress(String? address) async =>
      _savePref(_userAddress, address);
  String? getUserAddress() => _prefsInstance?.getString(_userAddress);

  Future<void> saveUserCity(String? city) async => _savePref(_userCity, city);
  String? getUserCity() => _prefsInstance?.getString(_userCity);

  Future<void> saveUserState(String? state) async =>
      _savePref(_userState, state);
  String? getUserState() => _prefsInstance?.getString(_userState);

  Future<void> saveUserPincode(String? pincode) async =>
      _savePref(_userPincode, pincode);
  String? getUserPincode() => _prefsInstance?.getString(_userPincode);

  Future<void> saveUserAbout(String? about) async =>
      _savePref(_userAbout, about);
  String? getUserAbout() => _prefsInstance?.getString(_userAbout);

  // ── Vendor Application ─────────────────────────────────────────────────────

  Future<void> saveApplicationId(String? appId) async =>
      _savePref(_applicationId, appId);
  String? getApplicationId() => _prefsInstance?.getString(_applicationId);

  Future<void> saveApplicationStatus(String? status) async =>
      _savePref(_applicationStatus, status);
  String? getApplicationStatus() =>
      _prefsInstance?.getString(_applicationStatus);

  // ── Full User Snapshot ─────────────────────────────────────────────────────

  Future<void> saveUserModel(Map<String, dynamic>? model) async {
    if (model == null) {
      await _savePref(_userModel, null);
    } else {
      await _savePref(_userModel, jsonEncode(model));
    }
  }

  Map<String, dynamic>? getUserModel() {
    final raw = _prefsInstance?.getString(_userModel);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Vendor Onboarding Draft ────────────────────────────────────────────────
  Future<void> saveVendorDraft(Map<String, dynamic>? draft) async {
    if (draft == null) {
      await _savePref(_vendorDraft, null);
    } else {
      await _savePref(_vendorDraft, jsonEncode(draft));
    }
  }

  Map<String, dynamic>? getVendorDraft() {
    final raw = _prefsInstance?.getString(_vendorDraft);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearVendorDraft() async {
    if (_prefsInstance == null) return;
    await _prefsInstance!.remove(_vendorDraft);
  }

  Future<void> saveVendorOnboardingCompleted(bool? completed) async =>
      _savePref(_vendorOnboardingCompleted, completed);

  bool getVendorOnboardingCompleted() {
    final explicit = _prefsInstance?.getBool(_vendorOnboardingCompleted);
    if (explicit != null) return explicit;
    final draft = getVendorDraft();
    if (draft != null) return false;
    final status = getApplicationStatus();
    if (status != null &&
        status.isNotEmpty &&
        status != 'Pending' &&
        status != 'Draft' &&
        status != 'Under Review') {
      return true;
    }
    if (getIsVerified()) return true;
    return false;
  }

  // ── Wedding Details ────────────────────────────────────────────────────────
  Future<void> saveWeddingDate(String? date) async =>
      _savePref(_weddingDate, date);
  String? getWeddingDate() => _prefsInstance?.getString(_weddingDate);

  Future<void> saveWeddingLocation(String? loc) async =>
      _savePref(_weddingLocation, loc);
  String? getWeddingLocation() => _prefsInstance?.getString(_weddingLocation);

  Future<void> saveWeddingEvents(List<Map<String, dynamic>>? events) async {
    if (events == null) {
      await _savePref(_weddingEvents, null);
    } else {
      await _savePref(_weddingEvents, jsonEncode(events));
    }
  }

  List<Map<String, dynamic>>? getWeddingEvents() {
    final raw = _prefsInstance?.getString(_weddingEvents);
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  // ── Platform Settings & Support ───────────────────────────────────────────

  /// Save platform settings JSON and individual preferences
  Future<void> saveSettings(SettingModel? settings) async {
    if (settings == null) {
      await _savePref(_appSettings, null);
      return;
    }
    await _savePref(_appSettings, jsonEncode(settings.toJson()));
    if (settings.contactEmail != null) {
      await _savePref(_contactEmail, settings.contactEmail!.trim());
    }
    if (settings.contactPhone != null) {
      await _savePref(_contactPhone, settings.contactPhone!.trim());
    }
    if (settings.instagram != null) {
      await _savePref(_instagramUrl, settings.instagram!.trim());
    }
    if (settings.google != null) {
      await _savePref(_googleUrl, settings.google!.trim());
    }
    if (settings.facebook != null) {
      await _savePref(_facebookUrl, settings.facebook!.trim());
    }
    if (settings.copyright != null) {
      await _savePref(_copyrightText, settings.copyright!.trim());
    }
  }

  /// Get platform settings with fallback to default verified values
  SettingModel getSettings() {
    final raw = _prefsInstance?.getString(_appSettings);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return SettingModel.fromJson(map);
      } catch (_) {}
    }

    final phone = _prefsInstance?.getString(_contactPhone);
    final email = _prefsInstance?.getString(_contactEmail);
    final insta = _prefsInstance?.getString(_instagramUrl);
    final fb = _prefsInstance?.getString(_facebookUrl);
    final google = _prefsInstance?.getString(_googleUrl);
    final copyright = _prefsInstance?.getString(_copyrightText);

    if (phone != null || email != null || insta != null || fb != null) {
      return SettingModel(
        contactPhone: phone ?? SettingModel.defaultSettings.contactPhone,
        contactEmail: email ?? SettingModel.defaultSettings.contactEmail,
        instagram: insta ?? SettingModel.defaultSettings.instagram,
        facebook: fb ?? SettingModel.defaultSettings.facebook,
        google: google ?? SettingModel.defaultSettings.google,
        copyright: copyright ?? SettingModel.defaultSettings.copyright,
        happyCustomersCount: SettingModel.defaultSettings.happyCustomersCount,
        happyCustomersLabel: SettingModel.defaultSettings.happyCustomersLabel,
        locationsCount: SettingModel.defaultSettings.locationsCount,
        locationsLabel: SettingModel.defaultSettings.locationsLabel,
        eventVendorsCount: SettingModel.defaultSettings.eventVendorsCount,
        eventVendorsLabel: SettingModel.defaultSettings.eventVendorsLabel,
        eventServicesCount: SettingModel.defaultSettings.eventServicesCount,
        eventServicesLabel: SettingModel.defaultSettings.eventServicesLabel,
      );
    }

    return SettingModel.defaultSettings;
  }

  String getContactEmail() => getSettings().displayEmail;
  String getContactPhone() => getSettings().displayPhone;
  String getInstagramUrl() => getSettings().displayInstagram;
  String getFacebookUrl() => getSettings().displayFacebook;
  String getGoogleUrl() => getSettings().displayWebsite;
  String getCopyright() => getSettings().displayCopyright;
  String getHappyCustomersCount() =>
      getSettings().happyCustomersCount ?? '200+';
  String getLocationsCount() => getSettings().locationsCount ?? '50+';
  String getEventVendorsCount() => getSettings().eventVendorsCount ?? '100+';
  String getEventServicesCount() => getSettings().eventServicesCount ?? '50+';

  // ── Session & All Data Clear ──────────────────────────────────────────────

  /// Completely wipes ALL stored preferences and data from the device
  Future<void> clearAllData() async {
    if (_prefsInstance == null) await init();
    if (_prefsInstance != null) {
      await _prefsInstance!.clear();
    }
  }

  /// Alias for clearAllData — clears all stored data on logout
  Future<void> clearSession() async {
    await clearAllData();
  }
}

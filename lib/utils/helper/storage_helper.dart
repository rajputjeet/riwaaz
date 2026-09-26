import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static SharedPreferences? _prefsInstance;

  static const String _accessToken      = "accessToken";
  static const String _refreshToken     = "refreshToken";
  static const String _userId           = "userId";
  static const String _roleId           = "roleId";
  static const String _isVerified       = "isVerified";
  static const String _isLoggedIn       = "isLoggedIn";
  static const String _userEmail        = "userEmail";
  static const String _userMobile       = "userMobile";
  static const String _userName         = "userName";
  static const String _applicationId    = "applicationId";
  static const String _applicationStatus= "applicationStatus";
  static const String _userModel        = "userModel";

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

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<void> saveUserEmail(String? email) async =>
      _savePref(_userEmail, email);
  String? getUserEmail() => _prefsInstance?.getString(_userEmail);

  Future<void> saveUserMobile(String? mobile) async =>
      _savePref(_userMobile, mobile);
  String? getUserMobile() => _prefsInstance?.getString(_userMobile);

  Future<void> saveUserName(String? name) async => _savePref(_userName, name);
  String? getUserName() => _prefsInstance?.getString(_userName);

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

  // ── Session Clear ──────────────────────────────────────────────────────────

  Future<void> clearSession() async {
    if (_prefsInstance == null) return;
    await Future.wait([
      _prefsInstance!.remove(_accessToken),
      _prefsInstance!.remove(_refreshToken),
      _prefsInstance!.remove(_userId),
      _prefsInstance!.remove(_roleId),
      _prefsInstance!.remove(_isVerified),
      _prefsInstance!.remove(_isLoggedIn),
      _prefsInstance!.remove(_userModel),
      _prefsInstance!.remove(_applicationId),
      _prefsInstance!.remove(_applicationStatus),
    ]);
  }
}

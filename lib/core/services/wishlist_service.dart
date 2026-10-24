import 'package:flutter/foundation.dart';

import '../../data/api_provider/wishlist_api_provider.dart';
import '../../data/models/user_model.dart';

class WishlistService extends ChangeNotifier {
  WishlistService._();

  static final WishlistService instance = WishlistService._();

  final WishlistApiProvider _api = WishlistApiProvider();
  final Set<String> _savedVendorIds = <String>{};
  final Set<String> _pendingVendorIds = <String>{};
  final List<UserModel> _savedVendors = <UserModel>[];

  Future<bool>? _loadFuture;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  List<UserModel> get savedVendors => List.unmodifiable(_savedVendors);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  bool isSaved(String vendorId) => _savedVendorIds.contains(vendorId);

  bool isToggling(String vendorId) => _pendingVendorIds.contains(vendorId);

  Future<bool> ensureLoaded() {
    if (_hasLoaded) return Future.value(true);
    return refreshSavedVendors();
  }

  Future<bool> refreshSavedVendors() {
    final activeLoad = _loadFuture;
    if (activeLoad != null) return activeLoad;

    final load = _fetchSavedVendors();
    _loadFuture = load;
    return load.whenComplete(() => _loadFuture = null);
  }

  Future<bool> _fetchSavedVendors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.getSavedVendors();
    _isLoading = false;
    _hasLoaded = true;

    if (response.isSuccess == true && response.data != null) {
      _savedVendors
        ..clear()
        ..addAll(response.data!);
      _savedVendorIds
        ..clear()
        ..addAll(
          _savedVendors
              .map((vendor) => vendor.id ?? '')
              .where((id) => id.isNotEmpty),
        );
      notifyListeners();
      return true;
    }

    _error =
        response.message ?? response.error ?? 'Could not load saved vendors.';
    notifyListeners();
    return false;
  }

  Future<bool?> toggleVendor(String vendorId, {UserModel? vendor}) async {
    if (vendorId.isEmpty || _pendingVendorIds.contains(vendorId)) return null;

    await ensureLoaded();
    _pendingVendorIds.add(vendorId);
    notifyListeners();

    try {
      final response = await _api.toggleSavedVendor(vendorId);
      if (response.isSuccess != true) {
        _error =
            response.message ??
            response.error ??
            'Could not update saved vendors.';
        return null;
      }

      final saved = response.data ?? !_savedVendorIds.contains(vendorId);
      if (saved) {
        _savedVendorIds.add(vendorId);
        if (vendor != null &&
            !_savedVendors.any((savedVendor) => savedVendor.id == vendorId)) {
          _savedVendors.insert(0, vendor);
        }
      } else {
        _savedVendorIds.remove(vendorId);
        _savedVendors.removeWhere((savedVendor) => savedVendor.id == vendorId);
      }

      _error = null;
      notifyListeners();
      return saved;
    } finally {
      _pendingVendorIds.remove(vendorId);
      notifyListeners();
    }
  }

  Future<bool> clearAll() async {
    final response = await _api.clearSavedVendors();
    if (response.isSuccess != true) {
      _error =
          response.message ??
          response.error ??
          'Could not clear saved vendors.';
      notifyListeners();
      return false;
    }

    _savedVendorIds.clear();
    _savedVendors.clear();
    _hasLoaded = true;
    _error = null;
    notifyListeners();
    return true;
  }
}

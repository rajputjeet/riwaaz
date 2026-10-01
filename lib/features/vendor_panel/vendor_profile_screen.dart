import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import '../../data/api_provider/user_api_provider.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/active_plan_model.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/api_provider/cms_api_provider.dart';
import '../../data/api_provider/faq_api_provider.dart';
import '../../data/models/cms_model.dart';
import '../../data/models/faq_model.dart';
import '../../data/shared/data_response.dart';
import '../../shared/widgets/app_states.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../shared/widgets/app_html_content_view.dart';
import '../../shared/widgets/app_support_sheet.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';
import '../auth/controllers/auth_controller.dart';
import '../auth/unified_login_screen.dart';
import 'vendor_packages_screen.dart';
import 'vendor_portfolio_screen.dart';
import 'vendor_subscription_plan_screen.dart';
import 'vendor_edit_profile_screen.dart';
import 'vendor_verification_screen.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => VendorProfileScreenState();
}

class VendorProfileScreenState extends State<VendorProfileScreen> {
  final _userApi = UserApiProvider();
  final _vendorApi = VendorApiProvider();
  final _cmsApi = CmsApiProvider();
  final _faqApi = FaqApiProvider();

  UserModel? _profile;
  ActivePlanModel? _activePlan;
  DashboardStatsModel? _stats;
  bool _isLoading = true;
  bool _isNoInternet = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll({bool silent = false}) async {
    if (!mounted) return;
    if (!silent && _profile == null) {
      setState(() {
        _isLoading = true;
        _isNoInternet = false;
        _errorMsg = null;
      });
    } else {
      setState(() {});
    }
    try {
      final results = await Future.wait([
        _userApi.getProfile(),
        _vendorApi.getActivePlan(),
        _vendorApi.getDashboardStats(),
      ]);
      if (!mounted) return;
      setState(() {
        final profileRes = results[0];
        final planRes = results[1];
        final statsRes = results[2];
        if (profileRes.isSuccess == true) _profile = profileRes.data as UserModel?;
        if (planRes.isSuccess == true) _activePlan = planRes.data as ActivePlanModel?;
        if (statsRes.isSuccess == true) _stats = statsRes.data as DashboardStatsModel?;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final isNet = e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('network');
      setState(() {
        if (_profile == null) {
          _isNoInternet = isNet;
          _errorMsg = isNet ? null : 'Could not load profile. Please try again.';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAll() => loadAll();

  String get _displayName {
    final biz = _profile?.vendorProfile?.businessName;
    if (biz != null && biz.trim().isNotEmpty) return biz.trim();
    if (_profile?.fullName?.trim().isNotEmpty == true) return _profile!.fullName!.trim();
    final stored = StorageHelper().getUserName();
    if (stored?.trim().isNotEmpty == true) return stored!.trim();
    return 'Vendor Partner';
  }

  String get _displayEmail => _profile?.email ?? StorageHelper().getUserEmail() ?? '';
  String get _displayMobile => _profile?.mobile ?? StorageHelper().getUserMobile() ?? '';

  String get _appStatus {
    final s = _stats?.applicationStatus ??
        _profile?.vendorProfile?.applicationStatus ??
        StorageHelper().getApplicationStatus() ?? '';
    return s.isEmpty ? 'Pending' : s;
  }

  bool get _isVerifiedVendor => StorageHelper().getIsVerified();

  String get _planSubtitle {
    if (_activePlan == null) return 'No active plan • View plans';
    final plan = _activePlan!;
    if (plan.isExpired) return 'Plan expired • Renew now';
    return '${plan.planTitle ?? 'Active Plan'} • ${plan.daysRemaining} days left';
  }

  String get _packagesSubtitle {
    final count = _stats?.portfolioStats.totalPackages ?? 0;
    return count == 0 ? 'No packages yet' : '$count package${count == 1 ? '' : 's'} active';
  }

  String get _portfolioSubtitle {
    final count = _stats?.portfolioStats.totalPortfolioItems ?? 0;
    return count == 0 ? 'No media uploaded yet' : '$count media item${count == 1 ? '' : 's'}';
  }

  String get _verificationSubtitle {
    if (_isVerifiedVendor) return 'Documents approved ✓';
    final s = _appStatus.toLowerCase().trim();
    if (s == 'approved' || s == 'active') {
      return 'Documents approved ✓';
    } else if (s == 'under review' || s == 'under_review' || s == 'in verification' || s == 'submitted') {
      return 'Under admin review...';
    } else if (s == 'rejected' || s == 'declined') {
      return 'Application rejected — resubmit';
    }
    return 'Pending verification';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Business Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                FadeScaleRoute(
                  page: const VendorEditProfileScreen(),
                ),
              );
              if (updated == true || mounted) {
                _loadAll();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadAll,
        child: _isLoading
            ? const AppLoadingState(message: 'Loading your profile...')
            : _isNoInternet
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: AppNoInternetState(onRetry: _loadAll),
                    ),
                  )
                : _errorMsg != null
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: AppErrorState(message: _errorMsg!, onRetry: _loadAll),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          children: [
                            // ── Vendor Profile Header Card ──────────────────
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.gold, width: 2),
                                        ),
                                        child: ClipOval(
                                          child: ((_profile?.profileImgUrl != null && _profile!.profileImgUrl!.isNotEmpty) ||
                                                  (StorageHelper().getUserProfileImg() != null && StorageHelper().getUserProfileImg()!.isNotEmpty))
                                              ? CachedImageView(
                                                  imageUrl: StorageHelper().getUserProfileImg() ?? _profile?.profileImgUrl ?? '',
                                                  fit: BoxFit.cover,
                                                  width: 80,
                                                  height: 80,
                                                  isCircle: true,
                                                  fallbackIcon: Icons.storefront_rounded,
                                                )
                                              : CircleAvatar(
                                                  radius: 40,
                                                  backgroundColor: AppColors.primary,
                                                  child: Text(
                                                    _displayName.isNotEmpty
                                                        ? _displayName[0].toUpperCase()
                                                        : 'V',
                                                    style: const TextStyle(
                                                      fontSize: 30,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      if (_isVerifiedVendor)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AppColors.success,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                                Icons.verified_rounded,
                                                color: AppColors.white,
                                                size: 16),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _displayName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  if (_displayEmail.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _displayEmail,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ],
                                  if (_displayMobile.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _displayMobile,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  _buildStatusBadge(_appStatus),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final updated = await Navigator.of(context).push<bool>(
                                        FadeScaleRoute(page: const VendorEditProfileScreen()),
                                      );
                                      if (updated == true || mounted) {
                                        _loadAll();
                                      }
                                    },
                                    icon: const Icon(Icons.edit_rounded, size: 14),
                                    label: const Text('Edit Profile'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'BUSINESS MANAGEMENT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildMenuItem(
                              icon: Icons.verified_user_outlined,
                              title: 'Verification Status',
                              subtitle: _verificationSubtitle,
                              onTap: () => Navigator.of(context).push(
                                FadeScaleRoute(page: const VendorVerificationScreen()),
                              ),
                            ),
                            _buildMenuItem(
                              icon: Icons.workspace_premium_rounded,
                              iconColor: AppColors.goldDark,
                              title: 'Vendor Membership Plans',
                              subtitle: _planSubtitle,
                              onTap: () => Navigator.of(context).push(
                                FadeScaleRoute(page: const VendorSubscriptionPlanScreen()),
                              ),
                            ),
                            _buildMenuItem(
                              icon: Icons.inventory_2_outlined,
                              title: 'My Pricing Packages',
                              subtitle: _packagesSubtitle,
                              onTap: () => Navigator.of(context).push(
                                FadeScaleRoute(page: const VendorPackagesScreen()),
                              ),
                            ),
                            _buildMenuItem(
                              icon: Icons.photo_library_outlined,
                              title: 'Portfolio & Media',
                              subtitle: _portfolioSubtitle,
                              onTap: () => Navigator.of(context).push(
                                FadeScaleRoute(page: const VendorPortfolioScreen()),
                              ),
                            ),

                            const SizedBox(height: 18),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'LEGAL & POLICIES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildMenuItem(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'Platform privacy & data protection',
                              onTap: () => _showPrivacyPolicySheet(context),
                            ),
                            _buildMenuItem(
                              icon: Icons.assignment_return_outlined,
                              title: 'Cancellation Policy',
                              subtitle: 'Booking cancellation & refund guidelines',
                              onTap: () => _showCancellationPolicySheet(context),
                            ),
                            _buildMenuItem(
                              icon: Icons.gavel_rounded,
                              title: 'Terms of Service',
                              subtitle: 'Platform terms & service agreement',
                              onTap: () => _showTermsOfServiceSheet(context),
                            ),
                            _buildMenuItem(
                              icon: Icons.help_outline_rounded,
                              title: 'FAQs',
                              subtitle: 'Frequently asked questions & help',
                              onTap: () => _showVendorFaqSheet(context),
                            ),
                            _buildMenuItem(
                              icon: Icons.headset_mic_rounded,
                              title: 'Help & Support',
                              subtitle: 'Direct Call & WhatsApp assistance',
                              onTap: () => _showSupportSheet(context),
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () => _showLogoutDialog(context),
                                icon: const Icon(Icons.logout_rounded,
                                    color: AppColors.primary, size: 18),
                                label: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Center(
                              child: TextButton.icon(
                                onPressed: () => _showDeleteAccountDialog(context),
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.red, size: 16),
                                label: const Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Widoora Vendor Partner v1.0.4 • Direct Celebrations Marketplace',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg, fg;
    IconData ic;
    final s = status.toLowerCase().trim();
    if (s == 'approved' || s == 'active') {
      bg = AppColors.successLight;
      fg = AppColors.success;
      ic = Icons.verified_rounded;
    } else if (s == 'under review' || s == 'under_review' || s == 'in verification' || s == 'submitted') {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFF57C00);
      ic = Icons.hourglass_top_rounded;
    } else if (s == 'rejected' || s == 'declined') {
      bg = const Color(0xFFFFEBEE);
      fg = AppColors.error;
      ic = Icons.cancel_rounded;
    } else {
      bg = const Color(0xFFF5F5F5);
      fg = AppColors.grey;
      ic = Icons.pending_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            status.isEmpty ? 'Pending' : status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }


  void _showPrivacyPolicySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(Icons.privacy_tip_rounded,
                          color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
                ),
              ],
            ),
            const Text(
              'Official Platform Privacy Policy & Data Protection',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<CmsModel>>(
                future: _cmsApi.getCmsData('privacy'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(message: 'Loading Privacy Policy...');
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final response = snapshot.data;
                  final content = response?.data?.description ?? '';
                  if (response?.isSuccess != true && content.isEmpty) {
                    return AppErrorState(
                      message: response?.message ?? 'Could not load Privacy Policy.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy Pending',
                      subtitle: 'The privacy terms will appear here once published by admin.',
                    );
                  }
                  return AppHtmlContentView(htmlContent: content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsOfServiceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(Icons.gavel_rounded,
                          color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
                ),
              ],
            ),
            const Text(
              'Official Platform Agreement & Service Terms',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<CmsModel>>(
                future: _cmsApi.getCmsData('terms'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(message: 'Loading Terms of Service...');
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final response = snapshot.data;
                  final content = response?.data?.description ?? '';
                  if (response?.isSuccess != true && content.isEmpty) {
                    return AppErrorState(
                      message: response?.message ?? 'Could not load Terms of Service.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.gavel_rounded,
                      title: 'Terms of Service Pending',
                      subtitle: 'The terms and conditions will appear here once published by admin.',
                    );
                  }
                  return AppHtmlContentView(htmlContent: content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancellationPolicySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(Icons.assignment_return_outlined,
                          color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Cancellation Policy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
                ),
              ],
            ),
            const Text(
              'Official Booking Cancellation & Direct Refund Guidelines',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<CmsModel>>(
                future: _cmsApi.getCmsData('refund'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(message: 'Loading Cancellation Policy...');
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final response = snapshot.data;
                  final content = response?.data?.description ?? '';
                  if (response?.isSuccess != true && content.isEmpty) {
                    return AppErrorState(
                      message: response?.message ?? 'Could not load Cancellation Policy.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.assignment_return_outlined,
                      title: 'Cancellation Policy Pending',
                      subtitle: 'The cancellation policy will appear here once published by admin.',
                    );
                  }
                  return AppHtmlContentView(htmlContent: content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    AppSupportSheet.show(
      context,
      isVendor: true,
      onOpenFaq: () => _showVendorFaqSheet(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsOverflowButtonSpacing: 8,
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your vendor account? You can sign back in anytime.',
          style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await StorageHelper().clearSession();
              if (Get.isRegistered<AuthController>()) {
                await Get.find<AuthController>().logout();
              }
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                FadeScaleRoute(page: const UnifiedLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsOverflowButtonSpacing: 8,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action is irreversible. All your vendor data will be permanently erased:',
              style: TextStyle(fontSize: 13, color: AppColors.black),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('• Business profile, verified badge & reviews',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Portfolio photos, media & service packages',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Active vendor membership plan & remaining days',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Client booking records & incoming requests',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to permanently delete your vendor account?',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Account',
                style: TextStyle(color: AppColors.darkGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Utils.showSuccess('Your vendor account has been deleted successfully.');
              Navigator.of(context).pushAndRemoveUntil(
                FadeScaleRoute(page: const UnifiedLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor ?? AppColors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.grey),
      ),
    );
  }

  void _showVendorFaqSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.help_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'FAQs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
                ),
              ],
            ),
            const Text(
              'Frequently Asked Questions & Answers',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<List<FaqModel>>>(
                future: _faqApi.getFaqList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(message: 'Loading FAQs...');
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final response = snapshot.data;
                  if (response == null || response.isSuccess != true) {
                    return AppErrorState(
                      message: response?.message ?? 'Could not load FAQs from server.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final faqs = response.data ?? [];
                  if (faqs.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.help_outline_rounded,
                      title: 'No FAQs Available',
                      subtitle: 'Frequently asked questions will appear here shortly.',
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: faqs.length,
                    itemBuilder: (context, i) {
                      final faq = faqs[i];
                      return _VendorFaqTile(
                        question: faq.question ?? 'FAQ',
                        answer: faq.answer ?? '',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expandable FAQ tile for vendor profile
class _VendorFaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _VendorFaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.grey,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.darkGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

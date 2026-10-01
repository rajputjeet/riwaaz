import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/booking_service.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import '../vendor_registration/controllers/vendor_registration_controller.dart';
import 'vendor_dashboard_tab.dart';
import 'vendor_bookings_tab.dart';
import 'vendor_profile_screen.dart';
import 'vendor_notifications_screen.dart';
import 'vendor_verification_screen.dart';

class VendorShell extends StatefulWidget {
  final int initialIndex;
  const VendorShell({super.key, this.initialIndex = 0});

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  late int _currentIndex;
  bool _showApprovalWarning = true;
  final _profileKey = GlobalKey<VendorProfileScreenState>();
  late final VendorRegistrationController _regController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _regController = Get.isRegistered<VendorRegistrationController>()
        ? Get.find<VendorRegistrationController>()
        : Get.put(VendorRegistrationController());
    _regController.fetchApplicationStatus();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 2) {
      _profileKey.currentState?.loadAll(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.diamond_rounded,
                  color: AppColors.white, size: 14),
            ),
            const SizedBox(width: 6),
            const Text(
              'WIDOORA VENDOR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Notifications bell with red badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.black, size: 22),
                onPressed: () {
                  Navigator.of(context).push(
                    FadeScaleRoute(
                      page: const VendorNotificationsScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          VendorDashboardTab(onNavigateTab: (idx) => _onTabTap(idx)),
          const VendorBookingsTab(key: ValueKey('vendor_bookings_tab_v2')),
          VendorProfileScreen(key: _profileKey),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showApprovalWarning) _buildApprovalWarningSnackBar(),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            elevation: 12,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: ListenableBuilder(
                  listenable: AppBookingService.instance,
                  builder: (context, _) {
                    final pending = AppBookingService.instance.pendingCount;
                    if (pending > 0) {
                      return Badge(
                        label: Text('$pending'),
                        backgroundColor: const Color(0xFFD97706),
                        child: const Icon(Icons.calendar_month_rounded),
                      );
                    }
                    return const Icon(Icons.calendar_month_rounded);
                  },
                ),
                label: 'Bookings',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalWarningSnackBar() {
    if (!_showApprovalWarning) return const SizedBox.shrink();

    return Obx(() {
      final appStatus = _regController.currentStatus.value.trim();
      final isVerified = _regController.isVerified.value || StorageHelper().getIsVerified();
      final normalized = appStatus.toLowerCase();
      final isApproved = isVerified || normalized == 'approved' || normalized == 'active';
      final isRejected = normalized == 'rejected' || normalized == 'declined';
      final isUnderReview = normalized == 'under review' ||
          normalized == 'under_review' ||
          normalized == 'in verification' ||
          normalized == 'submitted';

      // If approved or verified, do not show warning banner
      if (isApproved) {
        return const SizedBox.shrink();
      }

      final Color borderColor;
      final Color iconBgColor;
      final Color iconColor;
      final Color badgeBgColor;
      final Color badgeTextColor;
      final Color titleColor;
      final String title;
      final String badgeText;
      final String subtitle;
      final IconData iconData;
      final List<Color> gradientColors;

      if (isRejected) {
        borderColor = AppColors.error.withValues(alpha: 0.6);
        iconBgColor = AppColors.error.withValues(alpha: 0.2);
        iconColor = const Color(0xFFEF5350);
        badgeBgColor = AppColors.error.withValues(alpha: 0.25);
        badgeTextColor = const Color(0xFFEF5350);
        titleColor = const Color(0xFFFFCDD2);
        title = 'Verification Action Required';
        badgeText = 'DECLINED';
        subtitle = 'Your verification needs updates. Tap to review & resubmit.';
        iconData = Icons.error_outline_rounded;
        gradientColors = const [Color(0xFF330C12), Color(0xFF1F050A)];
      } else if (isUnderReview) {
        borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.5);
        iconBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.18);
        iconColor = const Color(0xFFFBBF24);
        badgeBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.25);
        badgeTextColor = const Color(0xFFFBBF24);
        titleColor = const Color(0xFFFDE68A);
        title = 'Profile Under Review';
        badgeText = 'IN REVIEW';
        subtitle = 'Documents are being verified by admin. Features unlock upon approval.';
        iconData = Icons.hourglass_top_rounded;
        gradientColors = const [Color(0xFF26180B), Color(0xFF1A1108)];
      } else {
        borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.5);
        iconBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.18);
        iconColor = const Color(0xFFFBBF24);
        badgeBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.25);
        badgeTextColor = const Color(0xFFFBBF24);
        titleColor = const Color(0xFFFDE68A);
        title = 'Verification Incomplete';
        badgeText = 'PENDING';
        subtitle = 'Please upload all 4 KYC documents to unlock your vendor account.';
        iconData = Icons.pending_actions_rounded;
        gradientColors = const [Color(0xFF26180B), Color(0xFF1A1108)];
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(context).push(
                FadeScaleRoute(page: const VendorVerificationScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: badgeTextColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFF3F4F6),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _showApprovalWarning = false;
                      });
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFFD1D5DB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}


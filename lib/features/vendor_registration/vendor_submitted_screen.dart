import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';
import '../vendor_panel/vendor_shell.dart';
import 'controllers/vendor_registration_controller.dart';
import 'vendor_verification_tracker_screen.dart';

class VendorSubmittedScreen extends StatefulWidget {
  final String businessName;
  final String businessType;
  final String ownerName;
  final String? applicationId;

  const VendorSubmittedScreen({
    super.key,
    this.businessName = 'Royal Click Studio',
    this.businessType = 'Photography',
    this.ownerName = 'Partner',
    this.applicationId,
  });

  @override
  State<VendorSubmittedScreen> createState() => _VendorSubmittedScreenState();
}

class _VendorSubmittedScreenState extends State<VendorSubmittedScreen> {
  late final VendorRegistrationController _controller;
  Timer? _redirectTimer;
  int _secondsRemaining = 5;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<VendorRegistrationController>()
        ? Get.find<VendorRegistrationController>()
        : Get.put(VendorRegistrationController());
    _controller.fetchApplicationStatus();
    _startRedirectTimer();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Restart timer on hot reload so live testing always ticks down
    if (!_hasNavigated) {
      _startRedirectTimer();
    }
  }

  void _startRedirectTimer() {
    _redirectTimer?.cancel();
    _secondsRemaining = 5;
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _redirectTimer = null;
        setState(() {
          _secondsRemaining = 0;
        });
        _navigateToPortfolio();
      }
    });
  }

  void _navigateToPortfolio() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _redirectTimer?.cancel();
    _redirectTimer = null;

    Navigator.of(context).pushAndRemoveUntil(
      FadeScaleRoute(
        page: const VendorShell(initialIndex: 2),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _redirectTimer = null;
    super.dispose();
  }

  String get _effectiveApplicationId {
    final liveAppId = _controller.applicationData.value?.applicationId;
    if (liveAppId != null && liveAppId.trim().isNotEmpty) return liveAppId.trim();
    if (widget.applicationId != null &&
        widget.applicationId!.trim().isNotEmpty &&
        widget.applicationId != 'WDV12345678') {
      return widget.applicationId!.trim();
    }
    final savedId = StorageHelper().getApplicationId();
    if (savedId != null && savedId.trim().isNotEmpty && savedId != 'WDV12345678') {
      return savedId.trim();
    }
    return 'IN VERIFICATION';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBusiness = widget.businessName.isNotEmpty && widget.businessName != 'Royal Click Studio'
        ? widget.businessName
        : (StorageHelper().getUserName() ?? widget.businessName);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),

                        // Green Check Circle
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.white,
                            size: 54,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Registration Submitted!',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'Your application for $effectiveBusiness has been submitted successfully. Our team will verify your details and activate your account soon.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkGrey,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Application ID Card
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Application ID',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _effectiveApplicationId,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: _effectiveApplicationId));
                                      Utils.showSuccess('Application ID copied to clipboard!');
                                    },
                                    child: const Icon(
                                      Icons.copy_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Dynamic live status from server
                              Obx(() {
                                final status = _controller.currentStatus.value;
                                final isVerified = _controller.isVerified.value;
                                final isApproved = isVerified || status == 'Approved' || status == 'Active';

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isApproved
                                        ? AppColors.success.withValues(alpha: 0.12)
                                        : AppColors.warning.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isApproved ? AppColors.success : AppColors.warning,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isApproved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                                        size: 13,
                                        color: isApproved ? AppColors.success : AppColors.warning,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'SERVER STATUS: ${status.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          color: isApproved ? AppColors.success : AppColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Notification note badge
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline_rounded,
                                  color: AppColors.error, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You will get a notification within 24-48 hours.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // 5-Sec Auto-redirect Countdown Banner (ABOVE 'Add Portfolio' button)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF2E9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      value: _secondsRemaining > 0 ? _secondsRemaining / 5.0 : 0.0,
                                      strokeWidth: 2.5,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  ),
                                  Text(
                                    '$_secondsRemaining',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Redirecting to portfolio in ${_secondsRemaining}s...',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add Portfolio Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToPortfolio,
                            icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                            label: const Text(
                              'Add Portfolio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // View Verification Process Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              _redirectTimer?.cancel();
                              Navigator.of(context).push(
                                FadeScaleRoute(
                                  page: const VendorVerificationTrackerScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Track Verification Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

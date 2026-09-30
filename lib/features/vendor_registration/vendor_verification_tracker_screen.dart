import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../utils/helper/storage_helper.dart';
import '../vendor_panel/vendor_shell.dart';
import 'controllers/vendor_registration_controller.dart';

class VendorVerificationTrackerScreen extends StatefulWidget {
  const VendorVerificationTrackerScreen({super.key});

  @override
  State<VendorVerificationTrackerScreen> createState() =>
      _VendorVerificationTrackerScreenState();
}

class _VendorVerificationTrackerScreenState
    extends State<VendorVerificationTrackerScreen> {
  late final VendorRegistrationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<VendorRegistrationController>()
        ? Get.find<VendorRegistrationController>()
        : Get.put(VendorRegistrationController());
    _controller.fetchApplicationStatus();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Verification Process',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchApplicationStatus(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Application Status Header
                Obx(() {
                  final isLoading = controller.isLoading.value;
                  final liveAppId = controller.applicationData.value?.applicationId;
                  final savedAppId = StorageHelper().getApplicationId();
                  final appId = (liveAppId != null && liveAppId.trim().isNotEmpty)
                      ? liveAppId.trim()
                      : ((savedAppId != null && savedAppId.trim().isNotEmpty && savedAppId != 'WDV12345678')
                          ? savedAppId.trim()
                          : 'IN VERIFICATION');

                  final status = controller.currentStatus.value;
                  final isVerified = controller.isVerified.value;
                  final isApproved = isVerified || status == 'Approved' || status == 'Active';
                  final isRejected = status == 'Rejected';

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Application ID',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appId,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isApproved
                                ? AppColors.success.withValues(alpha: 0.12)
                                : (isRejected
                                    ? AppColors.error.withValues(alpha: 0.12)
                                    : AppColors.warning.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isApproved
                                  ? AppColors.success
                                  : (isRejected ? AppColors.error : AppColors.warning),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading) ...[
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Icon(
                                isApproved
                                    ? Icons.check_circle_rounded
                                    : (isRejected
                                        ? Icons.cancel_rounded
                                        : Icons.hourglass_empty_rounded),
                                size: 14,
                                color: isApproved
                                    ? AppColors.success
                                    : (isRejected ? AppColors.error : AppColors.warning),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isApproved
                                      ? AppColors.success
                                      : (isRejected ? AppColors.error : AppColors.warning),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Stepper Timeline (Horizontal/Vertical)
                Obx(() => _buildTimelineStepper(controller.currentStatus.value, controller.isVerified.value)),

              const SizedBox(height: 28),

              // We verify the following Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'We verify the following:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildCheckItem('Document Verification'),
                    const SizedBox(height: 10),
                    _buildCheckItem('Business Information Check'),
                    const SizedBox(height: 10),
                    _buildCheckItem('Service & Portfolio Review'),
                    const SizedBox(height: 10),
                    _buildCheckItem('Quality & Authenticity Check'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Decorative Wedding Mandap Card
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedImageView(
                        imageUrl: AppImages.exploreDecoration,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.celebration_rounded,
                        iconColor: AppColors.gold,
                        iconSize: 48,
                        backgroundColor: AppColors.cream,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 16,
                        right: 16,
                        child: Text(
                          'Verified Widoora partners get 4x more customer bookings & inquiries',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'You will be notified at every step.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Go to Dashboard Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      FadeScaleRoute(
                        page: const VendorShell(initialIndex: 0),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go to Vendor Dashboard',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildCheckItem(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStepper(String status, bool isVerified) {
    final normStatus = status.trim().toLowerCase();
    final bool isApproved = isVerified || normStatus == 'approved' || normStatus == 'active';
    final bool isRejected = normStatus == 'rejected';

    final steps = [
      {
        'title': 'Submitted',
        'sub': 'Application\nreceived',
        'state': 'done', // done, current, pending, error
        'icon': Icons.download_done_rounded,
      },
      {
        'title': 'Under Review',
        'sub': isApproved
            ? 'Documents\nverified'
            : (isRejected ? 'Review\nconcluded' : 'Verifying\ndocuments'),
        'state': isApproved ? 'done' : (isRejected ? 'done' : 'current'),
        'icon': isApproved
            ? Icons.check_circle_rounded
            : (isRejected ? Icons.highlight_off_rounded : Icons.hourglass_top_rounded),
      },
      {
        'title': isRejected ? 'Rejected' : 'Verified',
        'sub': isApproved
            ? 'Account\nverified'
            : (isRejected ? 'Application\ndeclined' : 'Pending\nverification'),
        'state': isApproved ? 'done' : (isRejected ? 'error' : 'pending'),
        'icon': isApproved
            ? Icons.verified_rounded
            : (isRejected ? Icons.cancel_outlined : Icons.verified_outlined),
      },
      {
        'title': 'Approved',
        'sub': isApproved
            ? 'Live on\nWidoora'
            : (isRejected ? 'Declined' : 'Live on\nWidoora'),
        'state': isApproved ? 'done' : 'pending',
        'icon': isApproved
            ? Icons.celebration_rounded
            : Icons.celebration_outlined,
      },
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final state = step['state'] as String;
        final icon = step['icon'] as IconData;

        Color iconBg;
        Color iconColor;
        Color titleColor;

        if (state == 'done') {
          iconBg = AppColors.success;
          iconColor = AppColors.white;
          titleColor = AppColors.success;
        } else if (state == 'current') {
          iconBg = AppColors.warning;
          iconColor = AppColors.white;
          titleColor = AppColors.warning;
        } else if (state == 'error') {
          iconBg = AppColors.error;
          iconColor = AppColors.white;
          titleColor = AppColors.error;
        } else {
          iconBg = AppColors.lightGrey;
          iconColor = AppColors.grey;
          titleColor = AppColors.grey;
        }

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: i == 0
                        ? const SizedBox.shrink()
                        : Container(
                            height: 2,
                            color: state == 'pending'
                                ? AppColors.lightGrey
                                : AppColors.success,
                          ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  Expanded(
                    child: i == steps.length - 1
                        ? const SizedBox.shrink()
                        : Container(
                            height: 2,
                            color: (state == 'done' &&
                                    steps[i + 1]['state'] != 'pending')
                                ? (steps[i + 1]['state'] == 'done'
                                    ? AppColors.success
                                    : AppColors.warning)
                                : AppColors.lightGrey,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                step['sub'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.grey,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

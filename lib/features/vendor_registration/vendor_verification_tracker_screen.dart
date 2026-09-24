import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../vendor_panel/vendor_shell.dart';

class VendorVerificationTrackerScreen extends StatelessWidget {
  const VendorVerificationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Timeline (Horizontal/Vertical)
              _buildTimelineStepper(),

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
                      Image.asset(
                        AppImages.exploreDecoration,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppColors.cream,
                          child: const Icon(Icons.celebration_rounded,
                              size: 48, color: AppColors.gold),
                        ),
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
                          'Verified Riwaaz partners get 4x more customer bookings & inquiries',
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

  Widget _buildTimelineStepper() {
    final steps = [
      {
        'title': 'Submitted',
        'sub': 'Application\nsubmitted\n20 May, 2024',
        'state': 'done', // done, current, pending
        'icon': Icons.download_done_rounded,
      },
      {
        'title': 'Under Review',
        'sub': 'Our team is\nverifying docs\n20 May, 2024',
        'state': 'current',
        'icon': Icons.hourglass_top_rounded,
      },
      {
        'title': 'Verified',
        'sub': 'Account\nverified',
        'state': 'pending',
        'icon': Icons.verified_outlined,
      },
      {
        'title': 'Approved',
        'sub': 'Live on\nRiwaaz',
        'state': 'pending',
        'icon': Icons.celebration_outlined,
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
                                ? AppColors.warning
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

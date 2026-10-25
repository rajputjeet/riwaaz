import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatingController;

  // Theme constants matching Figma design
  static const Color _bgCream = Color(0xFFFFF8F1);
  static const Color _maroonPrimary = Color(0xFF790D16);
  static const Color _textColorTitle = Color(0xFF701325);
  static const Color _textColorBody = Color(0xFF4A4A4A);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  void _onFinish() {
    Navigator.of(
      context,
    ).pushReplacement(FadeScaleRoute(page: const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -250) {
              _onFinish();
            }
          },
          child: Stack(
            children: [
              // ─── 1. Botanical Leaf Branch at Top-Left ───
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    AppImages.onboardingLeafTopLeft,
                    width: 76,
                    height: 124,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ─── 3. Botanical Leaf Branch at Lower-Right Edge ───
              Positioned(
                bottom: 85,
                right: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    AppImages.onboardingLeafRight,
                    width: 44,
                    height: 128,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ─── 3. Main Content Layout ──────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar with Skip Button
                    _buildTopBar(),

                    // Text Header (Title & Subtitle)
                    _buildHeader(),

                    const SizedBox(height: 8),

                    // Center Visual: Mobile Phone Mockup flanked snugly by Category Badges
                    Expanded(child: _buildPhoneMockupVisual()),

                    // Bottom Controls: Primary Maroon "Get Started" Button
                    _buildBottomControls(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP BAR (Skip Button)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _onFinish,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  'Skip',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: _textColorBody,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Find Trusted\nWedding Vendors',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: _textColorTitle,
              height: 1.15,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'From photographers to caterers, find the\nbest vendors for your special day.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _textColorBody,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CENTER VISUAL (Mobile Mockup with Badges positioned closely)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPhoneMockupVisual() {
    // Scale the illustration together so badges never overlap the phone.
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 380,
          height: 450,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadgeColumn(const [
                (AppImages.onboardingBadgePhotographers, 'Photographers'),
                (AppImages.onboardingBadgeMakeup, 'Makeup Artists'),
                (AppImages.onboardingBadgeDecorators, 'Decorators'),
              ]),
              const SizedBox(width: 2),
              AnimatedBuilder(
                animation: _floatingController,
                child: Image.asset(
                  AppImages.onboardingPhoneMockup,
                  width: 188,
                  height: 420,
                  fit: BoxFit.contain,
                ),
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                    0,
                    math.sin(_floatingController.value * math.pi) * 3,
                  ),
                  child: child,
                ),
              ),
              const SizedBox(width: 2),
              _buildBadgeColumn(const [
                (AppImages.onboardingBadgeCaterers, 'Caterers'),
                (AppImages.onboardingBadgeVenues, 'Venues'),
                (AppImages.onboardingBadgeMore, '& More'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeColumn(List<(String, String)> badges) {
    return AnimatedBuilder(
      animation: _floatingController,
      child: SizedBox(
        width: 84,
        height: 390,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final badge in badges)
              _buildBadgeCard(imagePath: badge.$1, label: badge.$2),
          ],
        ),
      ),
      // Matching vertical motion keeps left and right badges aligned.
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          math.cos(_floatingController.value * math.pi) * 9,
        ),
        child: child,
      ),
    );
  }

  Widget _buildBadgeCard({required String imagePath, required String label}) {
    return SizedBox(
      height: 104,
      width: 84,
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 64,
            height: 64,
            alignment: Alignment.center,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 20,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2A2A2A),
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM CONTROLS (Primary Maroon "Get Started" Button)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _onFinish,
          style: ElevatedButton.styleFrom(
            backgroundColor: _maroonPrimary,
            foregroundColor: AppColors.white,
            elevation: 2,
            shadowColor: _maroonPrimary.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

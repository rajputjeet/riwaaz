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
      duration: const Duration(milliseconds: 2600),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final availH = constraints.maxHeight;
        final availW = constraints.maxWidth;

        // Mobile Phone height & width based on available visual area
        final phoneH = (availH * 0.94).clamp(320.0, 520.0);
        // Cropped phone aspect ratio is 423 / 941 ≈ 0.4495
        final phoneW = phoneH * 0.4495;
        final phoneLeft = (availW - phoneW) / 2;

        // Badge card dimensions (prominent size, cream rounded cards)
        const badgeW = 76.0;
        const badgeH = 70.0;

        // Position badges snugly close to the mobile's outer edges
        // Right side badges moved more close to the mobile (hovering over phone bezel)
        final leftBadgePos = (phoneLeft - badgeW).clamp(4.0, availW * 0.22);
        final rightBadgePos = (phoneLeft - badgeW + 12.0).clamp(
          8.0,
          availW * 0.28,
        );

        return AnimatedBuilder(
          animation: _floatingController,
          builder: (context, _) {
            final t = _floatingController.value;
            final f0 = math.sin(t * math.pi) * 4.5;
            final f1 = math.sin(t * math.pi + 1.1) * 4.5;
            final f2 = math.sin(t * math.pi + 2.2) * 4.5;
            final phoneFloat = math.sin(t * math.pi) * 3.0;

            return Stack(
              alignment: Alignment.center,
              children: [
                // ── Centered Mobile Phone Mockup ──
                Center(
                  child: Transform.translate(
                    offset: Offset(0, phoneFloat),
                    child: SizedBox(
                      width: phoneW,
                      height: phoneH,
                      child: Image.asset(
                        AppImages.onboardingPhoneMockup,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),

                // ── Left Badge Column (Photographers, Makeup Artists, Decorators) ──
                Positioned(
                  left: leftBadgePos,
                  top: availH * 0.05,
                  bottom: availH * 0.05,
                  width: badgeW,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, f0),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgePhotographers,
                          label: 'Photographers',
                          badgeW: badgeW,
                          badgeH: badgeH,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -f1),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeMakeup,
                          label: 'Makeup Artists',
                          badgeW: badgeW,
                          badgeH: badgeH,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, f2),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeDecorators,
                          label: 'Decorators',
                          badgeW: badgeW,
                          badgeH: badgeH,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right Badge Column (Caterers, Venues, & More) ──
                Positioned(
                  right: rightBadgePos,
                  top: availH * 0.05,
                  bottom: availH * 0.05,
                  width: badgeW,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -f0),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeCaterers,
                          label: 'Caterers',
                          badgeW: badgeW,
                          badgeH: badgeH,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, f1),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeVenues,
                          label: 'Venues',
                          badgeW: badgeW,
                          badgeH: badgeH,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(14.0, -f2),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeMore,
                          label: '& More',
                          badgeW: badgeW,
                          badgeH: badgeH,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBadgeCard({
    required String imagePath,
    required String label,
    required double badgeW,
    required double badgeH,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: badgeW,
          height: badgeH,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A2A2A),
            height: 1.2,
          ),
        ),
      ],
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

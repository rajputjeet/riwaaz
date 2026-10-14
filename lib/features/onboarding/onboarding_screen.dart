import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../auth/unified_login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _particleController;
  late final AnimationController _floatingController;

  int _currentPage = 0;

  // Theme constants matching the reference design
  static const Color _bgCreamTop = Color(0xFFFBF6F0);
  static const Color _bgCreamBottom = Color(0xFFF4ECE4);
  static const Color _maroonPrimary = Color(0xFF790D16);
  static const Color _maroonTitle = Color(0xFF2C0E14);
  static const Color _subtitleColor = Color(0xFF6E565B);
  static const Color _goldAccent = Color(0xFFD4AF37);
  static const Color _dotInactive = Color(0xFFE2C8BF);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _pageController = PageController();

    // Subtle floating golden sparkle particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Floating breathing animation for badges in Screen 2
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _particleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onFinish();
    }
  }

  void _onFinish() {
    Navigator.of(context).pushReplacement(
      FadeScaleRoute(page: const UnifiedLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgCreamTop,
      body: Stack(
        children: [
          // ─── 1. Luxury Warm Ivory / Cream Background ──────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_bgCreamTop, _bgCreamBottom],
                ),
              ),
            ),
          ),

          // ─── 2. Decorative Corner Botanical Motifs ────────────────────────
          _buildDecorativeVines(),

          // ─── 3. Animated Floating Golden Dots ─────────────────────────────
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) => CustomPaint(
              painter: _WarmParticlePainter(_particleController.value),
              size: size,
            ),
          ),

          // ─── 4. Main Foreground Content (PageView + Controls) ──────────────
          SafeArea(
            child: Column(
              children: [
                // Top Skip Bar (NO call or message icons)
                _buildTopBar(),

                // 3 Onboarding Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildScreen1(size),
                      _buildScreen2(size),
                      _buildScreen3(size),
                    ],
                  ),
                ),

                // Bottom Indicator Dots and Primary Button
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOP BAR (Clean Skip button on right - No call/msg icons) ──────────────
  Widget _buildTopBar() {
    final showSkip = _currentPage > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
      child: SizedBox(
        height: 38,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48), // Spacer to balance right-aligned Skip

            if (showSkip)
              GestureDetector(
                onTap: _onFinish,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _goldAccent.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _maroonPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  // ─── SCREEN 1: Welcome / Plan Discover Celebrate / Starts Here ─────────────
  Widget _buildScreen1(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 4),

          // Circular Brand Emblem
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: _goldAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _maroonPrimary.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: ClipOval(
              child: Image.asset(
                AppImages.widooraLogo,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.favorite_rounded,
                  color: _maroonPrimary,
                  size: 34,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // WIDOORA Title
          Text(
            'WIDOORA',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _maroonTitle,
              letterSpacing: 3.5,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            'Your Wedding, Your Way',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _subtitleColor,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 10),

          // Script Ribbon: Plan ~ Discover ~ Celebrate
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallDiamond(),
              const SizedBox(width: 8),
              Text(
                'Plan  ~  Discover  ~  Celebrate',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: _maroonPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              _buildSmallDiamond(),
            ],
          ),

          const SizedBox(height: 14),

          // Photographic Visual of Couple with Dark Bottom Gradient
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: _maroonPrimary.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      AppImages.onboardingWelcomeCouple,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        AppImages.weddingHero,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Bottom dark gradient overlay for text readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.20),
                              const Color(0xFF2E0407).withValues(alpha: 0.92),
                            ],
                            stops: const [0.55, 0.76, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Overlay Caption
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 18,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Your Dream Wedding',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Starts Here...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _goldAccent,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ─── SCREEN 2: Find Trusted Wedding Vendors (Phone + 6 Icons) ───────────────
  Widget _buildScreen2(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 4),

          // Title
          Text(
            'Find Trusted\nWedding Vendors',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _maroonTitle,
              letterSpacing: 0.4,
              height: 1.12,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'From photographers to caterers,\nfind the best vendors for your special day.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _subtitleColor,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Center phone mockup with 6 floating badges in side columns
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availH = constraints.maxHeight;
                final availW = constraints.maxWidth;

                // Phone dimensions scaled to available space
                final phoneW = (availW * 0.36).clamp(110.0, 150.0);
                final phoneH = (availH * 0.88).clamp(180.0, 310.0);

                // Badge column width = remaining space on each side
                final sideW = ((availW - phoneW) / 2).clamp(60.0, 100.0);

                return AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    final t = _floatingController.value;
                    final f0 = math.sin(t * math.pi) * 4.0;
                    final f1 = math.sin(t * math.pi + 1.0) * 4.0;
                    final f2 = math.sin(t * math.pi + 2.0) * 4.0;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Left column: 3 badges ──────────────────────────
                        SizedBox(
                          width: sideW,
                          height: phoneH,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(0, f0),
                                child: _buildBadgeCompact(
                                  iconPath: AppImages.onboardingCameraIcon,
                                  label: 'Photos',
                                  fallback: Icons.camera_alt_rounded,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, -f1),
                                child: _buildBadgeCompact(
                                  iconPath: AppImages.onboardingOutfitsIcon,
                                  label: 'Outfits',
                                  fallback: Icons.brush_rounded,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, f2),
                                child: _buildBadgeCompact(
                                  iconPath: AppImages.onboardingCoupleIcon,
                                  label: 'Couple',
                                  fallback: Icons.celebration_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Center: Phone Mockup ────────────────────────────
                        _buildPhoneMockupSized(phoneW, phoneH),

                        // ── Right column: 3 badges ─────────────────────────
                        SizedBox(
                          width: sideW,
                          height: phoneH,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(0, -f0),
                                child: _buildBadgeCompact(
                                  iconPath: AppImages.onboardingDholIcon,
                                  label: 'Music',
                                  fallback: Icons.music_note_rounded,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, f1),
                                child: _buildBadgeCompact(
                                  iconPath: AppImages.onboardingCarIcon,
                                  label: 'Venues',
                                  fallback: Icons.apartment_rounded,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, -f2),
                                child: _buildBadgeCompact(
                                  iconPath: AppImages.onboardingInvitationIcon,
                                  label: 'Cards',
                                  fallback: Icons.mail_outline_rounded,
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
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ─── SCREEN 3: Plan Your Dream Wedding (Mandap Stage Visual) ────────────────
  Widget _buildScreen3(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          const SizedBox(height: 4),

          // Title
          Text(
            'Plan Your\nDream Wedding',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _maroonTitle,
              letterSpacing: 0.4,
              height: 1.12,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Save time, compare options,\nread reviews and book with ease.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _subtitleColor,
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Mandap Floral Stage Card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: _maroonPrimary.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: _goldAccent.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      AppImages.onboardingMandap,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        AppImages.exploreDecoration,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Atmospheric gradient
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.15),
                              const Color(0xFF2E0407).withValues(alpha: 0.88),
                            ],
                            stops: const [0.55, 0.78, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Feature highlights pill row
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildValuePill(Icons.verified_rounded, 'Verified'),
                          _buildValuePill(Icons.star_rounded, 'Reviews'),
                          _buildValuePill(Icons.lock_outline_rounded, 'Easy Book'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ─── BOTTOM CONTROLS (Dots + Deep Maroon Button) ────────────────────────────
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Dots Indicator (Matching mockup: round dots, active is maroon) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 18 : 6.5,
                height: 6.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? _maroonPrimary : _dotInactive,
                ),
              );
            }),
          ),

          const SizedBox(height: 18),

          // ─── Primary Full-Width Maroon Button: Next -> ───────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroonPrimary,
                foregroundColor: AppColors.white,
                elevation: 3,
                shadowColor: _maroonPrimary.withValues(alpha: 0.40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPER WIDGETS ─────────────────────────────────────────────────────────

  Widget _buildDecorativeVines() {
    return Positioned(
      top: -10,
      left: -10,
      child: Opacity(
        opacity: 0.25,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _goldAccent.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallDiamond() {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 5,
        height: 5,
        color: _goldAccent,
      ),
    );
  }

  Widget _buildValuePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _goldAccent.withValues(alpha: 0.40),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _goldAccent),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }



  // Compact badge for side columns in screen 2 (44px circle, short label)
  Widget _buildBadgeCompact({
    required String iconPath,
    required String label,
    required IconData fallback,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFBF2EC),
            border: Border.all(
              color: const Color(0xFFEBD4CA),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _maroonPrimary.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(
            iconPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              fallback,
              color: _maroonPrimary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _maroonTitle,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  // White phone mockup with explicit w/h (from LayoutBuilder)
  Widget _buildPhoneMockupSized(double phoneWidth, double phoneHeight) {

    return Container(
      width: phoneWidth,
      height: phoneHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF2C0E14),
          width: 3.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _maroonPrimary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            // Speaker bar & camera notch
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 34,
              height: 3.5,
              decoration: BoxDecoration(
                color: const Color(0xFF2C0E14),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 5),

            // Mini App Header inside phone
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFAF5EF),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Image.asset(
                      AppImages.widooraLogo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.diamond_rounded,
                        color: _maroonPrimary,
                        size: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'WIDOORA',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: _maroonPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Mini Banner inside phone
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 7),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: _maroonPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'Plan • Discover • Book',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Mini Category 2x3 Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(6, (index) {
                    final icons = [
                      Icons.camera_alt_outlined,
                      Icons.face_retouching_natural_outlined,
                      Icons.restaurant_outlined,
                      Icons.apartment_outlined,
                      Icons.celebration_outlined,
                      Icons.apps_rounded,
                    ];
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9EFE9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        icons[index],
                        size: 12,
                        color: _maroonPrimary,
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Mini bottom bar
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              width: 32,
              height: 2.5,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WARM GOLDEN PARTICLE PAINTER ────────────────────────────────────────────
class _WarmParticlePainter extends CustomPainter {
  final double animationValue;
  final List<_WarmParticle> _particles;

  _WarmParticlePainter(this.animationValue)
      : _particles = _generateParticles();

  static List<_WarmParticle> _generateParticles() {
    final rng = math.Random(13579);
    return List.generate(30, (index) {
      return _WarmParticle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 2.2 + 0.8,
        speed: rng.nextDouble() * 0.12 + 0.04,
        opacity: rng.nextDouble() * 0.35 + 0.15,
        phase: rng.nextDouble() * 2 * math.pi,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final currentY = (p.y - (animationValue * p.speed)) % 1.0;
      final currentX =
          (p.x + math.sin(animationValue * 2 * math.pi + p.phase) * 0.02) % 1.0;

      final pulse =
          (math.sin(animationValue * 2 * math.pi + p.phase) * 0.3) + 0.7;

      paint.color = const Color(0xFFD4AF37).withValues(
        alpha: (p.opacity * pulse).clamp(0.0, 1.0),
      );

      canvas.drawCircle(
        Offset(currentX * size.width, currentY * size.height),
        p.radius * pulse,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WarmParticlePainter oldDelegate) => true;
}

class _WarmParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;
  final double phase;

  _WarmParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

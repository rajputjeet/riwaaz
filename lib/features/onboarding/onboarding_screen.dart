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

  int _step = 0; // 0: Phone mockup with golden laurels, 1: Dream Wedding Mandap
  bool _isMovingForward = true;

  // Theme constants matching Figma design
  static const Color _bgCream = Color(0xFFFFF8F1);
  static const Color _maroonPrimary = Color(0xFF790D16);
  static const Color _textColorTitle = Color(0xFF701325);
  static const Color _textColorBody = Color(0xFF4A4A4A);
  static const Color _dotInactiveBeige = Color(0xFFE8DCD4);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

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

  void _goToStep(int targetStep) {
    if (targetStep == _step) return;
    setState(() {
      _isMovingForward = targetStep > _step;
      _step = targetStep;
    });
  }

  void _onNext() {
    if (_step < 1) {
      _goToStep(1);
    } else {
      _onFinish();
    }
  }

  void _onFinish() {
    Navigator.of(context).pushReplacement(
      FadeScaleRoute(page: const LoginScreen()),
    );
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
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -250) {
                // Swiped Left -> go forward
                if (_step < 1) {
                  _goToStep(1);
                } else {
                  _onFinish();
                }
              } else if (details.primaryVelocity! > 250) {
                // Swiped Right -> go back
                if (_step > 0) {
                  _goToStep(0);
                }
              }
            }
          },
          child: Stack(
            children: [
              // ─── 1. Botanical Leaf Branch at Top-Left (Matches Design) ───
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

              // ─── 2. Main Content Layout ──────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar with Skip Button
                    _buildTopBar(),

                    // Animated Text Header (Title & Subtitle)
                    _buildAnimatedHeader(),

                    const SizedBox(height: 12),

                    // Animated Center Visual (Phone Mockup with Laurel Leaves <-> Mandap Stage)
                    Expanded(
                      child: _buildAnimatedVisual(),
                    ),

                    // Bottom Controls (Dot Indicators & Next Button)
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
  // ANIMATED TEXT HEADER (Title & Subtitle smoothly transition)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAnimatedHeader() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetTween = Tween<Offset>(
          begin: Offset(_isMovingForward ? 0.20 : -0.20, 0.0),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetTween.animate(animation),
            child: child,
          ),
        );
      },
      child: Padding(
        key: ValueKey<int>(_step),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _step == 0
                  ? 'Find Trusted\nWedding Vendors'
                  : 'Plan Your\nDream Wedding',
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
              _step == 0
                  ? 'From photographers to caterers, find the\nbest vendors for your special day.'
                  : 'Save time, compare options,\nread reviews and book with ease.',
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATED CENTER VISUAL (Step 0: Phone Mockup / Step 1: Mandap Stage)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAnimatedVisual() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetTween = Tween<Offset>(
          begin: Offset(_isMovingForward ? 0.22 : -0.22, 0.0),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetTween.animate(animation),
            child: child,
          ),
        );
      },
      child: _step == 0
          ? _buildPhoneMockupVisual(key: const ValueKey<int>(0))
          : _buildMandapVisual(key: const ValueKey<int>(1)),
    );
  }

  // Step 0: Stack layout — phone mockup fills center, badge cards at left/right edges
  Widget _buildPhoneMockupVisual({required Key key}) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        final availH = constraints.maxHeight;
        // Badge column width: matches the badge card size + padding
        const badgeColW = 76.0;

        return AnimatedBuilder(
          animation: _floatingController,
          builder: (context, _) {
            final t = _floatingController.value;
            final f0 = math.sin(t * math.pi) * 5.0;
            final f1 = math.sin(t * math.pi + 1.1) * 5.0;
            final f2 = math.sin(t * math.pi + 2.2) * 5.0;
            final phoneFloat = math.sin(t * math.pi) * 3.5;

            return Stack(
              alignment: Alignment.center,
              children: [
                // ── Phone mockup fills center (height reaches slightly above/below icons) ──
                Positioned.fill(
                  left: 48,
                  right: 48,
                  child: Transform.translate(
                    offset: Offset(0, phoneFloat),
                    child: Image.asset(
                      AppImages.onboardingPhoneMockup,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),

                // ── Left badge column ──
                Positioned(
                  left: 6,
                  top: availH * 0.08,
                  bottom: availH * 0.08,
                  width: badgeColW,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, f0),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgePhotographers,
                          label: 'Photographers',
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -f1),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeMakeup,
                          label: 'Makeup Artists',
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, f2),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeDecorators,
                          label: 'Decorators',
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right badge column ──
                Positioned(
                  right: 6,
                  top: availH * 0.08,
                  bottom: availH * 0.08,
                  width: badgeColW,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -f0),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeCaterers,
                          label: 'Caterers',
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, f1),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeVenues,
                          label: 'Venues',
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -f2),
                        child: _buildBadgeCard(
                          imagePath: AppImages.onboardingBadgeMore,
                          label: '& More',
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
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 60,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A2A2A),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // Step 1: Dream Wedding Mandap Stage — transparent PNG seamlessly blends into cream background
  Widget _buildMandapVisual({required Key key}) {
    return Container(
      key: key,
      color: _bgCream,
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          final floatY = math.sin(_floatingController.value * math.pi) * 4.0;
          return Transform.translate(
            offset: Offset(0, floatY),
            child: child,
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Image.asset(
              AppImages.onboardingMandapStage,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
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
  // BOTTOM CONTROLS (Current Animated Dot Indicators + Next Button)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 2-dot indicator (2 onboarding screens)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (index) {
              final isActive = index == _step;
              return GestureDetector(
                onTap: () => _goToStep(index),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    width: isActive ? 20.0 : 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive ? _maroonPrimary : _dotInactiveBeige,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 22),

          // Primary Maroon Pill Button: Next ->
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _onNext,
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
                    _step == 0 ? 'Next' : 'Get Started',
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
        ],
      ),
    );
  }
}

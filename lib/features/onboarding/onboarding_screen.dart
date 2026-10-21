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
    with TickerProviderStateMixin {
  late final AnimationController _floatingController;

  int _step = 0; // 0: Vendors, 1: Dream Wedding
  bool _isMovingForward = true;

  // Theme constants matching Figma mockup
  static const Color _bgCream = Color(0xFFFBF7F2);
  static const Color _maroonPrimary = Color(0xFF701325);
  static const Color _textColorTitle = Color(0xFF701325);
  static const Color _textColorBody = Color(0xFF4A4A4A);
  static const Color _dotInactiveBeige = Color(0xFFDECBC1);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Floating breathing animation for badges in Vendors Screen
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
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
              // ─── 1. Fixed Botanical Leaf Flourishes (Persistent) ─────────
              const Positioned.fill(
                child: CustomPaint(
                  painter: _BotanicalFlourishPainter(),
                ),
              ),

              // ─── 2. Single Unified Layout ────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar with Skip (Persistent)
                    _buildTopBar(),

                    // Animated Text Header (Title & Subtitle change with animation)
                    _buildAnimatedHeader(),

                    const SizedBox(height: 12),

                    // Animated Center Visual (Image/Mockup changes with animation)
                    Expanded(
                      child: _buildAnimatedVisual(),
                    ),

                    // Bottom Controls (Dots & Next Button - Persistent)
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
                fontSize: 33,
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
                  : 'Save time, compare options, read reviews\nand book with ease.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: _textColorBody,
                height: 1.38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATED CENTER VISUAL (Mockup/Cards <-> Mandap Stage)
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
          ? _buildVendorsVisual(key: const ValueKey<int>(0))
          : _buildDreamWeddingVisual(key: const ValueKey<int>(1)),
    );
  }

  // Visual for Step 0: Phone Mockup flanked by 6 Floating Badges
  Widget _buildVendorsVisual({required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availH = constraints.maxHeight;
          final phoneW = (constraints.maxWidth * 0.48).clamp(165.0, 225.0);
          final sideW = ((constraints.maxWidth - phoneW) / 2).clamp(68.0, 95.0);

          return AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              final t = _floatingController.value;
              final f0 = math.sin(t * math.pi) * 3.5;
              final f1 = math.sin(t * math.pi + 1.2) * 3.5;
              final f2 = math.sin(t * math.pi + 2.4) * 3.5;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left column: 3 Cards
                  SizedBox(
                    width: sideW,
                    height: availH * 0.88,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(0, f0),
                          child: _buildCategoryCard(
                            imagePath: AppImages.onboardingBadgePhotographers,
                            label: 'Photographers',
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -f1),
                          child: _buildCategoryCard(
                            imagePath: AppImages.onboardingBadgeMakeup,
                            label: 'Makeup Artists',
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, f2),
                          child: _buildCategoryCard(
                            imagePath: AppImages.onboardingBadgeDecorators,
                            label: 'Decorators',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center: 3D Tilted Phone Mockup (Enlarged)
                  SizedBox(
                    width: phoneW,
                    height: availH,
                    child: Center(
                      child: Transform.scale(
                        scale: 1.15,
                        child: Image.asset(
                          AppImages.onboardingPhoneMockup,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Right column: 3 Cards
                  SizedBox(
                    width: sideW,
                    height: availH * 0.88,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -f0),
                          child: _buildCategoryCard(
                            imagePath: AppImages.onboardingBadgeCaterers,
                            label: 'Caterers',
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, f1),
                          child: _buildCategoryCard(
                            imagePath: AppImages.onboardingBadgeVenues,
                            label: 'Wedding Venues',
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -f2),
                          child: _buildCategoryCard(
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
      ),
    );
  }

  // Visual for Step 1: Feathered Mandap Stage Image
  Widget _buildDreamWeddingVisual({required Key key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                AppImages.onboardingMandapStage,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _bgCream.withValues(alpha: 0.25),
                        Colors.transparent,
                        Colors.transparent,
                        _bgCream.withValues(alpha: 0.40),
                      ],
                      stops: const [0.0, 0.12, 0.88, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String imagePath,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF701325).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
            height: 1.15,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON CONTROLS: TOP BAR & BOTTOM NEXT BUTTON WITH 2 SYNCHRONIZED DOTS
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
                    color: const Color(0xFF4A4A4A),
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

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Synchronized 2-Dots Indicator with smooth animation
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
                    width: isActive ? 18.0 : 7.0,
                    height: 7.0,
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

          // Primary Pill Button: Next ->
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroonPrimary,
                foregroundColor: AppColors.white,
                elevation: 3,
                shadowColor: _maroonPrimary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next',
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

// ═════════════════════════════════════════════════════════════════════════════
// BOTANICAL LEAF FLOURISH PAINTER (Top-Left & Bottom-Right Branches)
// ═════════════════════════════════════════════════════════════════════════════
class _BotanicalFlourishPainter extends CustomPainter {
  const _BotanicalFlourishPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFFE5DACD)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final stemPaint = Paint()
      ..color = const Color(0xFFE5DACD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    // ── Top-Left Botanical Branch ──────────────────────────────────────────
    canvas.save();
    canvas.translate(14, 40);

    // Stem
    final stem1 = Path()
      ..moveTo(0, 0)
      ..cubicTo(20, 40, 35, 90, 50, 140);
    canvas.drawPath(stem1, stemPaint);

    // Leaves along the stem
    _drawLeaf(canvas, leafPaint, 8, 22, -0.6, 20, 11);
    _drawLeaf(canvas, leafPaint, 18, 48, 0.7, 22, 12);
    _drawLeaf(canvas, leafPaint, 25, 78, -0.5, 23, 12);
    _drawLeaf(canvas, leafPaint, 36, 108, 0.65, 21, 11);
    _drawLeaf(canvas, leafPaint, 48, 138, 0.4, 20, 10);
    canvas.restore();

    // ── Bottom-Right Botanical Branch ──────────────────────────────────────
    canvas.save();
    canvas.translate(size.width - 24, size.height - 110);
    canvas.rotate(math.pi * 0.95);

    final stem2 = Path()
      ..moveTo(0, 0)
      ..cubicTo(18, 35, 30, 75, 45, 115);
    canvas.drawPath(stem2, stemPaint);

    _drawLeaf(canvas, leafPaint, 6, 18, -0.6, 18, 10);
    _drawLeaf(canvas, leafPaint, 16, 42, 0.7, 20, 11);
    _drawLeaf(canvas, leafPaint, 23, 68, -0.5, 21, 11);
    _drawLeaf(canvas, leafPaint, 32, 92, 0.65, 19, 10);
    _drawLeaf(canvas, leafPaint, 43, 115, 0.4, 18, 9);
    canvas.restore();
  }

  void _drawLeaf(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double angle,
    double length,
    double width,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(width * 0.7, length * 0.4, 0, length);
    path.quadraticBezierTo(-width * 0.7, length * 0.4, 0, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../auth/unified_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _contentController;
  late AnimationController _btnController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _logoOpacity;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotate = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _btnScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.elasticOut),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _btnController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _contentController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  void _navigateToDetails() {
    Navigator.of(context).push(
      FadeScaleRoute(page: const UnifiedLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // Decorative background circles
            _buildDecorativeBackground(),

            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) => CustomPaint(
                painter: _ParticlePainter(_particleController.value),
                size: MediaQuery.of(context).size,
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, child) => FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Transform.rotate(
                          angle: _logoRotate.value,
                          child: child,
                        ),
                      ),
                    ),
                    child: _buildLogo(),
                  ),

                  const SizedBox(height: 36),

                  // Brand Name + Tagline
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Column(
                        children: [
                          // Riwaaz title with ornaments
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildOrnament(),
                              const SizedBox(width: 12),
                              Text(
                                'Riwaaz',
                                style: AppTextStyles.brandTitle.copyWith(
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildOrnament(),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: Text(
                              'Everything You Need to Make Your Event Special',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.brandSubtitle.copyWith(
                                fontSize: 14,
                                height: 1.45,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Get Started Button
                  ScaleTransition(
                    scale: _btnScale,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _buildGetStartedButton(),
                    ),
                  ),

                  const SizedBox(height: 44),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeBackground() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.6),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'R',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 76,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            height: 1.0,
            shadows: [
              Shadow(
                color: AppColors.secondary.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrnament() {
    return Row(
      children: List.generate(3, (i) {
        return Container(
          width: 4 + (i * 2.0),
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildGetStartedButton() {
    return AnimatedTapWidget(
      onTap: _navigateToDetails,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// Particle effect painter
class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final y = (baseY - progress * speed * size.height * 0.5) % size.height;
      final radius = 1.0 + random.nextDouble() * 2.5;
      final opacity = (0.2 + random.nextDouble() * 0.4) *
          math.sin(progress * math.pi * 2 + i).abs();

      paint.color = AppColors.secondary.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

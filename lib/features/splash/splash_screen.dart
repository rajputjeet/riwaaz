import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import '../auth/login_screen.dart';
import '../shell/main_shell.dart';
import '../vendor_panel/vendor_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _pulseController;
  late final AnimationController _textController;
  late final AnimationController _ribbonController;
  late final AnimationController _particleController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _pulseScale;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;
  late final Animation<double> _ribbonOpacity;
  late final Animation<double> _ribbonScale;
  late final Animation<double> _loadingAnimation;

  bool _hasNavigated = false;

  // Luxury Royal Wedding Palette matching Widoora identity
  static const Color _bgCreamTop = Color(0xFFFBF6F0);
  static const Color _bgCreamBottom = Color(0xFFF4ECE4);
  static const Color _maroonPrimary = Color(0xFF790D16);
  static const Color _maroonTitle = Color(0xFF2C0E14);
  static const Color _subtitleColor = Color(0xFF6E565B);
  static const Color _goldAccent = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Logo entrance animation (elastic scale + fade)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _logoScale = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    // Continuous breathing aura pulse around the emblem
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Text entrance animation (gentle slide up + fade)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Ribbon entrance animation (fade + scale)
    _ribbonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _ribbonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ribbonController, curve: Curves.easeOut),
    );
    _ribbonScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ribbonController, curve: Curves.easeOutBack),
    );

    // Golden loading bar animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOutCubic),
    );

    // Subtle drifting warm golden sparkle particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 1. Initial breathing pause then pop emblem in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();

    // 2. Slide and fade in brand name & subtitle
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textController.forward();

    // 3. Reveal decorative ribbon
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _ribbonController.forward();

    // 4. Start progress loading bar and wait for it to complete
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    try {
      await _loadingController.forward();
    } catch (_) {}
    if (!mounted || _hasNavigated) return;

    // 6. Navigate to destination
    _navigateToDestination();
  }

  void _navigateToDestination() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final storage = StorageHelper();
    final isLoggedIn = storage.getIsLoggedIn();
    final token = storage.getAccessToken();

    if (isLoggedIn == true && token != null && token.isNotEmpty) {
      final roleId = storage.getRoleId();
      if (roleId == 3 || roleId == 4) {
        Navigator.of(context).pushReplacement(
          FadeScaleRoute(page: const VendorShell(initialIndex: 0)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          FadeScaleRoute(page: const MainShell(initialIndex: 0)),
        );
      }
      return;
    }

    Navigator.of(context).pushReplacement(
        FadeScaleRoute(page: const LoginScreen()),

    );
  } 

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _ribbonController.dispose();
    _loadingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgCreamTop,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToDestination, // Allows skip on tap if desired
        child: Stack(
          children: [
            // ─── 1. Luxury Warm Cream Background ──────────────────────────────
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

            // ─── 2. Decorative Vignette / Botanical Circles ────────────────────
            _buildDecorativeAuras(),

            // ─── 3. Floating Golden Sparkle Particles ─────────────────────────
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) => CustomPaint(
                painter: _WarmParticlePainter(_particleController.value),
                size: size,
              ),
            ),

            // ─── 4. Centered Brand Emblem, Title & Subtitle ────────────────────
            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Brand Icon with Outer Golden Halo
                          AnimatedBuilder(
                            animation: Listenable.merge(
                                [_logoController, _pulseController]),
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _logoOpacity,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: _buildEmblem(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 22),

                          // WIDOORA Title & Subtitle from old Get Started screen
                          SlideTransition(
                            position: _textSlide,
                            child: FadeTransition(
                              opacity: _textOpacity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'WIDOORA',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: _maroonTitle,
                                      letterSpacing: 4.5,
                                      shadows: [
                                        Shadow(
                                          color: _maroonPrimary
                                              .withValues(alpha: 0.14),
                                          blurRadius: 18,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'Everything You Need to Make Your Event Special',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: _subtitleColor,
                                        letterSpacing: 0.6,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Decorative Ribbon: Plan ~ Discover ~ Celebrate
                          ScaleTransition(
                            scale: _ribbonScale,
                            child: FadeTransition(
                              opacity: _ribbonOpacity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSmallDiamond(),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Plan  ~  Discover  ~  Celebrate',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w700,
                                      color: _maroonPrimary,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildSmallDiamond(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── 5. Elegant Luxury Loading Bar at Bottom ───────────────
                  _buildLoadingBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact Luxury Loading Bar Matching App Primary Color
  Widget _buildLoadingBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 42),
        child: Container(
          width: 90,
          height: 3.5,
          decoration: BoxDecoration(
            color: _maroonPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _loadingAnimation.value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _maroonPrimary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: _maroonPrimary.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Circular Brand Emblem with pulsing golden halo
  Widget _buildEmblem() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer breathing golden halo
        Transform.scale(
          scale: _pulseScale.value,
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _goldAccent.withValues(alpha: 0.12),
              border: Border.all(
                color: _goldAccent.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
          ),
        ),

        // Brand emblem container
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: _goldAccent,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _maroonPrimary.withValues(alpha: 0.18),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _goldAccent.withValues(alpha: 0.25),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: ClipOval(
            child: Image.asset(
              AppImages.widooraLogo,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.favorite_rounded,
                color: _maroonPrimary,
                size: 46,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeAuras() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          left: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _goldAccent.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _maroonPrimary.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallDiamond() {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: _goldAccent,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ─── Warm Golden Particle Painter ────────────────────────────────────────────
class _WarmParticlePainter extends CustomPainter {
  final double animationValue;
  final List<_WarmParticle> _particles;

  _WarmParticlePainter(this.animationValue)
      : _particles = _generateParticles();

  static List<_WarmParticle> _generateParticles() {
    final rng = math.Random(24680);
    return List.generate(28, (index) {
      return _WarmParticle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 2.2 + 0.8,
        speed: rng.nextDouble() * 0.10 + 0.04,
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

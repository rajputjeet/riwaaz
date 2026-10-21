import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../../data/api_provider/setting_api_provider.dart';
import '../../utils/helper/storage_helper.dart';
import '../onboarding/onboarding_screen.dart';
import '../shell/main_shell.dart';
import '../vendor_panel/vendor_shell.dart';
import '../vendor_registration/vendor_registration_wizard_screen.dart';
import '../vendor_registration/vendor_verification_tracker_screen.dart';

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
  late final AnimationController _loadingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _pulseScale;
  late final Animation<double> _textOpacity;
  late final Animation<double> _loadingAnimation;

  bool _hasNavigated = false;

  static const Color _goldAccent = Color(0xFFD4AF37);
  static const Color _goldProgress = Color(0xFFE8C570);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Logo entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Subtle gentle pulse for emblem halo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Text fade entrance
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Luxury loading bar animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOutCubic),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Fetch latest verified platform settings and cache to prefs in background
    SettingApiProvider().fetchAndCacheSettings();

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    try {
      await _loadingController.forward();
    } catch (_) {}
    if (!mounted || _hasNavigated) return;

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
        final isVerified = storage.getIsVerified();
        final isOnboardingCompleted = storage.getVendorOnboardingCompleted();
        final draft = storage.getVendorDraft();
        final appStatus = storage.getApplicationStatus();

        // 1. If vendor registered but has not completed/submitted onboarding wizard:
        // Always resume directly from where they left the registration process!
        if (!isOnboardingCompleted || draft != null) {
          final draftStep = (draft?['step'] as int?) ?? 1;
          Navigator.of(context).pushReplacement(
            FadeScaleRoute(
              page: VendorRegistrationWizardScreen(initialStep: draftStep),
            ),
          );
          return;
        }

        // 2. If vendor completed the onboarding wizard but is awaiting admin review:
        if (!isVerified ||
            appStatus == 'Under Review' ||
            appStatus == 'Pending' ||
            appStatus == 'Submitted') {
          Navigator.of(context).pushReplacement(
            FadeScaleRoute(page: const VendorVerificationTrackerScreen()),
          );
          return;
        }

        // 3. Fully verified vendor with active dashboard access
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
      FadeScaleRoute(page: const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToDestination, // Allow tapping to proceed immediately
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ─── 1. Full-Bleed Couple Walking Image (Centered & Clear)
            Image.asset(
              AppImages.onboardingWalkCouple,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                AppImages.weddingHero,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // ─── 2. Soft Gradient Overlay (Decreased Opacity for Clear Image) ─
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.55, 0.80, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF3A0209).withValues(alpha: 0.25),
                      const Color(0xFF45060E).withValues(alpha: 0.60),
                    ],
                  ),
                ),
              ),
            ),

            // ─── 3. Top Section: Golden Circle Emblem & Cursive Tagline ───────
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Golden Circle Emblem with breathing halo
                      AnimatedBuilder(
                        animation: Listenable.merge([_logoController, _pulseController]),
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _logoOpacity,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer breathing golden halo
                                  Transform.scale(
                                    scale: _pulseScale.value,
                                    child: Container(
                                      width: 148,
                                      height: 148,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _goldAccent.withValues(alpha: 0.14),
                                        border: Border.all(
                                          color: _goldAccent.withValues(alpha: 0.35),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Brand Emblem
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFC99738),
                                        width: 3.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.20),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                        BoxShadow(
                                          color: _goldAccent.withValues(alpha: 0.35),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: ClipOval(
                                      child: Image.asset(
                                        AppImages.widooraLogo,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // Cursive Tagline: Plan • Discover • Celebrate
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: Text(
                          'Plan  •  Discover  •  Celebrate',
                          style: GoogleFonts.alexBrush(
                            fontSize: 27,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF280B10),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── 4. Bottom Section: Heading, Subheading & Loading Bar ─────────
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 38),
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your Dream Wedding',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Starts Here...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.95),
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Sleek Luxury Golden Loading Bar (Replacing Dots) ──
                        _buildLoadingBar(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Luxury Gold Loading Progress Bar
  Widget _buildLoadingBar() {
    return Container(
      width: 110,
      height: 3.5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
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
                  gradient: const LinearGradient(
                    colors: [
                      _goldAccent,
                      _goldProgress,
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: _goldProgress.withValues(alpha: 0.60),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

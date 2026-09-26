import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import 'controllers/auth_controller.dart';
import '../shell/main_shell.dart';

class UserOtpVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final int? initialOtp;

  const UserOtpVerificationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    this.initialOtp,
  });

  @override
  State<UserOtpVerificationScreen> createState() =>
      _UserOtpVerificationScreenState();
}

class _UserOtpVerificationScreenState extends State<UserOtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  int _resendCountdown = 30;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill OTP if server returned one in the sign-up response
    if (widget.initialOtp != null) {
      _otpController.text = widget.initialOtp.toString();
    }
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _focusOtp() {
    _otpFocusNode.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  String get _otpCode => _otpController.text;

  void _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the complete 4-digit code',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    final parsedOtp = int.tryParse(code) ?? 0;
    final res = await authController.verifyOtp(
      identifier: widget.email.isNotEmpty ? widget.email : widget.phone,
      otp: parsedOtp,
      roleId: 2, // Customer
      name: widget.name,
    );

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (res.isSuccess != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Welcome, ${widget.name}! Account verified successfully.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // Send user directly to Home
    Navigator.of(context).pushAndRemoveUntil(
      FadeScaleRoute(page: const MainShell(initialIndex: 0)),
      (route) => false,
    );
  }

  void _handleResend() async {
    if (_resendCountdown > 0) return;

    _otpController.clear();
    _otpFocusNode.requestFocus();
    _startTimer();

    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    final res = await authController.resendOtp(
      identifier: widget.email.isNotEmpty ? widget.email : widget.phone,
    );

    if (res.isSuccess == true && res.data?.otp != null) {
      _otpController.text = res.data!.otp.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOtpComplete = _otpCode.length == 4;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 16,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Verification Icon Badge
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.08),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.mark_email_read_outlined,
                            color: AppColors.primary,
                            size: 36,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Enter Verification Code',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle with phone
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.darkGrey,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                                text: 'We sent a 4-digit code to\n'),
                            TextSpan(
                              text: '+91 ${widget.phone}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 4-Digit Pure Round OTP Fields
                      GestureDetector(
                        onTap: _focusOtp,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: (62 * 4) + (16 * 3) + 16,
                          height: 64,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Visually pure round circular cells underneath
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(4, (index) {
                                  final code = _otpController.text;
                                  final hasValue = index < code.length;
                                  final isCurrent = index == code.length ||
                                      (index == 3 && code.length == 4);
                                  final isFocused =
                                      _otpFocusNode.hasFocus && isCurrent;
                                  final digit =
                                      hasValue ? code[index] : '';

                                  return AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 180),
                                    width: 62,
                                    height: 62,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                      border: Border.all(
                                        color: isFocused
                                            ? AppColors.primary
                                            : (hasValue
                                                ? AppColors.primary
                                                    .withValues(alpha: 0.6)
                                                : const Color(0xFFE2D6C7)),
                                        width: isFocused ? 2.4 : 1.4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isFocused
                                              ? AppColors.primary
                                                  .withValues(alpha: 0.16)
                                              : Colors.black
                                                  .withValues(alpha: 0.04),
                                          blurRadius: isFocused ? 10 : 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        digit,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              // Fully transparent TextField right on top so user taps naturally summon the keyboard
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.0,
                                  child: TextField(
                                    controller: _otpController,
                                    focusNode: _otpFocusNode,
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    autofocus: true,
                                    showCursor: false,
                                    enableInteractiveSelection: false,
                                    cursorWidth: 0,
                                    cursorHeight: 0,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    onChanged: (val) {
                                      setState(() {});
                                      if (val.length == 4) {
                                        _verifyOtp();
                                      }
                                    },
                                    onTap: () {
                                      SystemChannels.textInput
                                          .invokeMethod('TextInput.show');
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Demo Helper Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          '💡 Demo: Enter any 4 digits (e.g. 1 2 3 4)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Resend Code Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          if (_resendCountdown > 0)
                            Text(
                              'Resend in ${_resendCountdown.toString().padLeft(2, '0')}s',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _handleResend,
                              child: Text(
                                'Resend OTP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Spacer pushes Verify button to the bottom
                      const Spacer(),
                      const SizedBox(height: 24),

                      // Verify & Continue Button at bottom
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_isVerifying || !isOtpComplete)
                              ? null
                              : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.45),
                            foregroundColor: AppColors.white,
                            elevation: 3,
                            shadowColor:
                                AppColors.primary.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Verify & Continue',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded,
                                        size: 20),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

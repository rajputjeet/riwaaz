import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class AppSupportSheet {
  static void show(
    BuildContext context, {
    bool isVendor = false,
    VoidCallback? onOpenFaq,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.93,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: _AppSupportSheetBody(
                  scrollController: controller,
                  isVendor: isVendor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppSupportSheetBody extends StatelessWidget {
  final ScrollController scrollController;
  final bool isVendor;

  const _AppSupportSheetBody({
    required this.scrollController,
    required this.isVendor,
  });

  static const _phone = '+91 98765 43210';
  static const _email = 'support@widoora.com';
  static const _website = 'https://widoora.com';

  static Future<void> _handleCall() async {
    final uri = Uri.parse('tel:+919876543210');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> _handleWhatsApp() async {
    const message = 'Hello! I need help with my Widoora account.';
    final uri = Uri.parse(
        'https://wa.me/919876543210?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _handleEmail() async {
    final uri = Uri.parse(
        'mailto:$_email?subject=${Uri.encodeComponent('Support Request')}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> _handleWebsite() async {
    final uri = Uri.parse(_website);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _handleInstagram() async {
    final uri = Uri.parse('https://instagram.com/widoora');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _handleFacebook() async {
    final uri = Uri.parse('https://facebook.com/widoora');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),

            // ── Header ───────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.headset_mic_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'We are always here to help you',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Section Label ─────────────────────────────────────
            const Text(
              'CONTACT US',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 10),

            // ── Call Button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: _handleCall,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_in_talk_rounded, size: 20),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Call Helpline · $_phone',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── WhatsApp Button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: _handleWhatsApp,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_rounded, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Chat on WhatsApp',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Email Card ────────────────────────────────────────
            InkWell(
              onTap: _handleEmail,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.email_outlined,
                          size: 19, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Support',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.send_rounded,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Website Card ──────────────────────────────────────
            InkWell(
              onTap: _handleWebsite,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.language_rounded,
                          size: 19, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visit our Website',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'www.widoora.com',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Divider ───────────────────────────────────────────
            Divider(color: AppColors.grey.withValues(alpha: 0.18)),
            const SizedBox(height: 10),

            // ── Social Icons ──────────────────────────────────────
            const Center(
              child: Text(
                'Follow us',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  icon: Icons.camera_alt_outlined,
                  color: const Color(0xFFE1306C),
                  label: 'Instagram',
                  onTap: _handleInstagram,
                ),
                const SizedBox(width: 12),
                _SocialButton(
                  icon: Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                  label: 'Facebook',
                  onTap: _handleFacebook,
                ),
                const SizedBox(width: 12),
                _SocialButton(
                  icon: Icons.language_rounded,
                  color: AppColors.primary,
                  label: 'Website',
                  onTap: _handleWebsite,
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

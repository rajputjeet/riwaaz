import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/utils.dart';
import '../../data/api_provider/cms_api_provider.dart';
import '../../data/api_provider/setting_api_provider.dart';
import '../../data/models/cms_model.dart';
import '../../data/models/setting_model.dart';
import '../../data/shared/data_response.dart';
import '../../utils/helper/storage_helper.dart';
import 'app_html_content_view.dart';
import 'app_states.dart';

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

  /// Dedicated modal for Forgot Password where only Admin can reset passwords.
  static void showForgotPasswordAdminSheet(
    BuildContext context, {
    bool isVendor = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ForgotPasswordAdminSheet(isVendor: isVendor),
    );
  }

  /// Dedicated modal for Terms of Service & Privacy Policy
  static void showTermsOfServiceSheet(
    BuildContext context, {
    String type = 'terms',
  }) {
    final cmsApi = CmsApiProvider();
    final isPrivacy = type == 'privacy';
    final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';
    final subtitle = isPrivacy
        ? 'Platform Privacy • Data & Security Terms'
        : 'Platform Usage Agreement • Customer Terms';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isPrivacy ? Icons.security_rounded : Icons.gavel_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
                ),
              ],
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<CmsModel>>(
                future: cmsApi.getCmsData(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AppLoadingState(message: 'Loading $title...');
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final response = snapshot.data;
                  final content = response?.data?.description ?? '';
                  if (response?.isSuccess != true && content.isEmpty) {
                    return AppErrorState(
                      message: response?.message ?? 'Could not load $title.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return AppEmptyState(
                      icon: isPrivacy ? Icons.security_rounded : Icons.gavel_rounded,
                      title: '$title Pending',
                      subtitle: 'The $title will appear here once published by admin.',
                    );
                  }
                  return AppHtmlContentView(htmlContent: content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppSupportSheetBody extends StatefulWidget {
  final ScrollController scrollController;
  final bool isVendor;

  const _AppSupportSheetBody({
    required this.scrollController,
    required this.isVendor,
  });

  @override
  State<_AppSupportSheetBody> createState() => _AppSupportSheetBodyState();
}

class _AppSupportSheetBodyState extends State<_AppSupportSheetBody> {
  late SettingModel _settings;

  @override
  void initState() {
    super.initState();
    _settings = StorageHelper().getSettings();
    _fetchLiveSettings();
  }

  Future<void> _fetchLiveSettings() async {
    try {
      final res = await SettingApiProvider().getSettings();
      if (mounted && res.isSuccess == true && res.data != null) {
        setState(() {
          _settings = res.data!;
        });
      }
    } catch (_) {}
  }

  Future<void> _safeLaunch(
    Uri uri, {
    LaunchMode mode = LaunchMode.externalApplication,
    String? fallbackCopyText,
    String? fallbackMessage,
  }) async {
    try {
      final launched = await launchUrl(uri, mode: mode);
      if (launched) return;
    } catch (_) {}

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (launched) return;
    } catch (_) {}

    if (fallbackCopyText != null && fallbackCopyText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: fallbackCopyText));
      if (mounted) {
        Utils.showSuccess(fallbackMessage ?? 'Copied to clipboard: $fallbackCopyText');
      }
    } else {
      if (mounted) {
        Utils.showError('Could not open link: $uri');
      }
    }
  }

  Future<void> _handleCall() async {
    final phone = _settings.cleanPhone;
    final uri = Uri.parse('tel:$phone');
    await _safeLaunch(
      uri,
      fallbackCopyText: phone,
      fallbackMessage: 'Phone number ($phone) copied to clipboard',
    );
  }

  Future<void> _handleWhatsApp() async {
    final waNumber = _settings.whatsAppPhone;
    final role = widget.isVendor ? 'Vendor Partner' : 'Customer';
    final message = 'Hello Widoora Support! I need help with my $role account.';
    final encodedMessage = Uri.encodeComponent(message);

    // 1. Try native WhatsApp scheme directly
    final appUri = Uri.parse('whatsapp://send?phone=$waNumber&text=$encodedMessage');
    try {
      final launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {}

    // 2. Try wa.me web link in external browser
    final webUri = Uri.parse('https://wa.me/$waNumber?text=$encodedMessage');
    try {
      final launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {}

    // 3. Fallback to platform default
    try {
      final launched = await launchUrl(webUri, mode: LaunchMode.platformDefault);
      if (launched) return;
    } catch (_) {}

    // 4. Fallback copy to clipboard
    await Clipboard.setData(ClipboardData(text: waNumber));
    if (mounted) {
      Utils.showSuccess('WhatsApp number ($waNumber) copied to clipboard');
    }
  }

  Future<void> _handleEmail() async {
    final email = _settings.displayEmail;
    final uri = Uri.parse(
        'mailto:$email?subject=${Uri.encodeComponent('Support Request - Widoora')}');
    await _safeLaunch(
      uri,
      fallbackCopyText: email,
      fallbackMessage: 'Email address ($email) copied to clipboard',
    );
  }

  Future<void> _handleWebsite() async {
    final raw = _settings.displayWebsite;
    final url = raw.startsWith('http') ? raw : 'https://$raw';
    await _safeLaunch(Uri.parse(url));
  }

  Future<void> _handleInstagram() async {
    final raw = _settings.displayInstagram;
    final url = raw.startsWith('http') ? raw : 'https://$raw';
    await _safeLaunch(Uri.parse(url));
  }

  Future<void> _handleFacebook() async {
    final raw = _settings.displayFacebook;
    final url = raw.startsWith('http') ? raw : 'https://$raw';
    await _safeLaunch(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_in_talk_rounded, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      'Call Support Helpline',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email Support',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _settings.displayEmail,
                            style: const TextStyle(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visit our Website',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _settings.displayWebsite.isNotEmpty
                                ? _settings.displayWebsite
                                : 'https://widoora.com',
                            style: const TextStyle(
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
            const SizedBox(height: 14),

            // ── Copyright Footer ──────────────────────────────────
            Center(
              child: Text(
                '© ${_settings.displayCopyright} • All Rights Reserved',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.darkGrey.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
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

class _ForgotPasswordAdminSheet extends StatefulWidget {
  final bool isVendor;

  const _ForgotPasswordAdminSheet({required this.isVendor});

  @override
  State<_ForgotPasswordAdminSheet> createState() =>
      _ForgotPasswordAdminSheetState();
}

class _ForgotPasswordAdminSheetState extends State<_ForgotPasswordAdminSheet> {
  late SettingModel _settings;

  @override
  void initState() {
    super.initState();
    _settings = StorageHelper().getSettings();
    SettingApiProvider().getSettings().then((res) {
      if (mounted && res.isSuccess == true && res.data != null) {
        setState(() {
          _settings = res.data!;
        });
      }
    });
  }

  Future<void> _safeLaunch(
    Uri uri, {
    LaunchMode mode = LaunchMode.externalApplication,
    String? fallbackCopyText,
    String? fallbackMessage,
  }) async {
    try {
      final launched = await launchUrl(uri, mode: mode);
      if (launched) return;
    } catch (_) {}

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (launched) return;
    } catch (_) {}

    if (fallbackCopyText != null && fallbackCopyText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: fallbackCopyText));
      if (mounted) {
        Utils.showSuccess(fallbackMessage ?? 'Copied to clipboard: $fallbackCopyText');
      }
    } else {
      if (mounted) {
        Utils.showError('Could not open link: $uri');
      }
    }
  }

  Future<void> _handleCall() async {
    final phone = _settings.cleanPhone;
    final uri = Uri.parse('tel:$phone');
    await _safeLaunch(
      uri,
      fallbackCopyText: phone,
      fallbackMessage: 'Phone number ($phone) copied to clipboard',
    );
  }

  Future<void> _handleWhatsApp() async {
    final waNumber = _settings.whatsAppPhone;
    final role = widget.isVendor ? 'Vendor Partner' : 'Customer';
    final message =
        'Hello Widoora Admin,\nI forgot my password for my $role account. Please help me reset my account password.\nRegistered Phone/Email: ';
    final encodedMessage = Uri.encodeComponent(message);

    // 1. Try native WhatsApp scheme directly
    final appUri = Uri.parse('whatsapp://send?phone=$waNumber&text=$encodedMessage');
    try {
      final launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {}

    // 2. Try wa.me web link in external browser
    final webUri = Uri.parse('https://wa.me/$waNumber?text=$encodedMessage');
    try {
      final launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {}

    // 3. Fallback to platform default
    try {
      final launched = await launchUrl(webUri, mode: LaunchMode.platformDefault);
      if (launched) return;
    } catch (_) {}

    // 4. Fallback copy to clipboard
    await Clipboard.setData(ClipboardData(text: waNumber));
    if (mounted) {
      Utils.showSuccess('WhatsApp number ($waNumber) copied to clipboard');
    }
  }

  Future<void> _handleEmail() async {
    final email = _settings.displayEmail;
    final role = widget.isVendor ? 'Vendor Partner' : 'Customer';
    final uri = Uri.parse(
        'mailto:$email?subject=${Uri.encodeComponent('Password Reset Request - Widoora $role')}&body=${Uri.encodeComponent('Hello Widoora Admin,\n\nI forgot my password for my $role account. Please help me reset my account password.\n\nRegistered Phone / Email: ')}');
    await _safeLaunch(
      uri,
      fallbackCopyText: email,
      fallbackMessage: 'Email address ($email) copied to clipboard',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Security Icon Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),

          // Title
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Role indicator pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.isVendor ? 'Vendor Partner Account' : 'Customer Account',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Explanation Banner - Only Admin Will Change Password
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.darkGrey,
                        height: 1.45,
                      ),
                      children: [
                        TextSpan(
                          text: 'For account security, ',
                        ),
                        TextSpan(
                          text: 'only Admin can reset passwords. ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Please call or message support directly to verify your identity and receive your updated password.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Call Admin Support Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _handleCall,
              icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
              label: const Text(
                'Call Support Helpline',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Message on WhatsApp Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _handleWhatsApp,
              icon: const Icon(Icons.chat_rounded, size: 20),
              label: const Text(
                'Message Admin on WhatsApp',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Email Support Option
          InkWell(
            onTap: _handleEmail,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.email_outlined,
                      size: 20, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Email Admin Support',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

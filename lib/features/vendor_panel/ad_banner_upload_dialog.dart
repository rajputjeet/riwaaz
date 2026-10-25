import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../data/api_provider/ad_api_provider.dart';
import '../../data/models/ad_plan_model.dart';
import '../../utils/helper/cloudinary_helper.dart';
import '../../utils/utils.dart';

/// Mandatory Ad Banner Upload Dialog shown immediately after Ad purchase.
/// Displays an authentic user-side homepage top carousel mockup so the vendor
/// can see exactly how couples and users will experience their sponsored ad banner.
class AdBannerUploadDialog extends StatefulWidget {
  final AdPlanModel? adPlan;
  final String? vendorName;
  final String? vendorCategory;
  final Future<bool> Function(File bannerFile, String? bannerUrl)? onUploadBanner;

  const AdBannerUploadDialog({
    super.key,
    this.adPlan,
    this.vendorName,
    this.vendorCategory,
    this.onUploadBanner,
  });

  static Future<bool?> show(
    BuildContext context, {
    AdPlanModel? adPlan,
    String? vendorName,
    String? vendorCategory,
    Future<bool> Function(File bannerFile, String? bannerUrl)? onUploadBanner,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, anim1, anim2) => AdBannerUploadDialog(
        adPlan: adPlan,
        vendorName: vendorName,
        vendorCategory: vendorCategory,
        onUploadBanner: onUploadBanner,
      ),
    );
  }

  @override
  State<AdBannerUploadDialog> createState() => _AdBannerUploadDialogState();
}

class _AdBannerUploadDialogState extends State<AdBannerUploadDialog> {
  final ImagePicker _picker = ImagePicker();
  File? _bannerImage;
  int? _fileSizeBytes;
  bool _isUploading = false;
  String? _uploadError;

  String get _displayName =>
      (widget.vendorName?.trim().isNotEmpty == true)
          ? widget.vendorName!
          : 'Royal Wedding Studio';

  String get _displayCategory =>
      (widget.vendorCategory?.trim().isNotEmpty == true)
          ? widget.vendorCategory!
          : 'Featured Wedding Partner';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 88,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.length();
        setState(() {
          _bannerImage = file;
          _fileSizeBytes = bytes;
          _uploadError = null;
        });
      }
    } catch (e) {
      Utils.showError('Could not access image: $e');
    }
  }

  Future<void> _handleUpload() async {
    if (_bannerImage == null) {
      Utils.showError('Please pick an ad banner image first.');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      String? uploadedUrl;

      // 1. Attempt Cloudinary upload if available
      try {
        final res = await CloudinaryHelper.uploadFile(
          file: _bannerImage!,
          context: 'banners',
        );
        uploadedUrl = res['url']?.toString();
      } catch (_) {
        uploadedUrl = null;
      }

      // 2. Upload banner using POST /api/ad/upload-banner
      bool success = true;
      if (widget.onUploadBanner != null) {
        success = await widget.onUploadBanner!(_bannerImage!, uploadedUrl);
      } else {
        final res = await AdApiProvider().uploadAdBanner(_bannerImage!);
        if (res.isSuccess == true) {
          success = true;
        } else {
          success = false;
          _uploadError = res.message ?? res.error ?? 'Upload failed. Please check network.';
        }
      }

      if (!mounted) return;

      if (success) {
        setState(() => _isUploading = false);
        await _showSuccessCelebration();
      } else {
        setState(() {
          _isUploading = false;
          _uploadError = 'Upload failed. Please check your network and retry.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadError = 'Error uploading banner: $e';
      });
    }
  }

  Future<void> _showSuccessCelebration() async {
    final nav = Navigator.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ad Banner Published!',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your sponsored ad banner is now active and live on the customer homepage top carousel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.darkGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    nav.pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done & View My Ad',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isUploading) return false;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFF57C00), size: 24),
            const SizedBox(width: 8),
            Text(
              'Banner Upload Pending',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Your ad boost plan is already active, but your banner must be uploaded to appear on the couple homepage top carousel.\n\nDo you want to exit and upload later?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.darkGrey,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Upload Now (Recommended)',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Exit Anyway',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );

    return shouldExit == true;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final dialogMaxHeight = mq.size.height * 0.92;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final canExit = await _onWillPop();
        if (canExit && mounted) {
          nav.pop(false);
        }
      },
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: dialogMaxHeight,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHomepageLivePreviewMockup(),
                          const SizedBox(height: 18),
                          _buildImagePickerActions(),
                          const SizedBox(height: 16),
                          _buildSpecificationsCard(),
                          if (_uploadError != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: Colors.redAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _uploadError!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded,
                              size: 11, color: AppColors.primaryDark),
                          SizedBox(width: 4),
                          Text(
                            'MANDATORY STEP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Homepage Carousel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Upload Ads Banner',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'This banner will be prominently displayed at the top of the user app homepage.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.darkGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
            onPressed: () async {
              final nav = Navigator.of(context);
              final canExit = await _onWillPop();
              if (canExit && mounted) {
                nav.pop(false);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Authentic miniature phone mockup demonstrating how this banner
  /// looks in the real user-side homepage carousel (`dashboard_screen.dart`).
  Widget _buildHomepageLivePreviewMockup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.remove_red_eye_rounded,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'User App Live Preview',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _bannerImage != null
                    ? const Color(0xFFE8F5E9)
                    : AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _bannerImage != null
                      ? const Color(0xFF81C784)
                      : AppColors.grey.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _bannerImage != null
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 11,
                    color: _bannerImage != null
                        ? const Color(0xFF2E7D32)
                        : AppColors.darkGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _bannerImage != null
                        ? 'Image Ready'
                        : 'Awaiting Banner Image',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _bannerImage != null
                          ? const Color(0xFF2E7D32)
                          : AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Miniature Phone Top Frame Mockup
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1F),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF383842),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              // Mini Status Bar & App Header
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'WIDOORA',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF3D088),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Udaipur ▾',
                            style: TextStyle(
                              fontSize: 8.5,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.search_rounded,
                            size: 14, color: Colors.white70),
                        SizedBox(width: 8),
                        Icon(Icons.notifications_none_rounded,
                            size: 14, color: Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),

              // Mini Top Carousel Banner View
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 8.5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_bannerImage != null)
                          Image.file(
                            _bannerImage!,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryDark,
                                  const Color(0xFF2B0509),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 32,
                                    color: AppColors.gold.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Your Ad Banner Appears Here',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Couples tap here to open your profile directly',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Authentic Homepage Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.75),
                                Colors.black.withValues(alpha: 0.40),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.60, 1.0],
                            ),
                          ),
                        ),

                        // Top-Right "SPONSORED" Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 10, color: AppColors.primaryDark),
                                SizedBox(width: 3),
                                Text(
                                  'SPONSORED',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom-Left Overlay Text matching Customer Dashboard
                        Positioned(
                          left: 12,
                          bottom: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _displayName,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$_displayCategory • Book Now →',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFF3D088),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerActions() {
    if (_bannerImage == null) {
      return Row(
        children: [
          Expanded(
            child: _buildPickerButton(
              icon: Icons.photo_library_outlined,
              label: 'Choose Gallery',
              subtitle: 'Select from photos',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPickerButton(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              subtitle: 'Use camera',
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ),
        ],
      );
    }

    // When an image is picked: Show details & quick change options
    final sizeStr = _fileSizeBytes != null
        ? '${(_fileSizeBytes! / (1024 * 1024)).toStringAsFixed(2)} MB'
        : 'Ready';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _bannerImage!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Banner',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Size: $sizeStr • 16:9 Landscape',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                _bannerImage = null;
                _fileSizeBytes = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 14, color: Color(0xFFD4A017)),
              SizedBox(width: 6),
              Text(
                'Banner Guidelines for Best Engagement',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSpecRow(
              '📐 Format', '16:9 Landscape (Recommended 1200 × 600 px)'),
          _buildSpecRow(
              '📸 Content', 'High-res wedding photo with key subjects centered'),
          _buildSpecRow('⚡ Formats', 'JPG, PNG, or WEBP up to 10MB'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              detail,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isUploading ? null : _handleUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isUploading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Uploading & Launching Banner...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _bannerImage == null
                            ? 'Select Banner to Launch'
                            : 'Upload & Launch Ad Banner',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _isUploading
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    final canExit = await _onWillPop();
                    if (canExit && mounted) {
                      nav.pop(false);
                    }
                  },
            child: const Text(
              'I will upload banner later (Keep Ad on Hold)',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

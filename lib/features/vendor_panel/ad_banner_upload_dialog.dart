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
  final Future<bool> Function(File bannerFile, String? bannerUrl)?
  onUploadBanner;
  final bool selectionOnly;

  const AdBannerUploadDialog({
    super.key,
    this.adPlan,
    this.vendorName,
    this.vendorCategory,
    this.onUploadBanner,
    this.selectionOnly = false,
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

  static Future<File?> pickForPurchase(
    BuildContext context, {
    AdPlanModel? adPlan,
    String? vendorName,
    String? vendorCategory,
  }) {
    return showGeneralDialog<File?>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (context, anim, secondaryAnim, child) =>
          FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          ),
      pageBuilder: (_, _, _) => AdBannerUploadDialog(
        adPlan: adPlan,
        vendorName: vendorName,
        vendorCategory: vendorCategory,
        selectionOnly: true,
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
        if (!mounted) return;
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

    if (widget.selectionOnly) {
      Navigator.of(context).pop<File?>(_bannerImage);
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
          _uploadError =
              res.message ??
              res.error ??
              'Upload failed. Please check network.';
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

  void _closeDialog() {
    if (widget.selectionOnly) {
      Navigator.of(context).pop<File?>();
    } else {
      Navigator.of(context).pop<bool>(false);
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
    if (widget.selectionOnly) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF57C00),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Banner Upload Pending',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canExit = await _onWillPop();
        if (canExit && mounted) _closeDialog();
      },
      child: SafeArea(
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          backgroundColor: AppColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBannerPreview(),
                        const SizedBox(height: 18),
                        _buildImagePickerActions(),
                        const SizedBox(height: 16),
                        _buildSpecificationsCard(),
                        if (_uploadError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _uploadError!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                      ],
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
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      color: AppColors.cream.withValues(alpha: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectionOnly
                      ? 'Choose Ad Banner'
                      : 'Update Ad Banner',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.selectionOnly
                      ? 'Choose a banner for your ad, then continue to checkout.'
                      : 'Upload the banner customers will see on the homepage.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _isUploading
                ? null
                : () async {
                    final canExit = await _onWillPop();
                    if (canExit && mounted) _closeDialog();
                  },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 6,
          children: [
            const Text(
              'Banner preview',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              _bannerImage == null ? 'Choose an image below' : 'Image ready',
              style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _bannerImage != null
                ? Image.file(_bannerImage!, fit: BoxFit.cover)
                : ColoredBox(
                    color: AppColors.cream,
                    child: Center(
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 44,
                        color: AppColors.primary.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                child: Text(
                  'Selected banner\n$sizeStr',
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed: _isUploading
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                child: const Text('Change'),
              ),
              TextButton(
                onPressed: _isUploading
                    ? null
                    : () {
                        setState(() {
                          _bannerImage = null;
                          _fileSizeBytes = null;
                        });
                      },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
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
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: AppColors.darkGrey),
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
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 14,
                color: Color(0xFFD4A017),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Banner guidelines',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSpecRow(
            '📐 Format',
            '16:9 Landscape (Recommended 1200 × 600 px)',
          ),
          _buildSpecRow(
            '📸 Content',
            'High-res wedding photo with key subjects centered',
          ),
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
              textAlign: TextAlign.center,
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
              style: const TextStyle(fontSize: 10.5, color: AppColors.darkGrey),
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
        ElevatedButton(
          onPressed: _isUploading || _bannerImage == null
              ? null
              : _handleUpload,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            minimumSize: const Size(0, 50),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isUploading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.selectionOnly
                      ? 'Continue to Payment'
                      : 'Upload Ad Banner',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _isUploading
              ? null
              : () async {
                  final canExit = await _onWillPop();
                  if (canExit && mounted) _closeDialog();
                },
          child: Text(
            widget.selectionOnly ? 'Cancel' : 'Upload later',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

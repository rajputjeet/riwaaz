import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../data/api_provider/user_api_provider.dart';
import '../../shared/widgets/app_states.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../utils/helper/cloudinary_helper.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';

class VendorEditProfileScreen extends StatefulWidget {
  const VendorEditProfileScreen({super.key});

  @override
  State<VendorEditProfileScreen> createState() =>
      _VendorEditProfileScreenState();
}

class _VendorEditProfileScreenState extends State<VendorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userApi = UserApiProvider();
  final _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _businessNameCtrl;
  late TextEditingController _discCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _pincodeCtrl;

  XFile? _selectedImage;
  String? _currentProfileImgUrl;

  XFile? _selectedBannerImage;
  String? _currentBannerImgUrl;
  String? _currentBannerPublicId;

  @override
  void initState() {
    super.initState();
    final storage = StorageHelper();
    _nameCtrl = TextEditingController(text: storage.getUserName() ?? '');
    _businessNameCtrl = TextEditingController(
      text: storage.getUserName() ?? '',
    );
    _discCtrl = TextEditingController();
    _emailCtrl = TextEditingController(text: storage.getUserEmail() ?? '');
    _addressCtrl = TextEditingController(text: storage.getUserAddress() ?? '');
    _cityCtrl = TextEditingController(text: storage.getUserCity() ?? '');
    _stateCtrl = TextEditingController(text: storage.getUserState() ?? '');
    _pincodeCtrl = TextEditingController(text: storage.getUserPincode() ?? '');
    _currentProfileImgUrl = storage.getUserProfileImg();
    _currentBannerImgUrl = storage.getVendorBannerImg();

    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await _userApi.getProfile();
      if (!mounted) return;
      if (res.isSuccess == true && res.data != null) {
        final user = res.data!;
        final v = user.vendorProfile;

        _nameCtrl.text = v?.ownerName ?? user.fullName ?? '';
        _businessNameCtrl.text = v?.businessName ?? '';
        _discCtrl.text = v?.businessDescription ?? user.about ?? '';
        _emailCtrl.text = user.email ?? '';
        _addressCtrl.text = v?.businessAddress ?? user.address ?? '';
        _cityCtrl.text = v?.city ?? user.city ?? '';
        _stateCtrl.text = v?.state ?? user.state ?? '';
        _pincodeCtrl.text = v?.pincode ?? user.pincode ?? '';

        if (user.profileImgUrl != null && user.profileImgUrl!.isNotEmpty) {
          _currentProfileImgUrl = user.profileImgUrl;
          StorageHelper().saveUserProfileImg(user.profileImgUrl);
        }

        final banner = user.bannerImgId ?? v?.bannerImgId;
        if (banner != null && banner.url != null && banner.url!.isNotEmpty) {
          _currentBannerImgUrl = banner.url;
          _currentBannerPublicId = banner.publicId;
          StorageHelper().saveVendorBannerImg(banner.url);
        } else if (StorageHelper().getVendorBannerImg() != null) {
          _currentBannerImgUrl = StorageHelper().getVendorBannerImg();
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _businessNameCtrl.dispose();
    _discCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _showBannerSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Upload Business Banner',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a cover photo or storefront banner for your details card',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          final picked = await _picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 85,
                            maxWidth: 1920,
                            maxHeight: 1080,
                          );
                          if (picked != null) {
                            setState(() => _selectedBannerImage = picked);
                          }
                        } catch (e) {
                          if (!mounted) return;
                          Utils.showError('Camera error: $e');
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Camera',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          final picked = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                            maxWidth: 1920,
                            maxHeight: 1080,
                          );
                          if (picked != null) {
                            setState(() => _selectedBannerImage = picked);
                          }
                        } catch (e) {
                          if (!mounted) return;
                          Utils.showError('Gallery error: $e');
                        }
                      },
                      icon: const Icon(
                        Icons.photo_library_rounded,
                        color: AppColors.white,
                      ),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Upload Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a clear photo for your vendor profile',
                style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          final picked = await _picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 85,
                            maxWidth: 1600,
                            maxHeight: 1600,
                          );
                          if (picked != null) {
                            setState(() => _selectedImage = picked);
                          }
                        } catch (e) {
                          if (!mounted) return;
                          Utils.showError('Camera error: $e');
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Camera',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          final picked = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                            maxWidth: 1600,
                            maxHeight: 1600,
                          );
                          if (picked != null) {
                            setState(() => _selectedImage = picked);
                          }
                        } catch (e) {
                          if (!mounted) return;
                          Utils.showError('Gallery error: $e');
                        }
                      },
                      icon: const Icon(
                        Icons.photo_library_rounded,
                        color: AppColors.white,
                      ),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    final storage = StorageHelper();

    try {
      final name = _nameCtrl.text.trim();
      final businessName = _businessNameCtrl.text.trim();
      final disc = _discCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final address = _addressCtrl.text.trim();
      final city = _cityCtrl.text.trim();
      final state = _stateCtrl.text.trim();
      final pincode = _pincodeCtrl.text.trim();

      Map<String, dynamic>? bannerPayload;
      if (_selectedBannerImage != null) {
        try {
          final res = await CloudinaryHelper.uploadFile(
            file: File(_selectedBannerImage!.path),
            context: 'banners',
            authToken: storage.getAccessToken(),
          );
          final url = res['url']?.toString() ?? '';
          final publicId = res['public_id']?.toString() ?? '';
          if (url.isNotEmpty) {
            bannerPayload = {'url': url, 'public_id': publicId};
          }
        } catch (e) {
          debugPrint('Cloudinary banner upload error: $e');
        }
      } else if (_currentBannerImgUrl != null &&
          _currentBannerImgUrl!.isNotEmpty) {
        bannerPayload = {
          'url': _currentBannerImgUrl!,
          'public_id': _currentBannerPublicId ?? '',
        };
      }

      final formDataMap = <String, dynamic>{
        'fullName': name.isNotEmpty ? name : businessName,
        'name': name.isNotEmpty ? name : businessName,
        'ownerName': name,
        'businessName': businessName,
        'businessDescription': disc,
        'about': disc,
        'bio': disc,
        'email': email,
        'businessAddress': address,
        'address': address,
        'city': city,
        'state': state,
        if (pincode.isNotEmpty) 'pincode': pincode,
        if (bannerPayload != null) ...{
          'bannerImgId': bannerPayload,
          'bannerImgId[url]': bannerPayload['url'],
          'bannerImgId[public_id]': bannerPayload['public_id'],
        },
      };

      if (_selectedImage != null) {
        final fileName = _selectedImage!.name;
        formDataMap['profileImg'] = await dio.MultipartFile.fromFile(
          _selectedImage!.path,
          filename: fileName,
        );
      }

      if (_selectedBannerImage != null) {
        final fileName = _selectedBannerImage!.name;
        formDataMap['bannerImg'] = await dio.MultipartFile.fromFile(
          _selectedBannerImage!.path,
          filename: fileName,
        );
      }

      final formData = dio.FormData.fromMap(formDataMap);
      final res = await _userApi.editProfile(formData);

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (res.isSuccess == true || res.data != null) {
        if (businessName.isNotEmpty) {
          await storage.saveUserName(businessName);
        }
        if (email.isNotEmpty) {
          await storage.saveUserEmail(email);
        }
        if (address.isNotEmpty) {
          await storage.saveUserAddress(address);
        }
        if (city.isNotEmpty) {
          await storage.saveUserCity(city);
        }
        if (state.isNotEmpty) {
          await storage.saveUserState(state);
        }
        if (pincode.isNotEmpty) {
          await storage.saveUserPincode(pincode);
        }
        if (res.data?.profileImgUrl != null) {
          await storage.saveUserProfileImg(res.data!.profileImgUrl);
        }
        final newBanner = res.data?.bannerImgUrl ?? bannerPayload?['url'];
        if (newBanner != null && newBanner.isNotEmpty) {
          await storage.saveVendorBannerImg(newBanner);
        }

        if (!mounted) return;
        Utils.showSuccess('Business profile updated successfully!');
        Navigator.of(context).pop(true);
      } else {
        Utils.showError(res.message ?? 'Failed to update profile.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      Utils.showError('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Business Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const AppLoadingState(message: 'Loading profile details...')
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Business Profile Header (Banner in Background - Identical to Profile) ──
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _businessNameCtrl,
                        _nameCtrl,
                        _emailCtrl,
                      ]),
                      builder: (context, _) {
                        final bool hasBanner =
                            _selectedBannerImage != null ||
                            (_currentBannerImgUrl != null &&
                                _currentBannerImgUrl!.isNotEmpty);
                        final String displayName =
                            _businessNameCtrl.text.trim().isNotEmpty
                            ? _businessNameCtrl.text.trim()
                            : (_nameCtrl.text.trim().isNotEmpty
                                  ? _nameCtrl.text.trim()
                                  : (StorageHelper().getUserName() ??
                                        'Vendor Partner'));
                        final String displayEmail =
                            _emailCtrl.text.trim().isNotEmpty
                            ? _emailCtrl.text.trim()
                            : (StorageHelper().getUserEmail() ?? '');
                        final String displayMobile =
                            StorageHelper().getUserMobile() ?? '';

                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasBanner
                                  ? AppColors.gold.withValues(alpha: 0.5)
                                  : AppColors.gold.withValues(alpha: 0.3),
                              width: hasBanner ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: hasBanner ? 0.08 : 0.04,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // Background Banner
                              if (hasBanner) ...[
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: _showBannerSourceSheet,
                                    child: _selectedBannerImage != null
                                        ? Image.file(
                                            File(_selectedBannerImage!.path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                        : CachedImageView(
                                            imageUrl: _currentBannerImgUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                  ),
                                ),
                                // Dark gradient overlay for text readability
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withValues(
                                              alpha: 0.35,
                                            ),
                                            Colors.black.withValues(
                                              alpha: 0.82,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: _showBannerSourceSheet,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primary.withValues(
                                              alpha: 0.07,
                                            ),
                                            AppColors.gold.withValues(
                                              alpha: 0.14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              // Edit / Change Banner button at top right
                              Positioned(
                                top: 14,
                                right: 14,
                                child: InkWell(
                                  onTap: _showBannerSourceSheet,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasBanner
                                          ? Colors.black.withValues(alpha: 0.55)
                                          : AppColors.background,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: hasBanner
                                            ? Colors.white.withValues(
                                                alpha: 0.4,
                                              )
                                            : AppColors.gold.withValues(
                                                alpha: 0.4,
                                              ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          size: 13,
                                          color: hasBanner
                                              ? AppColors.white
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          hasBanner
                                              ? 'Edit Banner'
                                              : 'Add Banner',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: hasBanner
                                                ? AppColors.white
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Details Card Content (Centered - Exact same sizing as profile)
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    24,
                                    20,
                                    20,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Avatar (80x80 matching profile)
                                      GestureDetector(
                                        onTap: _showImageSourceSheet,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.gold,
                                                  width: 2.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                                color: AppColors.primary,
                                              ),
                                              child: ClipOval(
                                                child: _selectedImage != null
                                                    ? Image.file(
                                                        File(
                                                          _selectedImage!.path,
                                                        ),
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : CachedImageView(
                                                        imageUrl:
                                                            _currentProfileImgUrl ??
                                                            '',
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                        isCircle: true,
                                                        fallbackIcon: Icons
                                                            .storefront_rounded,
                                                        iconColor:
                                                            AppColors.gold,
                                                        iconSize: 40,
                                                        backgroundColor:
                                                            AppColors.primary,
                                                      ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.white,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt_rounded,
                                                  color: AppColors.white,
                                                  size: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        displayName,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: hasBanner
                                              ? AppColors.white
                                              : AppColors.black,
                                          shadows: hasBanner
                                              ? const [
                                                  Shadow(
                                                    color: Colors.black54,
                                                    blurRadius: 6,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                      if (displayEmail.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          displayEmail,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: hasBanner
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                            color: hasBanner
                                                ? AppColors.white.withValues(
                                                    alpha: 0.90,
                                                  )
                                                : AppColors.darkGrey,
                                          ),
                                        ),
                                      ],
                                      if (displayMobile.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          displayMobile,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: hasBanner
                                                ? AppColors.white.withValues(
                                                    alpha: 0.80,
                                                  )
                                                : AppColors.grey,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Center(
                                        child: OutlinedButton.icon(
                                          onPressed: _showImageSourceSheet,
                                          icon: Icon(
                                            Icons.photo_camera_rounded,
                                            size: 14,
                                            color: hasBanner
                                                ? AppColors.white
                                                : AppColors.primary,
                                          ),
                                          label: Text(
                                            'Change Profile Photo',
                                            style: TextStyle(
                                              color: hasBanner
                                                  ? AppColors.white
                                                  : AppColors.primary,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: hasBanner
                                                ? AppColors.white
                                                : AppColors.primary,
                                            backgroundColor: hasBanner
                                                ? Colors.black.withValues(
                                                    alpha: 0.35,
                                                  )
                                                : Colors.transparent,
                                            side: BorderSide(
                                              color: hasBanner
                                                  ? Colors.white.withValues(
                                                      alpha: 0.5,
                                                    )
                                                  : AppColors.primary
                                                        .withValues(alpha: 0.4),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // 1. Owner / Contact Person Name
                    _buildTextField(
                      label: 'Owner / Contact Person Name',
                      hintText: 'e.g. Nishant Rajput',
                      controller: _nameCtrl,
                      icon: Icons.person_outline_rounded,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter owner name';
                        }
                        if (v.trim().length < 2) {
                          return 'Owner name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // 2. Business / Studio Name
                    _buildTextField(
                      label: 'Business / Studio Name',
                      hintText: 'e.g. Royal Graphy Studio',
                      controller: _businessNameCtrl,
                      icon: Icons.storefront_rounded,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter business / studio name';
                        }
                        if (v.trim().length < 2) {
                          return 'Business name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // 3. Business Description (Disc)
                    _buildTextField(
                      label: 'Business Description',
                      hintText:
                          'Describe your wedding services, style and offerings...',
                      controller: _discCtrl,
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter business description';
                        }
                        if (v.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // 4. Email Address
                    _buildTextField(
                      label: 'Business Email',
                      hintText: 'e.g. studio@studio.com',
                      controller: _emailCtrl,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: false,
                      validator: (v) {
                        final email = v?.trim() ?? '';
                        if (email.isNotEmpty &&
                            (!email.contains('@') || !email.contains('.'))) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // 5. Business Address
                    _buildTextField(
                      label: 'Studio / Business Address',
                      hintText: 'e.g. 123 MG Road, Bandra West',
                      controller: _addressCtrl,
                      icon: Icons.storefront_outlined,
                      maxLines: 1,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter business address';
                        }
                        if (v.trim().length < 3) {
                          return 'Address must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // 6. City
                    _buildTextField(
                      label: 'City',
                      hintText: 'e.g. Mumbai',
                      controller: _cityCtrl,
                      icon: Icons.location_city_outlined,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter city';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // 7. State & Pincode Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'State',
                            hintText: 'e.g. Maharashtra',
                            controller: _stateCtrl,
                            icon: Icons.map_outlined,
                            isRequired: true,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter state';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'Pincode',
                            hintText: 'e.g. 400050',
                            controller: _pincodeCtrl,
                            icon: Icons.pin_drop_outlined,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter pincode';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                'Save Profile Changes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            children: [
              if (isRequired && !label.toLowerCase().contains('optional'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (maxLines > 1)
          Stack(
            children: [
              _buildProfileInput(
                label: hintText,
                controller: controller,
                icon: icon,
                maxLines: maxLines,
                keyboardType: keyboardType,
                validator: validator,
                multiline: true,
              ),
              Positioned(
                left: 13,
                top: 15,
                child: IgnorePointer(
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          )
        else
          _buildProfileInput(
            label: hintText,
            controller: controller,
            icon: icon,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
          ),
      ],
    );
  }

  Widget _buildProfileInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required int maxLines,
    required TextInputType keyboardType,
    required String? Function(String?)? validator,
    bool multiline = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.darkGrey),
        prefixIcon: multiline
            ? null
            : Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: multiline ? 46 : 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
    );
  }
}

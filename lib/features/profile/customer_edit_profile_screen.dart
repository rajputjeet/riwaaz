import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../data/api_provider/user_api_provider.dart';
import '../../shared/widgets/app_states.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userApi = UserApiProvider();
  final _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;

  XFile? _selectedImage;
  String? _currentProfileImgUrl;

  @override
  void initState() {
    super.initState();
    final storage = StorageHelper();
    _nameCtrl = TextEditingController(text: storage.getUserName() ?? '');
    _emailCtrl = TextEditingController(text: storage.getUserEmail() ?? '');
    _addressCtrl = TextEditingController(text: storage.getWeddingLocation() ?? '');
    _currentProfileImgUrl = storage.getUserProfileImg();

    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await _userApi.getProfile();
      if (!mounted) return;
      if (res.isSuccess == true && res.data != null) {
        final user = res.data!;
        _nameCtrl.text = user.fullName ?? '';
        _emailCtrl.text = user.email ?? '';

        if (user.profileImgUrl != null && user.profileImgUrl!.isNotEmpty) {
          _currentProfileImgUrl = user.profileImgUrl;
          StorageHelper().saveUserProfileImg(user.profileImgUrl);
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
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
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
                'Select a clear photo for your profile',
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
                      icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      icon: const Icon(Icons.photo_library_rounded, color: AppColors.white),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      final email = _emailCtrl.text.trim();
      final address = _addressCtrl.text.trim();

      final formDataMap = <String, dynamic>{
        'fullName': name,
        'name': name,
        'email': email,
        'address': address,
        'city': address,
      };

      if (_selectedImage != null) {
        final fileName = _selectedImage!.name;
        formDataMap['profileImg'] = await dio.MultipartFile.fromFile(
          _selectedImage!.path,
          filename: fileName,
        );
      }

      final formData = dio.FormData.fromMap(formDataMap);
      final res = await _userApi.editProfile(formData);

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (res.isSuccess == true || res.data != null) {
        if (name.isNotEmpty) {
          await storage.saveUserName(name);
        }
        if (email.isNotEmpty) {
          await storage.saveUserEmail(email);
        }
        if (address.isNotEmpty) {
          await storage.saveWeddingLocation(address);
        }
        if (res.data?.profileImgUrl != null) {
          await storage.saveUserProfileImg(res.data!.profileImgUrl);
        }

        if (!mounted) return;
        Utils.showSuccess('Profile updated successfully!');
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
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
                    // Profile Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.gold, width: 2.5),
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                              child: ClipOval(
                                child: _selectedImage != null
                                    ? Image.file(
                                        File(_selectedImage!.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : CachedImageView(
                                        imageUrl: _currentProfileImgUrl ?? '',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        isCircle: true,
                                        fallbackIcon: Icons.person_rounded,
                                        iconColor: AppColors.gold,
                                        iconSize: 46,
                                        backgroundColor: AppColors.primary,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton.icon(
                        onPressed: _showImageSourceSheet,
                        icon: const Icon(Icons.photo_camera_rounded, size: 16),
                        label: const Text(
                          'Change Profile Picture',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 1. Name
                    _buildTextField(
                      label: 'Full Name',
                      hintText: 'e.g. Rahul Sharma',
                      controller: _nameCtrl,
                      icon: Icons.person_outline_rounded,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (v.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // 2. Email Address
                    _buildTextField(
                      label: 'Email Address',
                      hintText: 'e.g. rahul@gmail.com',
                      controller: _emailCtrl,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter email address';
                        }
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // 3. Address
                    _buildTextField(
                      label: 'Address / City',
                      hintText: 'e.g. Chandigarh, Punjab',
                      controller: _addressCtrl,
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter address or city';
                        }
                        if (v.trim().length < 3) {
                          return 'Address must be at least 3 characters';
                        }
                        return null;
                      },
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
              if (isRequired)
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
        TextFormField(
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
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.darkGrey),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.grey.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.grey.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

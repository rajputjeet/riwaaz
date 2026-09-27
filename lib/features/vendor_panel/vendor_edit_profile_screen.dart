import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/service_categories.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../shared/widgets/service_categories_bar.dart';
import '../../utils/helper/storage_helper.dart';

class VendorEditProfileScreen extends StatefulWidget {
  const VendorEditProfileScreen({super.key});

  @override
  State<VendorEditProfileScreen> createState() =>
      _VendorEditProfileScreenState();
}

class _VendorEditProfileScreenState extends State<VendorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _businessNameCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _contactPersonCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _whatsappCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _experienceCtrl;
  late TextEditingController _bioCtrl;

  final List<String> _specialties = [
    'Royal Wedding Cinematography',
    'Candid Photography',
    'Drone 4K Shoots',
    'Pre-Wedding Films',
    'Traditional Photography',
    'Live Streaming',
  ];

  final Set<String> _selectedSpecialties = {
    'Royal Wedding Cinematography',
    'Candid Photography',
    'Pre-Wedding Films',
  };

  @override
  void initState() {
    super.initState();
    final storage = StorageHelper();
    _businessNameCtrl = TextEditingController(
        text: (storage.getUserName()?.isNotEmpty == true)
            ? storage.getUserName()!
            : 'Royal Click Studio');
    _categoryCtrl = TextEditingController();
    _contactPersonCtrl = TextEditingController();
    _phoneCtrl = TextEditingController(
        text: storage.getUserMobile() ?? '');
    _whatsappCtrl = TextEditingController(
        text: storage.getUserMobile() ?? '');
    _emailCtrl = TextEditingController(
        text: storage.getUserEmail() ?? '');
    _cityCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _experienceCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _categoryCtrl.dispose();
    _contactPersonCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _priceCtrl.dispose();
    _experienceCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
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
          'Edit Business Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo / Avatar Picker
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2.5),
                      ),
                      child: ClipOval(
                        child: CachedImageView(
                          imageUrl: AppImages.vendorRoyalClick,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.camera_alt,
                          iconColor: AppColors.white,
                          iconSize: 40,
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: AppColors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo selector opened'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('Change Studio Cover / Logo',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'BASIC BUSINESS INFORMATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'Business / Studio Name',
                controller: _businessNameCtrl,
                icon: Icons.storefront_rounded,
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
              ),

              _buildCategorySelector(),

              _buildTextField(
                label: 'Owner / Contact Person',
                controller: _contactPersonCtrl,
                icon: Icons.person_outline_rounded,
              ),

              _buildTextField(
                label: 'Phone Number (For Client Calls)',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              _buildTextField(
                label: 'WhatsApp Number (For Direct Chats)',
                controller: _whatsappCtrl,
                icon: Icons.chat_bubble_outline_rounded,
                keyboardType: TextInputType.phone,
              ),

              _buildTextField(
                label: 'Business Email',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              _buildTextField(
                label: 'Cities & Service Regions Covered',
                controller: _cityCtrl,
                icon: Icons.location_on_outlined,
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Starting Package',
                      controller: _priceCtrl,
                      icon: Icons.currency_rupee_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Experience',
                      controller: _experienceCtrl,
                      icon: Icons.workspace_premium_outlined,
                    ),
                  ),
                ],
              ),

              _buildTextField(
                label: 'About Studio / Description',
                controller: _bioCtrl,
                icon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              const Text(
                'SPECIALTIES & HIGHLIGHTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _specialties.map((spec) {
                  final isSelected = _selectedSpecialties.contains(spec);
                  return FilterChip(
                    label: Text(
                      spec,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.darkGrey,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.white,
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.grey.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.darkGrey,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSpecialties.add(spec);
                        } else {
                          _selectedSpecialties.remove(spec);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // In-Person Payment Reminder Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.handshake_rounded,
                        color: AppColors.success, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Direct In-Person Settlements: You retain 100% of client payments with zero platform commission deductions.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.black,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.grey.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.grey.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = Get.isRegistered<CategoryController>()
        ? CategoryController.to.serviceCategories
        : <ServiceCategoryItem>[];

    ServiceCategoryItem? currentItem;
    for (final c in categories) {
      if (c.title.toLowerCase().trim() ==
          _categoryCtrl.text.toLowerCase().trim()) {
        currentItem = c;
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category_rounded,
                  size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Primary Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _openCategoryPicker(categories),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.2), width: 1.2),
              ),
              child: Row(
                children: [
                  if (currentItem != null)
                    ServiceIconWrap(
                      item: currentItem,
                      size: 38,
                      iconSize: 18,
                      borderRadius: 10,
                    )
                  else
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _categoryCtrl.text.isNotEmpty
                              ? _categoryCtrl.text
                              : (currentItem?.title ?? 'Select Category'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        if (currentItem != null && currentItem.desc.isNotEmpty)
                          Text(
                            currentItem.desc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCategoryPicker(List<ServiceCategoryItem> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Select Business Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storefront_outlined,
                                size: 40, color: AppColors.grey),
                            const SizedBox(height: 12),
                            const Text(
                              'No categories available from server',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () async {
                                if (Get.isRegistered<CategoryController>()) {
                                  await CategoryController.to.fetchCategories(
                                      forceRefresh: true);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    setState(() {});
                                  }
                                }
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: categories.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    final isSelected = item.title.toLowerCase().trim() ==
                        _categoryCtrl.text.toLowerCase().trim();

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _categoryCtrl.text = item.title;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? item.bgColor : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? item.color
                                : AppColors.greyLight.withValues(alpha: 0.6),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            ServiceIconWrap(
                              item: item,
                              size: 42,
                              iconSize: 20,
                              borderRadius: 12,
                              isSelected: isSelected,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  Text(
                                    item.desc,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                  color: item.color, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

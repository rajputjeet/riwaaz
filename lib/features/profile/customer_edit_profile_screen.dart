import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/helper/storage_helper.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _partnerCtrl;
  late TextEditingController _eventCityCtrl;
  late TextEditingController _eventDateCtrl;
  late TextEditingController _guestCountCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _budgetCtrl;

  String _eventType = 'Wedding & Reception';
  final List<String> _eventTypes = [
    'Wedding & Reception',
    'Engagement & Roka',
    'Sangeet & Mehendi Night',
    'Cocktail & Gala Night',
    'Birthday & Anniversary Party',
  ];

  @override
  void initState() {
    super.initState();
    final storage = StorageHelper();
    _nameCtrl = TextEditingController(
        text: storage.getUserName() ?? '');
    _partnerCtrl = TextEditingController();
    _eventCityCtrl = TextEditingController();
    _eventDateCtrl = TextEditingController();
    _guestCountCtrl = TextEditingController();
    _phoneCtrl = TextEditingController(
        text: storage.getUserMobile() ?? '');
    _emailCtrl = TextEditingController(
        text: storage.getUserEmail() ?? '');
    _budgetCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _partnerCtrl.dispose();
    _eventCityCtrl.dispose();
    _eventDateCtrl.dispose();
    _guestCountCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 12, 28),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      setState(() {
        _eventDateCtrl.text =
            '${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wedding profile saved successfully!'),
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
          'Edit Profile',
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
              // Avatar
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.favorite_rounded,
                          color: AppColors.gold, size: 44),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: AppColors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'COUPLE & CELEBRATION DETAILS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Your Name',
                      controller: _nameCtrl,
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: "Partner's Name",
                      controller: _partnerCtrl,
                      icon: Icons.favorite_outline_rounded,
                    ),
                  ),
                ],
              ),

              // Event Type Choice Chips
              const Text(
                'Celebration Type',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _eventTypes.map((type) {
                  final isSelected = _eventType == type;
                  return ChoiceChip(
                    label: Text(
                      type,
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
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.darkGrey,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _eventType = type);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Event Date with Picker
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    label: 'Wedding / Event Date',
                    controller: _eventDateCtrl,
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
              ),

              _buildTextField(
                label: 'Event City & Venue Region',
                controller: _eventCityCtrl,
                icon: Icons.location_on_outlined,
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Expected Guests',
                      controller: _guestCountCtrl,
                      icon: Icons.people_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Total Event Budget',
                      controller: _budgetCtrl,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'CONTACT INFORMATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              _buildTextField(
                label: 'Email Address',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
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
}

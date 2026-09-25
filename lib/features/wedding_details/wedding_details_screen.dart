import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../shell/main_shell.dart';

class WeddingDetailsScreen extends StatefulWidget {
  const WeddingDetailsScreen({super.key});

  @override
  State<WeddingDetailsScreen> createState() => _WeddingDetailsScreenState();
}

class _WeddingDetailsScreenState extends State<WeddingDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _formController;

  String _selectedWeddingType = 'Wedding';
  DateTime _selectedDate = DateTime(2026, 12, 28);
  String _selectedLocation = 'Mohali, Punjab';
  double _guestCount = 500;
  double _budget = 500000;

  final List<String> _weddingTypes = [
    'Wedding',
    'Engagement',
    'Reception',
    'Sangeet',
    'Haldi',
  ];

  @override
  void initState() {
    super.initState();
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      FadeScaleRoute(page: const MainShell(initialIndex: 0)),
    );
  }

  String _formatBudget(double val) {
    if (val >= 100000) {
      return '₹${(val / 100000).toStringAsFixed(1)}L';
    }
    return '₹${val.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top decorative header
          _buildTopDecoration(),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 100),
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 24),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 200),
                          child: _buildWeddingTypeSelector(),
                        ),
                        const SizedBox(height: 16),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 300),
                          child: _buildDatePicker(),
                        ),
                        const SizedBox(height: 16),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 400),
                          child: _buildLocationPicker(),
                        ),
                        const SizedBox(height: 16),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 500),
                          child: _buildGuestSlider(),
                        ),
                        const SizedBox(height: 16),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 600),
                          child: _buildBudgetSlider(),
                        ),
                        const SizedBox(height: 32),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 700),
                          child: _buildContinueButton(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDecoration() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 140,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          AnimatedTapWidget(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.35),
              ),
            ),
            child: const Text(
              'Event Setup',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's Plan Your Event",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tell us about your event details',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.secondary.withValues(alpha: 0.85),
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.darkGrey,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildWeddingTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Event Type'),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0D5C8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedWeddingType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.expand_more, color: AppColors.primary),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
              items: _weddingTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedWeddingType = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Wedding Date'),
        AnimatedTapWidget(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: AppColors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0D5C8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.expand_more, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Location'),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0D5C8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.expand_more, color: AppColors.primary),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
              items: [
                'Mohali, Punjab',
                'Chandigarh',
                'Delhi, NCR',
                'Mumbai',
                'Jaipur',
                'Bengaluru',
              ]
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedLocation = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel('Expected Guests'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_guestCount.toInt()} Guests',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.cream,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: _guestCount,
            min: 50,
            max: 2000,
            divisions: 39,
            onChanged: (v) => setState(() => _guestCount = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50', style: AppTextStyles.labelSmall),
              Text('2000+', style: AppTextStyles.labelSmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel('Your Budget'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatBudget(_budget),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: const Color(0xFFEADBCE),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: _budget,
            min: 100000,
            max: 5000000,
            divisions: 49,
            onChanged: (v) => setState(() => _budget = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹1L', style: AppTextStyles.labelSmall),
              Text('₹50L+', style: AppTextStyles.labelSmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return AnimatedTapWidget(
      onTap: _navigateToDashboard,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';
import '../auth/controllers/auth_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../explore/explore_screen.dart';
import '../auth/login_screen.dart';
import '../wedding_details/wedding_details_screen.dart';
import '../../core/services/booking_service.dart';
import '../profile/customer_edit_profile_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/saved_vendors_screen.dart';
import '../../data/api_provider/user_api_provider.dart';
import '../../data/api_provider/cms_api_provider.dart';
import '../../data/api_provider/faq_api_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/cms_model.dart';
import '../../data/models/faq_model.dart';
import '../../data/shared/data_response.dart';
import '../../shared/widgets/app_states.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../shared/widgets/app_html_content_view.dart';
import '../../shared/widgets/app_support_sheet.dart';
import '../../shared/widgets/app_confirmation_dialog.dart';
import '../../shared/screens/account_deletion_request_screen.dart';

/// The main navigation shell — holds all customer tabs in an [IndexedStack]
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final _customerProfileKey = GlobalKey<_CustomerProfileTabState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 3) {
      AppBookingService.instance.fetchCustomerBookings(silent: true);
    } else if (index == 4) {
      _customerProfileKey.currentState?.loadProfile(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand,
        children: [
          DashboardBody(onNavigateTab: (index) => _onTabTap(index)),
          const ExploreBody(),
          const _CustomerWeddingTab(),
          const _CustomerBookingsTab(),
          _CustomerProfileTab(key: _customerProfileKey),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const barHeight = 62.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Bottom Row with 5 navigation slots
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 1,
                      icon: Icons.explore_rounded,
                      label: 'Explore',
                    ),
                  ),
                  // Center slot with label beneath the floating button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onTabTap(2),
                      behavior: HitTestBehavior.opaque,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'My Event',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: _currentIndex == 2
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: _currentIndex == 2
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 3,
                      icon: Icons.calendar_month_rounded,
                      label: 'Bookings',
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 4,
                      icon: Icons.person_rounded,
                      label: 'Profile',
                    ),
                  ),
                ],
              ),

              // Large prominent floating center icon overlapping the top of the bar
              Positioned(
                top: -20,
                child: GestureDetector(
                  onTap: () => _onTabTap(2),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      border: Border.all(color: AppColors.white, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.38),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _currentIndex == 2
                            ? Icons.celebration_rounded
                            : Icons.favorite_rounded,
                        color: AppColors.secondary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTap(index),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Customer Wedding Tab ───────────────────────────────────────────────────

class _CustomerWeddingTab extends StatefulWidget {
  const _CustomerWeddingTab();

  @override
  State<_CustomerWeddingTab> createState() => _CustomerWeddingTabState();
}

class _CustomerWeddingTabState extends State<_CustomerWeddingTab> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _events = StorageHelper().getWeddingEvents() ?? [];
    });
  }

  void _saveEvents() {
    StorageHelper().saveWeddingEvents(_events);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  @override
  Widget build(BuildContext context) {
    final savedDateStr = StorageHelper().getWeddingDate();
    final weddingDate =
        (savedDateStr != null && DateTime.tryParse(savedDateStr) != null)
        ? DateTime.parse(savedDateStr)
        : null;
    final now = DateTime.now();
    final diff = weddingDate?.difference(now);
    final days = (diff != null && !diff.isNegative) ? diff.inDays : 0;
    final hours = (diff != null && !diff.isNegative) ? (diff.inHours % 24) : 0;
    final mins = (diff != null && !diff.isNegative) ? (diff.inMinutes % 60) : 0;

    final savedLoc = StorageHelper().getWeddingLocation();
    final location = (savedLoc != null && savedLoc.isNotEmpty)
        ? savedLoc
        : 'Chandigarh';
    final dateDisplay = weddingDate != null
        ? '${weddingDate.day} ${_getMonthName(weddingDate.month)} ${weddingDate.year}'
        : 'Set Wedding Date';
    final userName = StorageHelper().getUserName()?.trim().isNotEmpty == true
        ? StorageHelper().getUserName()!
        : 'Your Event';

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Event Plan 💍',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$userName • $dateDisplay • $location',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  onPressed: () async {
                    await Navigator.of(
                      context,
                    ).push(FadeScaleRoute(page: const WeddingDetailsScreen()));
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Countdown Card
            GestureDetector(
              onTap: () async {
                await Navigator.of(
                  context,
                ).push(FadeScaleRoute(page: const WeddingDetailsScreen()));
                if (mounted) setState(() {});
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'COUNTDOWN TO THE BIG DAY',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (weddingDate != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTimerBlock('$days', 'DAYS'),
                          _buildTimerBlock('$hours', 'HOURS'),
                          _buildTimerBlock('$mins', 'MINS'),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tap to set wedding date',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Event Schedule',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddEventSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Event'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_events.isEmpty)
              AppEmptyState(
                icon: Icons.event_note_rounded,
                title: 'No Events Scheduled',
                subtitle:
                    'Add your Sangeet, Mehendi, Haldi, or Reception ceremonies to plan your schedule.',
                actionLabel: 'Add Function',
                onAction: () => _showAddEventSheet(context),
              )
            else
              ..._events.asMap().entries.map((entry) {
                final idx = entry.key;
                final ev = entry.value;
                return _buildEventRow(
                  context,
                  ev['title']?.toString() ?? 'Event',
                  ev['date']?.toString() ?? '',
                  ev['time']?.toString() ?? '',
                  ev['location']?.toString() ?? '',
                  Icons.favorite_rounded,
                  AppColors.primary,
                  onDelete: () {
                    setState(() {
                      _events.removeAt(idx);
                    });
                    _saveEvents();
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAddEventSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: '28 Dec 2026');
    final timeCtrl = TextEditingController(text: '7:00 PM');
    final venueCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Wedding Function',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Event Name (e.g. Cocktail Night)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateCtrl,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: timeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: venueCtrl,
                decoration: InputDecoration(
                  labelText: 'Venue Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final newTitle = titleCtrl.text.trim();
                    if (newTitle.isEmpty) return;
                    final newEvent = {
                      'title': newTitle,
                      'date': dateCtrl.text.trim(),
                      'time': timeCtrl.text.trim(),
                      'location': venueCtrl.text.trim().isEmpty
                          ? 'Chandigarh'
                          : venueCtrl.text.trim(),
                    };
                    setState(() {
                      _events.add(newEvent);
                    });
                    _saveEvents();
                    Navigator.pop(ctx);
                    Utils.showSuccess('Added $newTitle to Schedule!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBlock(String val, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            val,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.cream,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showEventDetailsSheet(
    BuildContext context,
    String title,
    String date,
    String time,
    String location,
    IconData icon,
    Color iconColor, {
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$date • $time',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location.isEmpty ? 'Venue To Be Finalized' : location,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (onDelete != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onDelete();
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (onDelete != null) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(
    BuildContext context,
    String title,
    String date,
    String time,
    String location,
    IconData icon,
    Color iconColor, {
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: () => _showEventDetailsSheet(
        context,
        title,
        date,
        time,
        location,
        icon,
        iconColor,
        onDelete: onDelete,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$date • $time',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Customer Bookings Tab ──────────────────────────────────────────────────

class _CustomerBookingsTab extends StatefulWidget {
  const _CustomerBookingsTab();

  @override
  State<_CustomerBookingsTab> createState() => _CustomerBookingsTabState();
}

class _CustomerBookingsTabState extends State<_CustomerBookingsTab> {
  int _selectedFilter = 0;
  String? _cancellingBookingId;

  @override
  void initState() {
    super.initState();
    AppBookingService.instance.addListener(_onBookingsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppBookingService.instance.fetchCustomerBookings(silent: true);
    });
  }

  @override
  void dispose() {
    AppBookingService.instance.removeListener(_onBookingsChanged);
    super.dispose();
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  int get _allCount => AppBookingService.instance.allCount;
  int get _pendingCount => AppBookingService.instance.pendingCount;
  int get _upcomingCount => AppBookingService.instance.upcomingCount;
  int get _completedCount => AppBookingService.instance.completedCount;
  int get _cancelledCount => AppBookingService.instance.cancelledCount;

  List<Map<String, dynamic>> get _filteredBookings =>
      AppBookingService.instance.customerBookingsForFilter(_selectedFilter);

  String _formatCustomerEventDate(String value) {
    final datePart = value.split('T').first.trim();
    final parsed = DateTime.tryParse(datePart);
    if (parsed == null) return datePart;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  Future<void> _callVendor(String? phone) async {
    final digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      Utils.showError('Vendor phone number is not available.');
      return;
    }

    final dialNumber = (phone?.trim().startsWith('+') ?? false)
        ? '+$digits'
        : digits;
    try {
      final opened = await launchUrl(
        Uri(scheme: 'tel', path: dialNumber),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) Utils.showError('Unable to open the phone dialer.');
    } catch (_) {
      Utils.showError('Unable to open the phone dialer.');
    }
  }

  Future<void> _openVendorWhatsApp(String? phone) async {
    var digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.length == 10) digits = '91$digits';
    if (digits.length == 11 && digits.startsWith('0')) {
      digits = '91${digits.substring(1)}';
    }
    if (digits.isEmpty) {
      Utils.showError('Vendor phone number is not available.');
      return;
    }

    try {
      final appUri = Uri(
        scheme: 'whatsapp',
        host: 'send',
        queryParameters: {'phone': digits},
      );
      if (await launchUrl(appUri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}

    try {
      final webUri = Uri.https('wa.me', '/$digits');
      if (await launchUrl(webUri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    Utils.showError('Unable to open WhatsApp.');
  }

  Future<void> _cancelConfirmedBooking(Map<String, dynamic> booking) async {
    final bookingId =
        ((booking['id'] as String?) ?? (booking['bookingId'] as String?) ?? '')
            .trim();
    if (bookingId.isEmpty || _cancellingBookingId != null) return;

    final shouldCancel = await AppConfirmationDialog.show(
      context: context,
      icon: Icons.event_busy_outlined,
      title: 'Cancel booking?',
      message: 'You can cancel at least 72 hours before the event.',
      confirmLabel: 'Cancel booking',
      cancelLabel: 'Keep booking',
      isDestructive: true,
    );
    if (shouldCancel != true || !mounted) return;

    setState(() => _cancellingBookingId = bookingId);
    final response = await AppBookingService.instance.cancelCustomerBooking(
      bookingId: bookingId,
      reason: 'Cancelled by customer',
    );
    if (!mounted) return;
    setState(() => _cancellingBookingId = null);

    if (response.isSuccess == true) {
      Utils.showSuccess('Booking cancelled successfully.');
      await AppBookingService.instance.fetchCustomerBookings(silent: true);
    } else {
      Utils.showError(response.message ?? 'Unable to cancel this booking.');
    }
  }

  void _showBookingDetailsSheet(BuildContext context, Map<String, dynamic> b) {
    final name = (b['name'] as String?) ?? '';
    final vendorEmail = (b['vendorEmail'] as String?)?.trim() ?? '';
    final vendorPhone =
        ((b['vendorPhone'] as String?) ?? (b['phone'] as String?) ?? '').trim();
    final status = (b['status'] as String?) ?? 'Pending';
    final package = (b['package'] as String?) ?? '';
    final date = (b['date'] as String?) ?? '';
    final time = (b['time'] as String?) ?? '';
    final venue = (b['venue'] as String?) ?? '';
    final rawTotal = (b['total'] as String?)?.trim() ?? '';
    final total = rawTotal.isEmpty || rawTotal == '—' ? 'N/A' : rawTotal;
    final bookingId =
        ((b['bookingId'] as String?) ?? (b['id'] as String?) ?? '').trim();
    final statusColor = bookingStatusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                children: [
                  const Expanded(
                    child: Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          bookingStatusIcon(status),
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _bookingDetailRow(
                        'Booking ID',
                        bookingId.isEmpty ? 'N/A' : bookingId,
                      ),
                      _bookingDetailRow(
                        'Vendor',
                        name.trim().isEmpty ? 'N/A' : name.trim(),
                      ),
                      _bookingDetailRow(
                        'Email',
                        vendorEmail.isEmpty ? 'N/A' : vendorEmail,
                      ),
                      _bookingDetailRow(
                        'Phone',
                        vendorPhone.isEmpty ? 'N/A' : vendorPhone,
                      ),
                      _bookingDetailRow(
                        'Service / Package',
                        package.trim().isEmpty ? 'N/A' : package.trim(),
                      ),
                      _bookingDetailRow(
                        'Event date',
                        date.trim().isEmpty ? 'N/A' : date,
                      ),
                      _bookingDetailRow(
                        'Event time',
                        time.trim().isEmpty ? 'N/A' : time,
                      ),
                      _bookingDetailRow(
                        'Event location',
                        venue.trim().isEmpty ? 'N/A' : venue,
                      ),
                      _bookingDetailRow('Price', total, emphasize: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookingDetailRow(
    String label,
    String value, {
    bool emphasize = false,
  }) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: emphasize ? 15 : 13,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color: emphasize ? AppColors.primary : AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;
    final isLoading = AppBookingService.instance.isLoading;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => AppBookingService.instance.fetchCustomerBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'View your booked services and packages',
                    style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Filter Tabs (Same as in vendor showing)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('All ($_allCount)'),
                      selected: _selectedFilter == 0,
                      onSelected: (_) => setState(() => _selectedFilter = 0),
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      elevation: _selectedFilter == 0 ? 1 : 0,
                      side: BorderSide(
                        color: _selectedFilter == 0
                            ? AppColors.primary
                            : AppColors.grey.withValues(alpha: 0.22),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: TextStyle(
                        color: _selectedFilter == 0
                            ? AppColors.white
                            : AppColors.darkGrey,
                        fontWeight: _selectedFilter == 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      backgroundColor: AppColors.white,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: _pendingCount > 0
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _selectedFilter == 1
                                    ? AppColors.white
                                    : const Color(0xFFD97706),
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      label: Text('Pending ($_pendingCount)'),
                      selected: _selectedFilter == 1,
                      onSelected: (_) => setState(() => _selectedFilter = 1),
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      elevation: _selectedFilter == 1 ? 1 : 0,
                      side: BorderSide(
                        color: _selectedFilter == 1
                            ? AppColors.primary
                            : AppColors.grey.withValues(alpha: 0.22),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: TextStyle(
                        color: _selectedFilter == 1
                            ? AppColors.white
                            : AppColors.darkGrey,
                        fontWeight: _selectedFilter == 1
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      backgroundColor: AppColors.white,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Upcoming ($_upcomingCount)'),
                      selected: _selectedFilter == 2,
                      onSelected: (_) => setState(() => _selectedFilter = 2),
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      elevation: _selectedFilter == 2 ? 1 : 0,
                      side: BorderSide(
                        color: _selectedFilter == 2
                            ? AppColors.primary
                            : AppColors.grey.withValues(alpha: 0.22),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: TextStyle(
                        color: _selectedFilter == 2
                            ? AppColors.white
                            : AppColors.darkGrey,
                        fontWeight: _selectedFilter == 2
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      backgroundColor: AppColors.white,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Completed ($_completedCount)'),
                      selected: _selectedFilter == 3,
                      onSelected: (_) => setState(() => _selectedFilter = 3),
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      elevation: _selectedFilter == 3 ? 1 : 0,
                      side: BorderSide(
                        color: _selectedFilter == 3
                            ? AppColors.primary
                            : AppColors.grey.withValues(alpha: 0.22),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: TextStyle(
                        color: _selectedFilter == 3
                            ? AppColors.white
                            : AppColors.darkGrey,
                        fontWeight: _selectedFilter == 3
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      backgroundColor: AppColors.white,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Cancelled ($_cancelledCount)'),
                      selected: _selectedFilter == 4,
                      onSelected: (_) => setState(() => _selectedFilter = 4),
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      elevation: _selectedFilter == 4 ? 1 : 0,
                      side: BorderSide(
                        color: _selectedFilter == 4
                            ? AppColors.primary
                            : AppColors.grey.withValues(alpha: 0.22),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: TextStyle(
                        color: _selectedFilter == 4
                            ? AppColors.white
                            : AppColors.darkGrey,
                        fontWeight: _selectedFilter == 4
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      backgroundColor: AppColors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Booked Vendors Cards or Empty State
              if (isLoading && bookings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 12),
                      Text(
                        'Loading your bookings...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (bookings.isEmpty)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 220),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.event_busy_rounded,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No Bookings Found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFilter == 0
                            ? "You haven't booked any vendors yet."
                            : "No ${_selectedFilter == 1
                                  ? 'pending'
                                  : _selectedFilter == 2
                                  ? 'upcoming'
                                  : _selectedFilter == 3
                                  ? 'completed'
                                  : 'cancelled'} bookings found.",
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...bookings.map((v) {
                  final String status = (v['status'] as String?) ?? 'Confirmed';
                  final bool isAccepted =
                      status.toLowerCase() == 'confirmed' ||
                      status.toLowerCase() == 'accepted' ||
                      status.toLowerCase() == 'approved';
                  final statusColor = bookingStatusColor(status);
                  final String package = (v['package'] as String?) ?? '';
                  final String vendorName =
                      (v['name'] as String?) ??
                      (v['vendorName'] as String?) ??
                      'Vendor';
                  final String? vendorProfileImg =
                      (v['vendorProfileImg'] as String?)?.trim();
                  final String total = (v['total'] as String?) ?? '';
                  final String rawEventDate =
                      (v['date'] as String?)?.trim() ?? '';
                  final String eventDate = rawEventDate.isEmpty
                      ? 'Event Day'
                      : _formatCustomerEventDate(rawEventDate);
                  final String eventTime = (v['time'] as String?)?.trim() ?? '';
                  final String displayBookingId =
                      ((v['bookingId'] as String?) ??
                              (v['id'] as String?) ??
                              '')
                          .trim();
                  final String bookingId =
                      ((v['id'] as String?) ??
                              (v['bookingId'] as String?) ??
                              '')
                          .trim();
                  final String vendorPhone =
                      (v['vendorPhone'] as String?) ??
                      (v['phone'] as String?) ??
                      '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CachedImageView(
                                    imageUrl: vendorProfileImg,
                                    width: 46,
                                    height: 46,
                                    isCircle: true,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    fallbackIcon: Icons.storefront_rounded,
                                    iconColor: AppColors.primary,
                                    iconSize: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (displayBookingId.isNotEmpty)
                                          Text(
                                            displayBookingId,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        const SizedBox(height: 3),
                                        Text(
                                          vendorName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    bookingStatusIcon(status),
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.045),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: AppColors.goldDark,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  package.isEmpty
                                      ? 'Service / Package'
                                      : package,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Divider(
                          height: 1,
                          color: statusColor.withValues(alpha: 0.12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              eventDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (eventTime.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  eventTime,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                (v['venue'] as String?)?.trim().isNotEmpty ==
                                        true
                                    ? (v['venue'] as String).trim()
                                    : 'N/A',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Booking total',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                total.isEmpty ? 'N/A' : total,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAccepted) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _callVendor(vendorPhone),
                                    icon: const Icon(
                                      Icons.call_rounded,
                                      size: 14,
                                    ),
                                    label: const Text('Call Vendor'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _openVendorWhatsApp(vendorPhone),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.phone_android_rounded,
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'WhatsApp',
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showBookingDetailsSheet(context, v),
                              icon: const Icon(
                                Icons.receipt_long_outlined,
                                size: 16,
                              ),
                              label: const Text('View booking details'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: _cancellingBookingId == null
                                  ? () => _cancelConfirmedBooking(v)
                                  : null,
                              icon: _cancellingBookingId == bookingId
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.cancel_outlined, size: 16),
                              label: Text(
                                _cancellingBookingId == bookingId
                                    ? 'Cancelling…'
                                    : 'Cancel booking',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE11D48),
                                side: const BorderSide(
                                  color: Color(0xFFE11D48),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Customer Profile Tab ───────────────────────────────────────────────────

class _CustomerProfileTab extends StatefulWidget {
  const _CustomerProfileTab({super.key});

  @override
  State<_CustomerProfileTab> createState() => _CustomerProfileTabState();
}

class _CustomerProfileTabState extends State<_CustomerProfileTab> {
  final _userApi = UserApiProvider();
  final _cmsApi = CmsApiProvider();
  final _faqApi = FaqApiProvider();

  UserModel? _profile;
  bool _isLoading = true;
  bool _isNoInternet = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile({bool silent = false}) async {
    if (!mounted) return;
    if (!silent && _profile == null) {
      setState(() {
        _isLoading = true;
        _isNoInternet = false;
        _errorMsg = null;
      });
    } else {
      // Instantly trigger re-render with latest stored credentials
      setState(() {});
    }

    try {
      final res = await _userApi.getProfile();
      if (!mounted) return;
      if (res.isSuccess == true) {
        setState(() {
          _profile = res.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final isNet =
          e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('network');
      setState(() {
        if (_profile == null) {
          _isNoInternet = isNet;
          _errorMsg = isNet ? null : 'Something went wrong. Please try again.';
        }
        _isLoading = false;
      });
    }
  }

  String get _displayName {
    final stored = StorageHelper().getUserName();
    if (stored?.trim().isNotEmpty == true) return stored!.trim();
    if (_profile?.fullName?.trim().isNotEmpty == true)
      return _profile!.fullName!.trim();
    return 'Customer';
  }

  String get _displayContact {
    final email = StorageHelper().getUserEmail();
    if (email?.trim().isNotEmpty == true) return email!.trim();
    if (_profile?.email?.trim().isNotEmpty == true)
      return _profile!.email!.trim();
    final mobile = StorageHelper().getUserMobile();
    if (mobile?.trim().isNotEmpty == true) return mobile!.trim();
    if (_profile?.mobile?.trim().isNotEmpty == true)
      return _profile!.mobile!.trim();
    return 'Event Organizer';
  }

  void _showChecklistSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(20),
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
                const Text(
                  'Wedding Checklist & Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const Text(
              'Track your preparations and milestones',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            const Expanded(
              child: AppEmptyState(
                icon: Icons.checklist_rounded,
                title: 'No Checklist Tasks',
                subtitle:
                    'You haven\'t added any event planning tasks yet. Custom milestones will appear here.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(20),
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
                const Text(
                  'Wedding Budget Planner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const Text(
              'Manage and allocate funds across all vendor categories',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            const Expanded(
              child: AppEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No Budget Items Added',
                subtitle:
                    'Start allocating your celebration budget across photography, venues, catering and more.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFaqSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
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
                Row(
                  children: const [
                    Icon(
                      Icons.help_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'FAQs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const Text(
              'Frequently Asked Questions • Widoora Help Center',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<List<FaqModel>>>(
                future: _faqApi.getFaqList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(message: 'Loading FAQs...');
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final response = snapshot.data;
                  if (response == null || response.isSuccess != true) {
                    return AppErrorState(
                      message:
                          response?.message ??
                          'Could not load FAQs. Please try again.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final faqs = response.data ?? [];
                  if (faqs.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.help_outline_rounded,
                      title: 'No FAQs Available',
                      subtitle:
                          'Frequently asked questions will appear here shortly.',
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: faqs.length,
                    itemBuilder: (context, i) {
                      final faq = faqs[i];
                      return _FaqTile(
                        question: faq.question ?? 'FAQ',
                        answer: faq.answer ?? '',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicySheet(BuildContext context) {
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
                    children: const [
                      Icon(
                        Icons.privacy_tip_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
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
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const Text(
              'Official Platform Privacy Policy',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<CmsModel>>(
                future: _cmsApi.getCmsData('privacy'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(
                      message: 'Loading Privacy Policy...',
                    );
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
                      message:
                          response?.message ?? 'Could not load Privacy Policy.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy Pending',
                      subtitle:
                          'The privacy terms will appear here once published by admin.',
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

  void _showTermsOfServiceSheet(BuildContext context) {
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
                    children: const [
                      Icon(
                        Icons.gavel_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
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
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const Text(
              'Platform Usage Agreement • Customer Terms',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<CmsModel>>(
                future: _cmsApi.getCmsData('terms'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(
                      message: 'Loading Terms of Service...',
                    );
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
                      message:
                          response?.message ??
                          'Could not load Terms of Service.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.gavel_rounded,
                      title: 'Terms of Service Pending',
                      subtitle:
                          'The terms and conditions will appear here once published by admin.',
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

  void _showCancellationPolicySheet(BuildContext context) {
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
                    children: const [
                      Icon(
                        Icons.assignment_return_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Cancellation Policy',
                          style: TextStyle(
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
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const Text(
              'Official Booking Cancellation & Direct Refund Guidelines',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder<DataResponse<CmsModel>>(
                future: _cmsApi.getCmsData('refund'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(
                      message: 'Loading Cancellation Policy...',
                    );
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
                      message:
                          response?.message ??
                          'Could not load Cancellation Policy.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.assignment_return_outlined,
                      title: 'Cancellation Policy Pending',
                      subtitle:
                          'The cancellation policy will appear here once published by admin.',
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

  void _showSupportSheet(BuildContext context) {
    AppSupportSheet.show(
      context,
      isVendor: false,
      onOpenFaq: () => _showFaqSheet(context),
    );
  }

  void _openChangePasswordScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(FadeScaleRoute(page: const ChangePasswordScreen(isVendor: false)));
  }

  void _showLogoutDialog(BuildContext context) {
    AppConfirmationDialog.show(
      context: context,
      icon: Icons.logout_rounded,
      iconColor: AppColors.primary,
      iconBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
      title: 'Log Out?',
      message: 'You can sign back in anytime to continue using Widoora.',
      confirmLabel: 'Log Out',
      cancelLabel: 'Cancel',
      confirmColor: AppColors.primary,
      onConfirm: () async {
        if (Get.isRegistered<AuthController>()) {
          await Get.find<AuthController>().logout();
        } else {
          await StorageHelper().clearAllData();
        }
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          FadeScaleRoute(page: const LoginScreen()),
          (route) => false,
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    String? requestMessage;
    final deleted = await AccountDeletionRequestScreen.show(
      context: context,
      isVendor: false,
      onSubmit: (reason, description) async {
        final response = await _userApi.deleteAccount(
          reason: reason,
          description: description,
        );
        if (response.isSuccess == true) {
          requestMessage = response.message;
          return null;
        }
        return response.message ??
            response.error ??
            'Unable to submit your deletion request. Please try again.';
      },
    );
    if (deleted != true) return;
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().logout();
    } else {
      await StorageHelper().clearAllData();
    }
    if (!context.mounted) return;
    Utils.showSuccess(
      requestMessage?.trim().isNotEmpty == true
          ? requestMessage!.trim()
          : 'Your account deletion request has been submitted.',
    );
    Navigator.of(context).pushAndRemoveUntil(
      FadeScaleRoute(page: const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isNoInternet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppNoInternetState(onRetry: loadProfile),
      );
    }

    if (_errorMsg != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppErrorState(message: _errorMsg!, onRetry: loadProfile),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: AppLoadingState(message: 'Loading profile...'),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadProfile,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold, width: 2),
                          ),
                          child: ClipOval(
                            child:
                                ((_profile?.profileImgUrl != null &&
                                        _profile!.profileImgUrl!.isNotEmpty) ||
                                    (StorageHelper().getUserProfileImg() !=
                                            null &&
                                        StorageHelper()
                                            .getUserProfileImg()!
                                            .isNotEmpty))
                                ? CachedImageView(
                                    imageUrl:
                                        StorageHelper().getUserProfileImg() ??
                                        _profile?.profileImgUrl ??
                                        '',
                                    fit: BoxFit.cover,
                                    width: 72,
                                    height: 72,
                                    isCircle: true,
                                    fallbackIcon: Icons.favorite_rounded,
                                  )
                                : const CircleAvatar(
                                    radius: 36,
                                    backgroundColor: AppColors.primary,
                                    child: Icon(
                                      Icons.favorite_rounded,
                                      color: AppColors.gold,
                                      size: 36,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _displayContact,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final updated = await Navigator.of(context).push<bool>(
                          FadeScaleRoute(
                            page: const CustomerEditProfileScreen(),
                          ),
                        );
                        if (updated == true || mounted) {
                          loadProfile();
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'PROFILE MANAGEMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 10),

              _buildActionItem(
                context: context,
                icon: Icons.edit_note_rounded,
                title: 'Profile',
                subtitle: 'Update names, celebration date, city & guest count',
                onTap: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    FadeScaleRoute(page: const CustomerEditProfileScreen()),
                  );
                  if (updated == true || mounted) {
                    loadProfile();
                  }
                },
              ),
              _buildActionItem(
                context: context,
                icon: Icons.favorite_border_rounded,
                title: 'Saved Vendors',
                subtitle: 'View vendors you have saved',
                onTap: () => Navigator.of(
                  context,
                ).push(FadeScaleRoute(page: const SavedVendorsScreen())),
              ),
              const SizedBox(height: 18),

              const Text(
                'SECURITY & ACCOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 10),

              _buildActionItem(
                context: context,
                icon: Icons.lock_reset_rounded,
                title: 'Change Password',
                subtitle: 'Update your account security password',
                onTap: () => _openChangePasswordScreen(context),
              ),

              const SizedBox(height: 18),

              const Text(
                'LEGAL & POLICIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 10),

              _buildActionItem(
                context: context,
                icon: Icons.headset_mic_rounded,
                title: 'Help & Support',
                subtitle: 'Direct Call & WhatsApp assistance',
                onTap: () => _showSupportSheet(context),
              ),
              _buildActionItem(
                context: context,
                icon: Icons.gavel_rounded,
                title: 'Terms of Service',
                subtitle: 'Platform agreement & service terms',
                onTap: () => _showTermsOfServiceSheet(context),
              ),
              _buildActionItem(
                context: context,
                icon: Icons.assignment_return_outlined,
                title: 'Cancellation Policy',
                subtitle: 'Booking cancellation & refund guidelines',
                onTap: () => _showCancellationPolicySheet(context),
              ),
              _buildActionItem(
                context: context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Data protection & direct payment privacy',
                onTap: () => _showPrivacyPolicySheet(context),
              ),
              _buildActionItem(
                context: context,
                icon: Icons.help_outline_rounded,
                title: 'FAQs',
                subtitle: 'Frequently asked questions & help',
                onTap: () => _showFaqSheet(context),
              ),

              const SizedBox(height: 28),

              // ─── BOTTOM ACTIONS (LOGOUT & DELETE ACCOUNT) ───────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton.icon(
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  label: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Widoora v1.0.4',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.grey.withValues(alpha: 0.8),
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

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.grey,
        ),
      ),
    );
  }
}

/// Reusable expandable FAQ tile used by both customer and vendor profiles
class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.15)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.grey,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.darkGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

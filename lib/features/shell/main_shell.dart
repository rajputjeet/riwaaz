import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';
import '../auth/controllers/auth_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../explore/explore_screen.dart';
import '../auth/unified_login_screen.dart';
import '../wedding_details/wedding_details_screen.dart';
import '../service_listing/service_listing_screen.dart';
import '../../core/services/booking_service.dart';
import '../profile/customer_edit_profile_screen.dart';
import '../profile/change_password_screen.dart';
import '../notifications/customer_notifications_screen.dart';
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
    if (index == 4) {
      _customerProfileKey.currentState?.loadProfile(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand,
        children: [
          const DashboardBody(),
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
                      border: Border.all(
                        color: AppColors.white,
                        width: 3.5,
                      ),
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  @override
  Widget build(BuildContext context) {
    final savedDateStr = StorageHelper().getWeddingDate();
    final weddingDate = (savedDateStr != null && DateTime.tryParse(savedDateStr) != null)
        ? DateTime.parse(savedDateStr)
        : null;
    final now = DateTime.now();
    final diff = weddingDate?.difference(now);
    final days = (diff != null && !diff.isNegative) ? diff.inDays : 0;
    final hours = (diff != null && !diff.isNegative) ? (diff.inHours % 24) : 0;
    final mins = (diff != null && !diff.isNegative) ? (diff.inMinutes % 60) : 0;

    final savedLoc = StorageHelper().getWeddingLocation();
    final location = (savedLoc != null && savedLoc.isNotEmpty) ? savedLoc : 'Chandigarh';
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
                      style: const TextStyle(fontSize: 13, color: AppColors.darkGrey),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded,
                      color: AppColors.primary, size: 28),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      FadeScaleRoute(page: const WeddingDetailsScreen()),
                    );
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Countdown Card
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  FadeScaleRoute(page: const WeddingDetailsScreen()),
                );
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
                            Icon(Icons.calendar_month_rounded, color: AppColors.white, size: 20),
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
                subtitle: 'Add your Sangeet, Mehendi, Haldi, or Reception ceremonies to plan your schedule.',
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
                      'location': venueCtrl.text.trim().isEmpty ? 'Chandigarh' : venueCtrl.text.trim(),
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
                border: Border.all(color: AppColors.grey.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 18, color: AppColors.primary),
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
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.grey),
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

  @override
  void initState() {
    super.initState();
    AppBookingService.instance.addListener(_onBookingsChanged);
  }

  @override
  void dispose() {
    AppBookingService.instance.removeListener(_onBookingsChanged);
    super.dispose();
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  int get _totalCount => AppBookingService.instance.customerBookingsCount;
  int get _officeCount => AppBookingService.instance.officeCount;
  int get _partyCount => AppBookingService.instance.partyCount;
  int get _weddingCount => AppBookingService.instance.weddingCount;

  List<Map<String, dynamic>> get _filteredBookings =>
      AppBookingService.instance.customerBookingsForFilter(_selectedFilter);

  void _showBookingDetailsSheet(BuildContext context, Map<String, dynamic> b) {
    final name = (b['name'] as String?) ?? 'Vendor';
    final category = (b['category'] as String?) ?? '';
    final status = (b['status'] as String?) ?? 'Confirmed';
    final package = (b['package'] as String?) ?? '';
    final date = (b['date'] as String?) ?? '';
    final time = (b['time'] as String?) ?? '';
    final venue = (b['venue'] as String?) ?? '';
    final inclusions = ((b['inclusions'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
    final total = (b['total'] as String?) ?? '';
    final phone = (b['phone'] as String?) ?? '';
    final isAccepted = status == 'Confirmed' || status == 'Accepted';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(22),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAccepted
                        ? AppColors.successLight
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isAccepted
                          ? AppColors.success
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Package & Event Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('📅 Event Date: $date • $time',
                      style: const TextStyle(fontSize: 12, color: AppColors.black)),
                  const SizedBox(height: 4),
                  Text('📍 Location: $venue',
                      style: const TextStyle(fontSize: 12, color: AppColors.darkGrey)),
                  const SizedBox(height: 4),
                  Text(
                    isAccepted
                        ? '📞 Contact: $phone (Call & WhatsApp)'
                        : '🔒 Contact: Hidden until vendor accepts booking',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isAccepted ? FontWeight.w700 : FontWeight.w500,
                      color: isAccepted ? AppColors.black : AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Deliverables Included',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: inclusions.map((item) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pricing & In-Person Settlement',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Agreed Package:'),
                      Text(total,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Payment Mode:'),
                      Text('Pay In Person (Offline)',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.black)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('App Charges / Fees:'),
                      Text('₹0 (Direct Settlement)',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.handshake_rounded,
                            color: AppColors.success, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pay the vendor directly in person on the event day or upon agreement. Widoora does not charge fees or collect payments from users.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF166534),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (isAccepted)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Utils.showInfo('Calling $name ($phone)...');
                      },
                      icon: const Icon(Icons.phone_rounded, size: 16),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Utils.showSuccess('Opening WhatsApp with $name ($phone)...');
                      },
                      icon: const Icon(Icons.phone_android_rounded, size: 16),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_clock_rounded,
                        color: Color(0xFFD97706), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Booking awaiting acceptance. Direct Call & WhatsApp contact details will unlock automatically once confirmed.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;

    return SafeArea(
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
                  'Track booked vendors & in-person arrangements',
                  style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Summary KPI Strip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'EVENT BUDGET & BOOKINGS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_totalCount Vendors Hired 🎉',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Booked',
                              style: TextStyle(color: AppColors.cream, fontSize: 10),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppBookingService.instance.customerTotalBudgetFormatted,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: AppColors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Payment Mode',
                              style: TextStyle(color: AppColors.cream, fontSize: 10),
                            ),
                            SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Pay In-Person',
                                style: TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: AppColors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'App Advance',
                              style: TextStyle(color: AppColors.cream, fontSize: 10),
                            ),
                            SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '₹0 (Direct)',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.handshake_rounded, color: AppColors.goldLight, size: 14),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Direct in-person settlement • Zero app payments or commissions',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Filter Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text('All ($_totalCount)'),
                  selected: _selectedFilter == 0,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 0 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  onSelected: (_) => setState(() => _selectedFilter = 0),
                ),
                ChoiceChip(
                  label: Text('Office Parties ($_officeCount)'),
                  selected: _selectedFilter == 1,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 1 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  onSelected: (_) => setState(() => _selectedFilter = 1),
                ),
                ChoiceChip(
                  label: Text('Birthdays & Parties ($_partyCount)'),
                  selected: _selectedFilter == 2,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 2 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  onSelected: (_) => setState(() => _selectedFilter = 2),
                ),
                ChoiceChip(
                  label: Text('Weddings & Galas ($_weddingCount)'),
                  selected: _selectedFilter == 3,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 3 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  onSelected: (_) => setState(() => _selectedFilter = 3),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Booked Vendors Cards or Empty State
            if (bookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy_rounded,
                        size: 56, color: AppColors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'No Bookings Found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "You haven't booked any vendors in this category yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          FadeScaleRoute(
                            page: const ServiceListingScreen(category: 'Photography'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Explore Vendors'),
                    ),
                  ],
                ),
              )
            else
              ...bookings.map((v) {
                final String vendorName = (v['name'] as String?) ?? 'Vendor';
                final String status = (v['status'] as String?) ?? 'Confirmed';
                final bool isAccepted = status == 'Confirmed' || status == 'Accepted';
                final String category = (v['category'] as String?) ?? '';
                final String package = (v['package'] as String?) ?? '';
                final String total = (v['total'] as String?) ?? '';
                final String phone = (v['phone'] as String?) ?? '';
                final String? eventName = v['eventName'] as String?;
                final Color eventColor = (v['eventColor'] as Color?) ?? AppColors.primary;
                final IconData eventIcon = (v['eventIcon'] as IconData?) ?? Icons.celebration_rounded;

                return GestureDetector(
                  onTap: () => _showBookingDetailsSheet(context, v),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (eventName != null) ...[  
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: eventColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            eventIcon,
                                            size: 11,
                                            color: eventColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              eventName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: eventColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  Text(
                                    vendorName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAccepted
                                    ? AppColors.successLight
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isAccepted
                                      ? AppColors.success
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          package,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // In-Person settlement notice badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F6F0),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.handshake_rounded,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Pay In Person',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                total,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextButton.icon(
                                onPressed: () => _showBookingDetailsSheet(context, v),
                                icon: const Icon(Icons.description_outlined, size: 14),
                                label: const Text(
                                  'Details',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isAccepted) ...[
                              Expanded(
                                flex: 4,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Utils.showInfo('Calling $phone...');
                                  },
                                  icon: const Icon(Icons.phone_rounded, size: 12),
                                  label: const Text('Call', style: TextStyle(fontSize: 11)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 6,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Utils.showSuccess('Opening WhatsApp with $vendorName ($phone)...');
                                  },
                                  icon: const Icon(Icons.phone_android_rounded, size: 12),
                                  label: const Text(
                                    'WhatsApp',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: AppColors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                            ] else
                              Expanded(
                                flex: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFD97706).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.lock_clock_rounded,
                                          size: 12, color: Color(0xFFD97706)),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Call & WhatsApp unlock upon acceptance',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 10),

            // Browse more services card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need more services for your event? ✨',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Book DJs, Caterers, Decorators, Luxury Cars & More',
                    style: TextStyle(fontSize: 11, color: AppColors.darkGrey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          FadeScaleRoute(
                            page: const ServiceListingScreen(category: 'Makeup Artist'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.explore_rounded, size: 16),
                      label: const Text('Explore All Vendors'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
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
      final isNet = e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('network');
      setState(() {
        if (_profile == null) {
          _isNoInternet = isNet;
          _errorMsg = isNet ? null : 'Failed to connect to server. Please try again.';
        }
        _isLoading = false;
      });
    }
  }

  String get _displayName {
    final stored = StorageHelper().getUserName();
    if (stored?.trim().isNotEmpty == true) return stored!.trim();
    if (_profile?.fullName?.trim().isNotEmpty == true) return _profile!.fullName!.trim();
    return 'Customer';
  }

  String get _displayContact {
    final email = StorageHelper().getUserEmail();
    if (email?.trim().isNotEmpty == true) return email!.trim();
    if (_profile?.email?.trim().isNotEmpty == true) return _profile!.email!.trim();
    final mobile = StorageHelper().getUserMobile();
    if (mobile?.trim().isNotEmpty == true) return mobile!.trim();
    if (_profile?.mobile?.trim().isNotEmpty == true) return _profile!.mobile!.trim();
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
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
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
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
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
                    Icon(Icons.help_rounded, color: AppColors.primary, size: 24),
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
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
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
                      message: response?.message ?? 'Could not load FAQs from server.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final faqs = response.data ?? [];
                  if (faqs.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.help_outline_rounded,
                      title: 'No FAQs Available',
                      subtitle: 'Frequently asked questions will appear here shortly.',
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
                      Icon(Icons.privacy_tip_rounded,
                          color: AppColors.primary, size: 24),
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
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
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
                    return const AppLoadingState(message: 'Loading Privacy Policy...');
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
                      message: response?.message ?? 'Could not load Privacy Policy.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy Pending',
                      subtitle: 'The privacy terms will appear here once published by admin.',
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
                      Icon(Icons.gavel_rounded,
                          color: AppColors.primary, size: 24),
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
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
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
                    return const AppLoadingState(message: 'Loading Terms of Service...');
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
                      message: response?.message ?? 'Could not load Terms of Service.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.gavel_rounded,
                      title: 'Terms of Service Pending',
                      subtitle: 'The terms and conditions will appear here once published by admin.',
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
                      Icon(Icons.assignment_return_outlined,
                          color: AppColors.primary, size: 24),
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
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
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
                    return const AppLoadingState(message: 'Loading Cancellation Policy...');
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
                      message: response?.message ?? 'Could not load Cancellation Policy.',
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  if (content.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.assignment_return_outlined,
                      title: 'Cancellation Policy Pending',
                      subtitle: 'The cancellation policy will appear here once published by admin.',
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
    Navigator.of(context).push(
      FadeScaleRoute(
        page: const ChangePasswordScreen(isVendor: false),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsOverflowButtonSpacing: 8,
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of Widoora? You can sign back in anytime.',
          style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (Get.isRegistered<AuthController>()) {
                await Get.find<AuthController>().logout();
              } else {
                await StorageHelper().clearAllData();
              }
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                FadeScaleRoute(page: const UnifiedLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsOverflowButtonSpacing: 8,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action is irreversible. All your data will be permanently erased:',
              style: TextStyle(fontSize: 13, color: AppColors.black),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('• Profile & event celebration details',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Wedding checklist & task progress',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Wedding budget tracker & cost estimates',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Saved vendor shortlists & bookings',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to permanently delete your account?',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Account',
                style: TextStyle(color: AppColors.darkGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (Get.isRegistered<AuthController>()) {
                await Get.find<AuthController>().logout();
              } else {
                await StorageHelper().clearAllData();
              }
              Utils.showSuccess('Your account has been deleted successfully.');
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                FadeScaleRoute(page: const UnifiedLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
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
                          child: ((_profile?.profileImgUrl != null && _profile!.profileImgUrl!.isNotEmpty) ||
                                  (StorageHelper().getUserProfileImg() != null && StorageHelper().getUserProfileImg()!.isNotEmpty))
                              ? CachedImageView(
                                  imageUrl: StorageHelper().getUserProfileImg() ?? _profile?.profileImgUrl ?? '',
                                  fit: BoxFit.cover,
                                  width: 72,
                                  height: 72,
                                  isCircle: true,
                                  fallbackIcon: Icons.favorite_rounded,
                                )
                              : const CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.favorite_rounded,
                                      color: AppColors.gold, size: 36),
                                ),
                        ),
                      ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
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
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  color: AppColors.white, size: 13),
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
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'EVENT PLANNING TOOLS',
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
                title: 'Edit Wedding & Host Profile',
                subtitle: 'Update names, celebration date, city & guest count',
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
              ),
              _buildActionItem(
                context: context,
                icon: Icons.notifications_active_outlined,
                title: 'Notifications & Alerts',
                subtitle: 'Booking confirmations, milestones & reminders',
                onTap: () => Navigator.of(context).push(
                  FadeScaleRoute(
                    page: const CustomerNotificationsScreen(),
                  ),
                ),
              ),
              _buildActionItem(
                context: context,
                icon: Icons.checklist_rounded,
                title: 'Wedding Checklist & Tasks',
                subtitle: 'Track wedding milestones and preparation tasks',
                onTap: () => _showChecklistSheet(context),
              ),
              _buildActionItem(
                context: context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wedding Budget Tracker',
                subtitle: 'Manage budget allocations and planned expenses',
                onTap: () => _showBudgetSheet(context),
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

              // ─── BOTTOM ACTIONS (CHANGE PASSWORD, LOGOUT & DELETE ACCOUNT) ─────
              // Change Password
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _openChangePasswordScreen(context),
                  icon: const Icon(Icons.lock_reset_rounded,
                      color: AppColors.secondary, size: 18),
                  label: const Text(
                    'Change Password',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondary, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ─── BOTTOM ACTIONS (LOGOUT & DELETE ACCOUNT) ───────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.primary, size: 18),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
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
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 16),
                  label: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Widoora v1.0.4 • Direct Celebrations Marketplace',
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
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
        ),
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
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.grey),
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
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
        ),
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

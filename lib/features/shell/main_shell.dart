import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import '../dashboard/dashboard_screen.dart';
import '../explore/explore_screen.dart';
import '../auth/unified_login_screen.dart';
import '../wedding_details/wedding_details_screen.dart';
import '../service_listing/service_listing_screen.dart';
import '../../core/services/booking_service.dart';
import '../vendor_panel/vendor_shell.dart';
import '../profile/customer_edit_profile_screen.dart';
import '../notifications/customer_notifications_screen.dart';

/// The main navigation shell — holds all customer tabs in an [IndexedStack]
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
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
        children: const [
          DashboardBody(),
          ExploreBody(),
          _CustomerWeddingTab(),
          _CustomerBookingsTab(),
          _CustomerProfileTab(),
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

class _CustomerWeddingTab extends StatelessWidget {
  const _CustomerWeddingTab();

  @override
  Widget build(BuildContext context) {
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
                      '${StorageHelper().getUserName()?.trim().isNotEmpty == true ? StorageHelper().getUserName()! : 'Your'} • 28 Dec 2026 • Chandigarh',
                      style: const TextStyle(fontSize: 13, color: AppColors.darkGrey),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded,
                      color: AppColors.primary, size: 28),
                  onPressed: () {
                    Navigator.of(context).push(
                      FadeScaleRoute(page: const WeddingDetailsScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Countdown Card
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  FadeScaleRoute(page: const WeddingDetailsScreen()),
                );
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimerBlock('118', 'DAYS'),
                        _buildTimerBlock('14', 'HOURS'),
                        _buildTimerBlock('32', 'MINS'),
                      ],
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

            _buildEventRow(
                context,
                'Mehendi & Sangeet',
                '26 Dec 2026',
                '6:00 PM',
                'The Grand Palace, Chandigarh',
                Icons.music_note_rounded,
                const Color(0xFF8B1A2E)),
            _buildEventRow(
                context,
                'Haldi Ceremony',
                '27 Dec 2026',
                '10:00 AM',
                'Home Lawn, Sector 9',
                Icons.spa_rounded,
                const Color(0xFFD4A017)),
            _buildEventRow(
                context,
                'Wedding & Anand Karaj',
                '28 Dec 2026',
                '11:00 AM',
                'Heritage Haveli Resort',
                Icons.favorite_rounded,
                const Color(0xFFAD1457)),
            _buildEventRow(
                context,
                'Grand Reception',
                '29 Dec 2026',
                '7:30 PM',
                'Hyatt Regency Ballroom',
                Icons.celebration_rounded,
                const Color(0xFF1565C0)),
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
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Added ${titleCtrl.text.isEmpty ? "Event" : titleCtrl.text} to Schedule!'),
                      ),
                    );
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
    Color iconColor,
  ) {
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
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.people_outline_rounded,
                          size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Estimated Attendees: 450 Guests',
                          style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 18, color: AppColors.success),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vendor coordination in progress • Pay in person',
                          style: TextStyle(fontSize: 12, color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
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
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: () => _showEventDetailsSheet(
        context,
        title,
        date,
        time,
        location,
        icon,
        iconColor,
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
                            'Pay the vendor directly in person on the event day or upon agreement. Riwaaz does not charge fees or collect payments from users.',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling $name ($phone)...')),
                        );
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Opening WhatsApp with $name ($phone)...'),
                            backgroundColor: const Color(0xFF25D366),
                          ),
                        );
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
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Calling $phone...'),
                                      ),
                                    );
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
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Opening WhatsApp with $vendorName ($phone)...'),
                                        backgroundColor: const Color(0xFF25D366),
                                      ),
                                    );
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

class _CustomerProfileTab extends StatelessWidget {
  const _CustomerProfileTab();

  void _showChecklistSheet(BuildContext context) {
    final tasks = [
      ('Book Wedding Photographer', true),
      ('Finalize Venue & Banquet Hall', true),
      ('Select Floral Decor Theme', true),
      ('Book Bridal Makeup Artist', false),
      ('Order Custom Wedding Invitations', false),
      ('Arrange Luxury Wedding Car', false),
      ('Finalize Sangeet DJ & Sound', false),
      ('Book Catering Tasting Session', false),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
              const Text(
                'Wedding Checklist & Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track all key milestones before the big day',
                style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = tasks[i];
                    return CheckboxListTile(
                      value: item.$2,
                      title: Text(
                        item.$1,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration:
                              item.$2 ? TextDecoration.lineThrough : null,
                          color: item.$2 ? AppColors.grey : AppColors.black,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setSheetState(() {
                          tasks[i] = (item.$1, val ?? false);
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetSheet(BuildContext context) {
    final categories = [
      ('Venue & Banquet', '₹3,50,000', 'Agreed • Pay In Person', 0.8),
      ('Decoration & Floral', '₹1,50,000', 'Agreed • Pay In Person', 0.6),
      ('Photography & Cinema', '₹75,000', 'Agreed • Pay In Person', 0.9),
      ('Catering & Buffet', '₹2,00,000', 'Planned • Pay In Person', 0.0),
      ('Bridal Wear & Jewellery', '₹1,25,000', 'Planned • In-Store', 0.0),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
            const Text(
              'Wedding Budget Planner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Total Budget: ₹9,00,000 • Booked: ₹5,75,000',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat.$1,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              cat.$2,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.$3,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedVendorsSheet(BuildContext context) {
    final saved = [
      ('Royal Click Studio', 'Photography', '4.9 ★', '₹35,000'),
      ('Memories Forever', 'Photography', '4.8 ★', '₹28,000'),
      ('Royal Mandap Decor', 'Decoration', '4.9 ★', '₹50,000'),
      ('Flavours of Punjab Catering', 'Catering', '4.7 ★', '₹850/plate'),
      ('Heritage Haveli Resort', 'Venue', '4.9 ★', '₹2,50,000'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
            const Text(
              'Saved Vendors (5)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your shortlisted professionals for quick access',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: saved.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final s = saved[i];
                  return ListTile(
                    tileColor: AppColors.offWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.favorite_rounded,
                          color: AppColors.gold, size: 18),
                    ),
                    title: Text(
                      s.$1,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${s.$2} • ${s.$3}'),
                    trailing: Text(
                      s.$4,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        FadeScaleRoute(
                          page: ServiceListingScreen(category: s.$2),
                        ),
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
              'Last Updated: September 2026 • Riwaaz User Privacy',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPolicySection(
                    icon: Icons.shield_rounded,
                    title: '1. Commitment to User Privacy',
                    content:
                        'Riwaaz values your personal privacy. We collect only essential information required to help you discover, coordinate, and organize your wedding and special events seamlessly.',
                  ),
                  _buildPolicySection(
                    icon: Icons.person_search_rounded,
                    title: '2. Information We Collect',
                    content:
                        'We collect your basic profile details (name, phone number, email address), event milestones (celebration type, date, venue location), and your saved vendor shortlist or checklist items.',
                  ),
                  _buildPolicySection(
                    icon: Icons.handshake_rounded,
                    title: '3. In-Person Payments & No Banking Data Collection',
                    content:
                        'Clients do NOT pay vendors through the Riwaaz application. All event transactions, advance deposits, and final settlements happen directly in person between you and the vendor. Riwaaz does not collect, process, or store your credit card, debit card, or net banking credentials.',
                  ),
                  _buildPolicySection(
                    icon: Icons.phone_forwarded_rounded,
                    title: '4. Direct Communication via Call & WhatsApp',
                    content:
                        'The Riwaaz application does not support built-in chat. When a booking request is accepted by a vendor, direct contact details (Phone Call and WhatsApp) are unlocked so you can coordinate directly.',
                  ),
                  _buildPolicySection(
                    icon: Icons.lock_outline_rounded,
                    title: '5. Security & Data Protection',
                    content:
                        'Your account data is secured using industry-standard encryption protocols. We do not sell your personal data to unauthorized third-party advertisers.',
                  ),
                  _buildPolicySection(
                    icon: Icons.delete_forever_rounded,
                    title: '6. Your Rights & Account Deletion',
                    content:
                        'You maintain complete control over your information. You can request a data copy or permanently delete your account and all associated planning data anytime from your profile screen.',
                  ),
                  _buildPolicySection(
                    icon: Icons.contact_support_rounded,
                    title: '7. Privacy Inquiries & Support',
                    content:
                        'For any privacy concerns, data inquiries, or grievance redressal, reach out to our privacy officer at privacy@riwaazweddings.in.',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsAndConditionsSheet(BuildContext context) {
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
                          'Terms & Conditions',
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
              'Last Updated: September 2026 • Platform Usage Agreement',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPolicySection(
                    icon: Icons.check_circle_outline_rounded,
                    title: '1. Acceptance of Terms',
                    content:
                        'By downloading, accessing, or using the Riwaaz app, you agree to comply with and be legally bound by these Terms and Conditions.',
                  ),
                  _buildPolicySection(
                    icon: Icons.storefront_rounded,
                    title: '2. Platform Marketplace Role',
                    content:
                        'Riwaaz is a discovery platform connecting event organizers, couples, and hosts with independent event professionals (venues, photographers, decorators, caterers, DJs, etc.). Riwaaz is not an employer or principal of any vendor.',
                  ),
                  _buildPolicySection(
                    icon: Icons.payments_outlined,
                    title: '3. In-Person Payments & Direct Contracts',
                    content:
                        'Riwaaz is an event discovery and booking connection platform. The application does not support built-in chat or app money transfers. Once a vendor accepts your booking, their direct Call and WhatsApp contact details are unlocked. All service contracts and package fees are settled directly in person between you and the vendor.',
                  ),
                  _buildPolicySection(
                    icon: Icons.assignment_turned_in_rounded,
                    title: '4. Service Delivery & Vendor Responsibility',
                    content:
                        'Vendors are solely responsible for the execution, quality, and punctuality of their deliverables. Clients are advised to inspect sample work and finalize formal agreements directly with vendors.',
                  ),
                  _buildPolicySection(
                    icon: Icons.event_repeat_rounded,
                    title: '5. Cancellations & Rescheduling',
                    content:
                        'Policies regarding date rescheduling, cancellations, and advance retention are determined strictly by mutual contract between the host and vendor. Riwaaz is not liable for vendor refund disputes.',
                  ),
                  _buildPolicySection(
                    icon: Icons.person_remove_rounded,
                    title: '6. Account Termination & Deletion',
                    content:
                        'You may terminate your account at any time using the "Delete Account" feature in your profile settings. Upon deletion, all your stored event planning data is permanently erased.',
                  ),
                  _buildPolicySection(
                    icon: Icons.balance_rounded,
                    title: '7. Limitation of Liability & Jurisdiction',
                    content:
                        'Riwaaz provides vendor listings on an "as-is" basis. Any disputes arising out of the use of the platform shall be governed by the laws of India and subject to the jurisdiction of courts in Chandigarh.',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
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
          'Are you sure you want to log out of Riwaaz? You can sign back in anytime.',
          style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
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
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your account has been deleted successfully.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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

  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.darkGrey,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.favorite_rounded,
                            color: AppColors.gold, size: 36),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            FadeScaleRoute(
                              page: const CustomerEditProfileScreen(),
                            ),
                          ),
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
                  const Text(
                    'Simran & Rahul 💍',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Wedding Date: 28 Dec 2026 • Chandigarh',
                    style: TextStyle(
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
              onTap: () => Navigator.of(context).push(
                FadeScaleRoute(
                  page: const CustomerEditProfileScreen(),
                ),
              ),
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
              subtitle: '12 of 24 tasks completed',
              onTap: () => _showChecklistSheet(context),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wedding Budget Tracker',
              subtitle: '₹9,00,000 budget • ₹5,75,000 booked',
              onTap: () => _showBudgetSheet(context),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.bookmark_outline_rounded,
              title: 'Saved Vendors (5)',
              subtitle: 'Photographers, Decorators, Caterers',
              onTap: () => _showSavedVendorsSheet(context),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.storefront_rounded,
              title: 'Vendor Partner Portal',
              subtitle: 'Switch to vendor panel, incoming bookings & inquiries',
              onTap: () {
                Navigator.of(context).push(
                  FadeScaleRoute(page: const VendorShell(initialIndex: 0)),
                );
              },
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
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Data protection & direct payment privacy',
              onTap: () => _showPrivacyPolicySheet(context),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.gavel_rounded,
              title: 'Terms & Conditions',
              subtitle: 'Platform agreement & in-person terms',
              onTap: () => _showTermsAndConditionsSheet(context),
            ),

            const SizedBox(height: 28),

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
                'Riwaaz v1.0.4 • Direct Celebrations Marketplace',
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

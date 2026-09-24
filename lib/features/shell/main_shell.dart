import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import '../dashboard/dashboard_screen.dart';
import '../explore/explore_screen.dart';
import '../auth/unified_login_screen.dart';
import '../wedding_details/wedding_details_screen.dart';
import '../service_listing/service_listing_screen.dart';

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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 38),
                          Text(
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
                          const SizedBox(height: 6),
                        ],
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Event Plan 💍',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Simran & Rahul • 28 Dec 2026 • Chandigarh',
                      style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
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
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title: $date at $location')),
        );
      },
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
  int _selectedFilter = 0; // 0 = All, 1 = Confirmed, 2 = Balance Due

  final List<Map<String, dynamic>> _allBookings = [
    {
      'name': 'Royal Click Studio',
      'category': 'Photography & Cinema',
      'package': 'Royal Diamond 4K Crew Package',
      'date': '28 Dec 2026',
      'time': 'Full Day (8:00 AM - 11:00 PM)',
      'venue': 'Heritage Haveli Resort, Mohali',
      'status': 'Confirmed',
      'total': '₹75,000',
      'paid': '₹25,000 Paid',
      'balance': '₹50,000 Due on Event',
      'paidFraction': 0.33,
      'phone': '+91 98765 43210',
      'inclusions': [
        '4K Cinematic Drone',
        '2 Candid Photographers',
        'Traditional Video',
        '2 Luxury Velvet Albums',
      ],
    },
    {
      'name': 'Royal Mandap & Floral Decor',
      'category': 'Decoration & Themes',
      'package': 'Grand Floral & Crystal Mandap Theme',
      'date': '28 Dec 2026',
      'time': 'Morning Setup (6:00 AM)',
      'venue': 'Heritage Haveli Resort Lawn',
      'status': 'Confirmed',
      'total': '₹1,50,000',
      'paid': '₹50,000 Paid',
      'balance': '₹1,00,000 Due on Event',
      'paidFraction': 0.33,
      'phone': '+91 98112 44556',
      'inclusions': [
        'Exotic Floral Arch',
        'Stage Lighting & Fog FX',
        'Entryway Flower Pathway',
        'Varmala Stage Setup',
      ],
    },
    {
      'name': 'Heritage Haveli Resort',
      'category': 'Venue & Banquet',
      'package': 'Grand Lawn + 2 AC Ballrooms + 12 Rooms',
      'date': '28 Dec 2026',
      'time': 'Full Day Check-in 10:00 AM',
      'venue': 'SCO 142, Sector 70, Mohali',
      'status': 'Advance Confirmed',
      'total': '₹3,50,000',
      'paid': '₹1,00,000 Paid',
      'balance': '₹2,50,000 Due on 20 Dec',
      'paidFraction': 0.28,
      'phone': '+91 98223 99887',
      'inclusions': [
        '800 Guest Capacity Lawn',
        'Bridal Luxury Suite',
        'Full Power Backup & Valet',
        'Decorative Lighting Setup',
      ],
    },
    {
      'name': 'Flavours of Punjab Caterers',
      'category': 'Catering & Buffet',
      'package': 'Royal 65-Item Live Counters Buffet',
      'date': '28 Dec 2026',
      'time': 'Dinner Service 7:30 PM',
      'venue': 'Heritage Haveli Resort Dining Area',
      'status': 'Menu Confirmed',
      'total': '₹45,000 Token (₹850 / Plate)',
      'paid': '₹20,000 Paid',
      'balance': 'Remaining on final plate count',
      'paidFraction': 0.44,
      'phone': '+91 98987 11223',
      'inclusions': [
        '12 Live Chaat & Tandoori Counters',
        'Authentic Amritsari Kulcha Corner',
        'Exotic Mocktails & Desserts',
        'Premium Cutlery & Stewards',
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 1) {
      return _allBookings.where((b) => b['status'] == 'Confirmed').toList();
    } else if (_selectedFilter == 2) {
      return _allBookings.where((b) => b['balance'] != null).toList();
    }
    return _allBookings;
  }

  void _showBookingDetailsSheet(BuildContext context, Map<String, dynamic> b) {
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
                        b['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        b['category'],
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
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    b['status'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
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
                    b['package'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('📅 Event Date: ${b['date']} • ${b['time']}',
                      style: const TextStyle(fontSize: 12, color: AppColors.black)),
                  const SizedBox(height: 4),
                  Text('📍 Location: ${b['venue']}',
                      style: const TextStyle(fontSize: 12, color: AppColors.darkGrey)),
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
              children: (b['inclusions'] as List<String>).map((item) {
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
              'Payment Breakdown',
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
                      Text(b['total'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Advance Paid (Verified):',
                          style: TextStyle(color: AppColors.success)),
                      Text(b['paid'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remaining Balance:'),
                      Text(b['balance'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGrey)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${b['name']} (${b['phone']})...')),
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
                        SnackBar(content: Text('Chat opened with ${b['name']}!')),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
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
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Booked Vendors',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Track booked vendors & payments for Dec 28',
                    style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary, size: 28),
                onPressed: () {
                  Navigator.of(context).push(
                    FadeScaleRoute(
                      page: const ServiceListingScreen(category: 'Photography'),
                    ),
                  );
                },
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
                  children: const [
                    Text(
                      'WEDDING BUDGET OVERVIEW',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '4 Vendors Hired 💍',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Total Booked',
                          style: TextStyle(color: AppColors.cream, fontSize: 11),
                        ),
                        Text(
                          '₹ 6,20,000',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.white.withValues(alpha: 0.3),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Advance Paid',
                          style: TextStyle(color: AppColors.cream, fontSize: 11),
                        ),
                        Text(
                          '₹ 1,95,000',
                          style: TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.white.withValues(alpha: 0.3),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Due on Event',
                          style: TextStyle(color: AppColors.cream, fontSize: 11),
                        ),
                        Text(
                          '₹ 4,25,000',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Filter Chips
          Row(
            children: [
              ChoiceChip(
                label: Text('All (${_allBookings.length})'),
                selected: _selectedFilter == 0,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color:
                      _selectedFilter == 0 ? AppColors.white : AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                onSelected: (_) => setState(() => _selectedFilter = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Confirmed (3)'),
                selected: _selectedFilter == 1,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color:
                      _selectedFilter == 1 ? AppColors.white : AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                onSelected: (_) => setState(() => _selectedFilter = 1),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Pending Balance (1)'),
                selected: _selectedFilter == 2,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color:
                      _selectedFilter == 2 ? AppColors.white : AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                onSelected: (_) => setState(() => _selectedFilter = 2),
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
              final double paidFraction = (v['paidFraction'] as double?) ?? 0.33;

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
                            child: Text(
                              v['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              v['status']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        v['category']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        v['package']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Progress bar for payment
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: paidFraction,
                          backgroundColor: AppColors.lightGrey,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            v['paid']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            v['balance']!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showBookingDetailsSheet(context, v),
                            icon: const Icon(Icons.receipt_long_rounded, size: 14),
                            label: const Text('View Invoice'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Calling ${v['phone']}...'),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                ),
                                child: const Text('Call'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Opening chat with ${v['name']}...'),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  elevation: 0,
                                ),
                                child: const Text('Chat'),
                              ),
                            ],
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
                  'Need more services for your wedding? 🌸',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Book DJs, Makeup Artists, Luxury Cars & Jewellery',
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
                    label: const Text('Explore Vendors'),
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
      ('Venue & Banquet', '₹3,50,000', '₹1,00,000 Paid', 0.8),
      ('Decoration & Floral', '₹1,50,000', '₹50,000 Paid', 0.6),
      ('Photography & Cinema', '₹75,000', '₹25,000 Paid', 0.9),
      ('Catering & Buffet', '₹2,00,000', 'Planned', 0.0),
      ('Bridal Wear & Jewellery', '₹1,25,000', 'Planned', 0.0),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
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
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.favorite_rounded,
                        color: AppColors.gold, size: 36),
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

            const SizedBox(height: 20),

            // Profile Actions
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

            const SizedBox(height: 16),

            // ─── LOGOUT BUTTON ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text(
                          'Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pushAndRemoveUntil(
                              FadeScaleRoute(
                                  page: const UnifiedLoginScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.red, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

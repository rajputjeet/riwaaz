import 'package:flutter/material.dart';

/// Single unified booking record shared between Customer and Vendor panels.
class BookingRecord {
  final String id;
  final String vendorName;
  final String clientName;
  final String vendorPhone;
  final String clientPhone;
  final String category;
  final String package;
  final String total;
  final int price;
  final String date;
  final String time;
  final String venue;
  final String eventName;
  final String eventType;
  final IconData eventIcon;
  final Color eventColor;
  String status; // 'Pending', 'Confirmed', 'Delivered & Paid', 'Declined'
  final String paymentMode; // 'Pay In Person (Direct)'
  final String balance; // 'Settle on Event Day'
  final List<String> inclusions;
  final DateTime createdAt;

  BookingRecord({
    required this.id,
    required this.vendorName,
    required this.clientName,
    required this.vendorPhone,
    required this.clientPhone,
    required this.category,
    required this.package,
    required this.total,
    required this.price,
    required this.date,
    required this.time,
    required this.venue,
    required this.eventName,
    required this.eventType,
    this.eventIcon = Icons.celebration_rounded,
    this.eventColor = const Color(0xFF8B1A2E),
    this.status = 'Pending',
    this.paymentMode = 'Pay In Person (Direct)',
    this.balance = 'Settle on Event Day',
    this.inclusions = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAccepted => status == 'Confirmed' || status == 'Accepted';
  bool get isPending => status == 'Pending';
  bool get isCompleted => status == 'Delivered & Paid' || status == 'Completed';
  bool get isDeclined => status == 'Declined' || status == 'Cancelled';

  /// Map representation compatible with both Customer and Vendor panel UI widgets.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': vendorName,
      'client': clientName,
      'clientName': clientName,
      'vendorName': vendorName,
      'phone': vendorPhone,
      'clientPhone': clientPhone,
      'vendorPhone': vendorPhone,
      'category': category,
      'package': package,
      'total': total,
      'price': price,
      'date': date,
      'time': time,
      'venue': venue,
      'eventName': eventName,
      'eventType': eventType,
      'eventIcon': eventIcon,
      'eventColor': eventColor,
      'status': status,
      'payment': paymentMode,
      'paymentMode': paymentMode,
      'balance': balance,
      'inclusions': inclusions,
      'createdAt': createdAt,
    };
  }
}

/// Central synchronized booking service connecting Customer & Vendor panel processes.
class AppBookingService extends ChangeNotifier {
  static final AppBookingService instance = AppBookingService._internal();
  factory AppBookingService() => instance;

  final List<BookingRecord> _bookings = [];

  AppBookingService._internal() {
    _loadSeedBookings();
  }

  List<BookingRecord> get bookings => List.unmodifiable(_bookings);

  List<Map<String, dynamic>> get allBookingsAsMaps =>
      _bookings.map((b) => b.toMap()).toList();

  int get pendingCount => _bookings.where((b) => b.isPending).length;
  int get confirmedCount => _bookings.where((b) => b.isAccepted).length;
  int get completedCount => _bookings.where((b) => b.isCompleted).length;
  int get totalCount => _bookings.length;

  int get totalRevenue {
    return _bookings
        .where((b) => b.isAccepted || b.isCompleted)
        .fold(0, (sum, b) => sum + b.price);
  }

  /// Active bookings for Customer Panel
  List<BookingRecord> get customerBookings =>
      _bookings.where((b) => !b.isCompleted).toList();

  int get customerBookingsCount => customerBookings.length;

  /// Event type counts for Customer filter chips
  int get officeCount => _bookings
      .where((b) => !b.isCompleted && b.eventType == 'Office Party')
      .length;

  int get partyCount => _bookings
      .where((b) =>
          !b.isCompleted &&
          (b.eventType == 'Birthday Party' || b.eventType == 'Private Party'))
      .length;

  int get weddingCount => _bookings
      .where((b) =>
          !b.isCompleted &&
          (b.eventType == 'Wedding' || b.eventType == 'Anniversary'))
      .length;

  /// Formatted total budget for customer bookings
  String get customerTotalBudgetFormatted {
    final total = customerBookings.fold<int>(0, (sum, b) => sum + b.price);
    return '₹ ${_formatIndianCurrency(total)}';
  }

  static String _formatIndianCurrency(int value) {
    final str = value.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (match) => '${match[1]},',
    );
    return '$formattedRest,$lastThree';
  }

  /// Reset to seed data for testing
  void resetForTesting() {
    _bookings.clear();
    _loadSeedBookings();
    notifyListeners();
  }

  /// Filtered bookings for Customer Panel:
  /// 0 = All, 1 = Office Parties, 2 = Birthdays & Parties, 3 = Weddings & Galas
  List<Map<String, dynamic>> customerBookingsForFilter(int filterIndex) {
    List<BookingRecord> filtered;
    switch (filterIndex) {
      case 1:
        filtered = _bookings
            .where((b) => !b.isCompleted && b.eventType == 'Office Party')
            .toList();
        break;
      case 2:
        filtered = _bookings
            .where((b) =>
                !b.isCompleted &&
                (b.eventType == 'Birthday Party' ||
                    b.eventType == 'Private Party'))
            .toList();
        break;
      case 3:
        filtered = _bookings
            .where((b) =>
                !b.isCompleted &&
                (b.eventType == 'Wedding' || b.eventType == 'Anniversary'))
            .toList();
        break;
      default:
        filtered = customerBookings;
    }
    return filtered.map((b) => b.toMap()).toList();
  }

  /// Filtered bookings for Vendor Panel:
  /// 0 = Pending Requests, 1 = Upcoming / Confirmed, 2 = Completed, 3 = All
  List<Map<String, dynamic>> vendorBookingsForFilter(int filterIndex) {
    List<BookingRecord> filtered;
    switch (filterIndex) {
      case 0:
        filtered = _bookings.where((b) => b.isPending).toList();
        break;
      case 1:
        filtered = _bookings.where((b) => b.isAccepted).toList();
        break;
      case 2:
        filtered = _bookings.where((b) => b.isCompleted).toList();
        break;
      default:
        filtered = _bookings;
    }
    return filtered.map((b) => b.toMap()).toList();
  }

  /// Customer books a vendor package -> creates a booking in 'Pending' state
  BookingRecord createBooking({
    required String vendorName,
    required String category,
    required String package,
    required String total,
    required int price,
    String? clientName,
    String? clientPhone,
    String? vendorPhone,
    String? date,
    String? time,
    String? venue,
    String? eventName,
    String? eventType,
    IconData? eventIcon,
    Color? eventColor,
    List<String>? inclusions,
  }) {
    final record = BookingRecord(
      id: 'BK_${DateTime.now().millisecondsSinceEpoch}',
      vendorName: vendorName,
      clientName: clientName ?? 'Simran & Rahul 💍',
      vendorPhone: vendorPhone ?? '+91 98765 43210',
      clientPhone: clientPhone ?? '+91 98765 11223',
      category: category,
      package: package,
      total: total,
      price: price,
      date: date ?? '28 Dec 2026',
      time: time ?? 'Event Day',
      venue: venue ?? 'The Oberoi Sukhvilas, Chandigarh',
      eventName: eventName ?? 'Grand Royal Vivah',
      eventType: eventType ?? 'Wedding',
      eventIcon: eventIcon ?? Icons.celebration_rounded,
      eventColor: eventColor ?? const Color(0xFF8B1A2E),
      status: 'Pending',
      paymentMode: 'Pay In Person (Direct)',
      balance: 'Settle on Event Day',
      inclusions: inclusions ??
          const [
            'Full Event Coordination Included',
            'Dedicated Professional Team',
            'Direct In-Person Settlement',
          ],
    );

    // Insert at front so new bookings appear prominently
    _bookings.insert(0, record);
    notifyListeners();
    return record;
  }

  /// Vendor accepts a booking -> changes status to 'Confirmed', unlocking contact info
  bool acceptBooking(String id) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx].status = 'Confirmed';
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Vendor declines a booking
  bool declineBooking(String id) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx].status = 'Declined';
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Mark booking as completed upon in-person settlement
  bool completeBooking(String id) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx].status = 'Delivered & Paid';
      notifyListeners();
      return true;
    }
    return false;
  }

  void _loadSeedBookings() {
    _bookings.addAll([
      BookingRecord(
        id: 'BK_001',
        vendorName: 'Grand Stage Crafters & AV Tech',
        clientName: 'TechCorp Annual Office Gala',
        vendorPhone: '+91 98450 11223',
        clientPhone: '+91 98450 11223',
        category: 'AV, Stage & Lighting',
        package: 'Corporate 4K LED Backdrop & Line-Array Audio',
        total: '₹1,20,000',
        price: 120000,
        date: '15 Jan 2027',
        time: '4:00 PM - 11:30 PM',
        venue: 'JW Marriott Grand Ballroom, Chandigarh',
        eventName: 'TechCorp Office Gala',
        eventType: 'Office Party',
        eventIcon: Icons.business_center_rounded,
        eventColor: const Color(0xFF1E3A8A),
        status: 'Confirmed',
        paymentMode: 'Pay In Person',
        balance: 'Settle on Event Day',
        inclusions: [
          'P3 LED Video Wall (20x10 ft)',
          'Line Array Sound & 4 Cordless Mics',
          'Stage Moving Head Lights',
          'Onsite Sound Engineer',
        ],
      ),
      BookingRecord(
        id: 'BK_002',
        vendorName: 'Rainbow Balloon & Carnival Themes',
        clientName: "Reyansh's 5th Birthday",
        vendorPhone: '+91 98144 77889',
        clientPhone: '+91 98144 77889',
        category: 'Theme Decor & Kids Setup',
        package: 'Grand Jungle Safari Balloon Arc & Magic Stage',
        total: '₹35,000',
        price: 35000,
        date: '10 Jan 2027',
        time: '4:00 PM - 8:30 PM',
        venue: 'Forest Hill Resort Clubhouse, Mohali',
        eventName: "Reyansh's 5th Birthday",
        eventType: 'Birthday Party',
        eventIcon: Icons.cake_rounded,
        eventColor: const Color(0xFFD97706),
        status: 'Pending',
        paymentMode: 'Pay In Person',
        balance: 'Settle on Event Day',
        inclusions: [
          '3D Jungle Safari Backdrop & Pillar Arch',
          'Custom Name Neon Sign',
          'Magician & Tattoo Artist (2 Hrs)',
          'Popcorn & Candy Floss Machine',
        ],
      ),
      BookingRecord(
        id: 'BK_003',
        vendorName: 'DJ Sandy Beats & Sound System',
        clientName: 'Neon Music & Cocktail Night',
        vendorPhone: '+91 98721 33445',
        clientPhone: '+91 98721 33445',
        category: 'DJ & Sound System',
        package: 'Club Sound, Dual Bass Bins & Laser Lights',
        total: '₹45,000',
        price: 45000,
        date: '31 Dec 2026',
        time: '8:00 PM - 2:00 AM',
        venue: 'The Lalit Sky Lounge, Chandigarh',
        eventName: 'Neon Music & Cocktail Night',
        eventType: 'Private Party',
        eventIcon: Icons.nightlife_rounded,
        eventColor: const Color(0xFF7E22CE),
        status: 'Confirmed',
        paymentMode: 'Pay In Person',
        balance: 'Settle on Event Day',
        inclusions: [
          'Pioneer CDJ 3000 & DJ Console',
          '2000W JBL Bass Subwoofers',
          'RGB Strobe & Laser Show',
          'Smoke & CO2 Jet FX',
        ],
      ),
      BookingRecord(
        id: 'BK_004',
        vendorName: 'Royal Click Studio',
        clientName: 'Grand Royal Vivah',
        vendorPhone: '+91 98765 43210',
        clientPhone: '+91 98765 43210',
        category: 'Photography & Cinema',
        package: 'Royal Diamond 4K Crew Package',
        total: '₹75,000',
        price: 75000,
        date: '28 Dec 2026',
        time: 'Full Day (8:00 AM - 11:00 PM)',
        venue: 'The Oberoi Sukhvilas, New Chandigarh',
        eventName: 'Grand Royal Vivah',
        eventType: 'Wedding',
        eventIcon: Icons.camera_alt_rounded,
        eventColor: const Color(0xFF8B1A2E),
        status: 'Confirmed',
        paymentMode: 'Pay In Person',
        balance: 'Settle on Event Day',
        inclusions: [
          '4K Cinematic Drone',
          '2 Candid Photographers',
          'Traditional Video',
          '2 Luxury Velvet Albums',
        ],
      ),
      BookingRecord(
        id: 'BK_005',
        vendorName: 'Royal Mandap & Floral Decor',
        clientName: 'Grand Royal Vivah',
        vendorPhone: '+91 98112 44556',
        clientPhone: '+91 98112 44556',
        category: 'Decoration & Themes',
        package: 'Grand Floral & Crystal Theme',
        total: '₹1,50,000',
        price: 150000,
        date: '28 Dec 2026',
        time: 'Morning Setup (6:00 AM)',
        venue: 'The Oberoi Sukhvilas Lawn',
        eventName: 'Grand Royal Vivah',
        eventType: 'Wedding',
        eventIcon: Icons.local_florist_rounded,
        eventColor: const Color(0xFF2E7D32),
        status: 'Pending',
        paymentMode: 'Pay In Person',
        balance: 'Settle on Event Day',
        inclusions: [
          'Exotic Floral Arch',
          'Stage Lighting & Fog FX',
          'Entryway Flower Pathway',
          'Varmala Stage Setup',
        ],
      ),
      BookingRecord(
        id: 'BK_006',
        vendorName: 'Flavours of Punjab Caterers',
        clientName: 'TechCorp Annual Office Gala',
        vendorPhone: '+91 98987 11223',
        clientPhone: '+91 98987 11223',
        category: 'Catering & Buffet',
        package: 'Premium 50-Item Multi-Cuisine Live Counters',
        total: '₹95,000',
        price: 95000,
        date: '15 Jan 2027',
        time: 'Lunch & Evening High Tea',
        venue: 'JW Marriott Grand Ballroom',
        eventName: 'TechCorp Office Gala',
        eventType: 'Office Party',
        eventIcon: Icons.restaurant_rounded,
        eventColor: const Color(0xFF1E3A8A),
        status: 'Confirmed',
        paymentMode: 'Pay In Person',
        balance: 'Settle on Event Day',
        inclusions: [
          'Live Pasta, Chaat & Tandoor Counters',
          'Continental & North Indian Buffet',
          'Artisanal Mocktail Bar',
          'Premium Cutlery & Stewards',
        ],
      ),
      BookingRecord(
        id: 'BK_007',
        vendorName: 'Audi A8 & Vintage Car Rentals',
        clientName: 'Silver Jubilee Gala',
        vendorPhone: '+91 98889 00112',
        clientPhone: '+91 98889 00112',
        category: 'Luxury Transport',
        package: 'Audi A8 Luxury Chauffeur Experience',
        total: '₹22,000',
        price: 22000,
        date: '05 Jan 2027',
        time: '6:00 PM - Midnight',
        venue: 'Noorani Lawns, Zirakpur',
        eventName: 'Silver Jubilee Gala',
        eventType: 'Anniversary',
        eventIcon: Icons.directions_car_rounded,
        eventColor: const Color(0xFF0D9488),
        status: 'Confirmed',
        paymentMode: 'Pay In Person',
        balance: 'Settle on Event Day',
        inclusions: [
          'Decorated Luxury White Audi A8',
          'Uniformed Professional Chauffeur',
          'Fuel & Tolls Included',
          'VIP Red Carpet Drop',
        ],
      ),
      // Historical delivered bookings for Vendor record
      BookingRecord(
        id: 'BK_008',
        vendorName: 'Royal Click Studio',
        clientName: 'InnoTech Corporate Diwali Bash',
        vendorPhone: '+91 98765 43210',
        clientPhone: '+91 98765 44332',
        category: 'AV, Stage & Sound',
        package: 'Annual Gala Stage & Sound (₹95,000)',
        total: '₹95,000',
        price: 95000,
        date: '10 Nov 2026',
        time: 'Evening',
        venue: 'JW Marriott, Chandigarh',
        eventName: 'Corporate Diwali Gala',
        eventType: 'Office Party',
        status: 'Delivered & Paid',
        paymentMode: 'Paid in Person (100%)',
        balance: 'Event Completed ✓',
      ),
      BookingRecord(
        id: 'BK_009',
        vendorName: 'Royal Click Studio',
        clientName: 'Gurpreet & Harleen Wedding',
        vendorPhone: '+91 98765 43210',
        clientPhone: '+91 98881 22334',
        category: 'Photography & Cinema',
        package: 'Royal Diamond Package (₹85,000)',
        total: '₹85,000',
        price: 85000,
        date: '12 May 2026',
        time: 'Full Day',
        venue: 'JW Marriott, Chandigarh',
        eventName: 'Royal Anand Karaj',
        eventType: 'Wedding',
        status: 'Delivered & Paid',
        paymentMode: 'Paid in Person (100%)',
        balance: 'Album & 4K Video Delivered ✓',
      ),
      BookingRecord(
        id: 'BK_010',
        vendorName: 'Royal Click Studio',
        clientName: 'Deepak & Sunita 25th Anniversary',
        vendorPhone: '+91 98765 43210',
        clientPhone: '+91 98770 99881',
        category: 'Theme Decor & Floral',
        package: 'Silver Jubilee Decor & Audio (₹45,000)',
        total: '₹45,000',
        price: 45000,
        date: '28 Apr 2026',
        time: 'Evening',
        venue: 'Heritage Haveli, Mohali',
        eventName: 'Silver Jubilee',
        eventType: 'Anniversary',
        status: 'Delivered & Paid',
        paymentMode: 'Paid in Person (100%)',
        balance: 'Drive Link Sent ✓',
      ),
    ]);
  }
}

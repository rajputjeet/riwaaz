/// Model for a single booking from GET /api/booking/list
class BookingModel {
  final String? id;
  final String? bookingId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? customerProfileImg;
  final String? vendorId;
  final String? vendorName;
  final String? vendorEmail;
  final String? vendorPhone;
  final String? vendorProfileImg;
  final String? categoryName;
  final String? serviceName;
  final String? eventType;
  final String? eventDate;
  final String? eventTime;
  final int? guestCount;
  final String? venueLocation;
  final String? eventLocation;
  final String? city;
  final num? totalAmount;
  final num? advancePaid;
  final String? paymentStatus;
  String status; // Pending, Confirmed, Completed, Cancelled
  final String? notes;
  final String? createdAt;

  BookingModel({
    this.id,
    this.bookingId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerProfileImg,
    this.vendorId,
    this.vendorName,
    this.vendorEmail,
    this.vendorPhone,
    this.vendorProfileImg,
    this.categoryName,
    this.serviceName,
    this.eventType,
    this.eventDate,
    this.eventTime,
    this.guestCount,
    this.venueLocation,
    this.eventLocation,
    this.city,
    this.totalAmount,
    this.advancePaid,
    this.paymentStatus,
    this.status = 'Pending',
    this.notes,
    this.createdAt,
  });

  bool get isPending => status == 'Pending';
  bool get isConfirmed =>
      status == 'Confirmed' || status == 'Accepted' || status == 'Approved';
  bool get isCompleted => status == 'Completed' || status == 'Delivered & Paid';
  bool get isExpired => status.toLowerCase() == 'expired';
  bool get isCancelled =>
      status == 'Cancelled' || status == 'Rejected' || status == 'Declined';

  static String? _firstNonEmptyString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    return null;
  }

  static String? _profileImageUrl(Map<String, dynamic>? user) {
    if (user == null) return null;
    final image =
        user['profileImgId'] ??
        user['profileImg'] ??
        user['profileImgUrl'] ??
        user['profileImage'] ??
        user['profileImageUrl'] ??
        user['avatar'];
    if (image is Map) {
      return _firstNonEmptyString(
        Map<String, dynamic>.from(image),
        const ['url', 'secureUrl', 'path'],
      );
    }
    final value = image?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  static num? _parsePrice(Map<String, dynamic> json) {
    final nestedPrice =
        json['pricing'] ??
        json['priceDetails'] ??
        (json['price'] is Map ? json['price'] : null);
    final candidates = [
      json['totalAmount'],
      json['price'],
      json['amount'],
      json['servicePrice'],
      json['packagePrice'],
      if (nestedPrice is Map) nestedPrice['amount'],
      if (nestedPrice is Map) nestedPrice['price'],
    ];
    for (final candidate in candidates) {
      if (candidate is num) return candidate;
      final normalized = candidate?.toString().replaceAll(
        RegExp(r'[^\d.-]'),
        '',
      );
      final parsed = num.tryParse(normalized ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String _normalizeStatus(dynamic value) {
    final status = value?.toString().trim() ?? '';
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'declined':
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'expired':
        return 'Expired';
      default:
        return status.isEmpty ? 'Pending' : status;
    }
  }

  /// Prefer populated detail-response values, while retaining list values when
  /// the detail endpoint omits optional fields.
  BookingModel mergeMissingFrom(BookingModel fallback) => BookingModel(
        id: id ?? fallback.id,
        bookingId: bookingId ?? fallback.bookingId,
        customerName: customerName ?? fallback.customerName,
        customerEmail: customerEmail ?? fallback.customerEmail,
        customerPhone: customerPhone ?? fallback.customerPhone,
        customerProfileImg: customerProfileImg ?? fallback.customerProfileImg,
        vendorId: vendorId ?? fallback.vendorId,
        vendorName: vendorName ?? fallback.vendorName,
        vendorEmail: vendorEmail ?? fallback.vendorEmail,
        vendorPhone: vendorPhone ?? fallback.vendorPhone,
        vendorProfileImg: vendorProfileImg ?? fallback.vendorProfileImg,
        categoryName: categoryName ?? fallback.categoryName,
        serviceName: serviceName ?? fallback.serviceName,
        eventType: eventType ?? fallback.eventType,
        eventDate: eventDate ?? fallback.eventDate,
        eventTime: eventTime ?? fallback.eventTime,
        guestCount: guestCount ?? fallback.guestCount,
        venueLocation: venueLocation ?? fallback.venueLocation,
        eventLocation: eventLocation ?? fallback.eventLocation,
        city: city ?? fallback.city,
        totalAmount: totalAmount ?? fallback.totalAmount,
        advancePaid: advancePaid ?? fallback.advancePaid,
        paymentStatus: paymentStatus ?? fallback.paymentStatus,
        status: status.isNotEmpty ? status : fallback.status,
        notes: notes ?? fallback.notes,
        createdAt: createdAt ?? fallback.createdAt,
      );

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String? custName = _firstNonEmptyString(json, const ['customerName']);
    String? custEmail = _firstNonEmptyString(json, const ['customerEmail']);
    String? custPhone = _firstNonEmptyString(
      json,
      const ['formattedPhone', 'customerPhone'],
    );

    final rawUser = json['userId'] ?? json['customerId'] ?? json['user'];
    if (rawUser is Map) {
      final u = Map<String, dynamic>.from(rawUser);
      custName ??= _firstNonEmptyString(u, const ['fullName', 'name']);
      custEmail ??= _firstNonEmptyString(u, const ['email']);
      custPhone ??= _firstNonEmptyString(
        u,
        const ['formattedPhone', 'mobile', 'phone'],
      );
    }
    final rawVendor = json['vendorId'];
    final vendor = rawVendor is Map ? Map<String, dynamic>.from(rawVendor) : null;
    final rawCategory = json['categoryId'];
    final category = rawCategory is Map
        ? Map<String, dynamic>.from(rawCategory)
        : null;
    final eventLocation = _firstNonEmptyString(json, const [
      'eventLocation',
      'venueLocation',
      'eventVenue',
      'venueAddress',
      'location',
      'venue',
    ]);

    return BookingModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      bookingId: json['bookingId']?.toString(),
      customerName: custName,
      customerEmail: custEmail,
      customerPhone: custPhone,
      customerProfileImg:
          _firstNonEmptyString(json, const [
            'customerProfileImg',
            'customerProfileImage',
            'userProfileImg',
          ]) ??
          _profileImageUrl(rawUser is Map ? Map<String, dynamic>.from(rawUser) : null),
      vendorId: vendor?['_id']?.toString() ?? rawVendor?.toString(),
      vendorName: _firstNonEmptyString(json, const ['vendorName']) ??
          (vendor == null
              ? null
              : _firstNonEmptyString(
                  vendor,
                  const ['businessName', 'fullName', 'name'],
                )),
      vendorEmail: _firstNonEmptyString(json, const ['vendorEmail']) ??
          (vendor == null
              ? null
              : _firstNonEmptyString(vendor, const ['email'])),
      vendorPhone: _firstNonEmptyString(json, const ['vendorPhone']) ??
          (vendor == null
              ? null
              : _firstNonEmptyString(vendor, const ['mobile', 'phone'])),
      vendorProfileImg:
          _firstNonEmptyString(json, const [
            'vendorProfileImg',
            'vendorProfileImage',
          ]) ??
          _profileImageUrl(vendor),
      categoryName: _firstNonEmptyString(json, const ['categoryName']) ??
          (category == null
              ? null
              : _firstNonEmptyString(category, const ['name'])),
      serviceName: json['serviceName']?.toString(),
      eventType: json['eventType']?.toString(),
      eventDate: json['eventDate']?.toString(),
      eventTime: json['eventTime']?.toString(),
      guestCount: json['guestCount'] is num
          ? (json['guestCount'] as num).toInt()
          : int.tryParse(json['guestCount']?.toString() ?? ''),
      venueLocation: eventLocation,
      eventLocation: eventLocation,
      city: json['city']?.toString(),
      totalAmount: _parsePrice(json),
      advancePaid: json['advancePaid'] is num
          ? json['advancePaid']
          : num.tryParse(json['advancePaid']?.toString() ?? ''),
      paymentStatus: json['paymentStatus']?.toString(),
      status: _normalizeStatus(json['status']),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        if (bookingId != null) 'bookingId': bookingId,
        if (customerName != null) 'customerName': customerName,
        if (customerEmail != null) 'customerEmail': customerEmail,
        if (customerPhone != null) 'customerPhone': customerPhone,
        if (customerProfileImg != null) 'customerProfileImg': customerProfileImg,
        if (vendorId != null) 'vendorId': vendorId,
        if (vendorName != null) 'vendorName': vendorName,
        if (vendorEmail != null) 'vendorEmail': vendorEmail,
        if (vendorPhone != null) 'vendorPhone': vendorPhone,
        if (vendorProfileImg != null) 'vendorProfileImg': vendorProfileImg,
        if (categoryName != null) 'categoryName': categoryName,
        if (serviceName != null) 'serviceName': serviceName,
        if (eventType != null) 'eventType': eventType,
        if (eventDate != null) 'eventDate': eventDate,
        if (eventTime != null) 'eventTime': eventTime,
        if (guestCount != null) 'guestCount': guestCount,
        if (venueLocation != null) 'venueLocation': venueLocation,
        if (eventLocation != null) 'eventLocation': eventLocation,
        if (city != null) 'city': city,
        if (totalAmount != null) 'totalAmount': totalAmount,
        if (advancePaid != null) 'advancePaid': advancePaid,
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
        'status': status,
        if (notes != null) 'notes': notes,
        if (createdAt != null) 'createdAt': createdAt,
      };
}

/// Summary counts returned alongside booking list
class BookingsSummary {
  final int all;
  final int pending;
  final int confirmed;
  final int upcoming;
  final int cancelled;
  final int rejected;
  final int completed;
  final num totalRevenue;

  BookingsSummary({
    this.all = 0,
    this.pending = 0,
    this.confirmed = 0,
    this.upcoming = 0,
    this.cancelled = 0,
    this.rejected = 0,
    this.completed = 0,
    this.totalRevenue = 0,
  });

  factory BookingsSummary.fromJson(Map<String, dynamic> json) {
    return BookingsSummary(
      all: (json['all'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      confirmed: (json['confirmed'] as num?)?.toInt() ?? 0,
      upcoming: (json['upcoming'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      totalRevenue: json['totalRevenue'] is num ? json['totalRevenue'] : 0,
    );
  }
}

/// Full response for booking list API
class BookingsListResponse {
  final List<BookingModel> bookings;
  final BookingsSummary? summary;

  BookingsListResponse({required this.bookings, this.summary});

  factory BookingsListResponse.fromJson(dynamic rawJson) {
    List<dynamic> list = [];
    BookingsSummary? summary;

    if (rawJson is List) {
      list = rawJson;
    } else if (rawJson is Map<String, dynamic>) {
      final inner = rawJson['data'];
      if (inner is List) {
        list = inner;
      } else if (inner is Map<String, dynamic>) {
        if (inner['bookings'] is List) {
          list = inner['bookings'] as List;
        } else if (inner['data'] is List) {
          list = inner['data'] as List;
        }
        if (inner['summary'] is Map<String, dynamic>) {
          summary = BookingsSummary.fromJson(inner['summary'] as Map<String, dynamic>);
        }
      } else if (rawJson['bookings'] is List) {
        list = rawJson['bookings'] as List;
      }

      if (summary == null && rawJson['summary'] is Map<String, dynamic>) {
        summary = BookingsSummary.fromJson(rawJson['summary'] as Map<String, dynamic>);
      }
    }

    return BookingsListResponse(
      bookings: list
          .whereType<Map<String, dynamic>>()
          .map((b) => BookingModel.fromJson(b))
          .toList(),
      summary: summary,
    );
  }
}

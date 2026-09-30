/// Model for a single booking from GET /api/booking/list
class BookingModel {
  final String? id;
  final String? bookingId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? serviceName;
  final String? eventType;
  final String? eventDate;
  final String? eventTime;
  final int? guestCount;
  final String? venueLocation;
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
    this.serviceName,
    this.eventType,
    this.eventDate,
    this.eventTime,
    this.guestCount,
    this.venueLocation,
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
  bool get isCancelled =>
      status == 'Cancelled' || status == 'Rejected' || status == 'Declined';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      bookingId: json['bookingId']?.toString(),
      customerName: json['customerName']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      serviceName: json['serviceName']?.toString(),
      eventType: json['eventType']?.toString(),
      eventDate: json['eventDate']?.toString(),
      eventTime: json['eventTime']?.toString(),
      guestCount: json['guestCount'] is num
          ? (json['guestCount'] as num).toInt()
          : int.tryParse(json['guestCount']?.toString() ?? ''),
      venueLocation: json['venueLocation']?.toString(),
      city: json['city']?.toString(),
      totalAmount: json['totalAmount'] is num ? json['totalAmount'] : null,
      advancePaid: json['advancePaid'] is num ? json['advancePaid'] : null,
      paymentStatus: json['paymentStatus']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
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
        if (serviceName != null) 'serviceName': serviceName,
        if (eventType != null) 'eventType': eventType,
        if (eventDate != null) 'eventDate': eventDate,
        if (eventTime != null) 'eventTime': eventTime,
        if (guestCount != null) 'guestCount': guestCount,
        if (venueLocation != null) 'venueLocation': venueLocation,
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

  factory BookingsListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    return BookingsListResponse(
      bookings: data
          .whereType<Map<String, dynamic>>()
          .map((b) => BookingModel.fromJson(b))
          .toList(),
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? BookingsSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }
}

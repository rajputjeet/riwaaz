/// Model for GET /api/users/vendor/dashboard-stats
class DashboardStatsModel {
  final BookingsCount bookingsCount;
  final Financials financials;
  final PortfolioStats portfolioStats;
  final DashboardSubscription? subscription;
  final String? applicationStatus;
  final List<RecentBooking> recentBookings;

  DashboardStatsModel({
    required this.bookingsCount,
    required this.financials,
    required this.portfolioStats,
    this.subscription,
    this.applicationStatus,
    this.recentBookings = const [],
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> recent = json['recentBookings'] ?? [];
    return DashboardStatsModel(
      bookingsCount: json['bookingsCount'] != null
          ? BookingsCount.fromJson(
              json['bookingsCount'] as Map<String, dynamic>)
          : BookingsCount(),
      financials: json['financials'] != null
          ? Financials.fromJson(json['financials'] as Map<String, dynamic>)
          : Financials(),
      portfolioStats: json['portfolioStats'] != null
          ? PortfolioStats.fromJson(
              json['portfolioStats'] as Map<String, dynamic>)
          : PortfolioStats(),
      subscription: json['subscription'] != null &&
              json['subscription'] is Map<String, dynamic>
          ? DashboardSubscription.fromJson(
              json['subscription'] as Map<String, dynamic>)
          : null,
      applicationStatus: json['applicationStatus']?.toString(),
      recentBookings: recent
          .whereType<Map<String, dynamic>>()
          .map((b) => RecentBooking.fromJson(b))
          .toList(),
    );
  }
}

class BookingsCount {
  final int all;
  final int pending;
  final int upcoming;
  final int rejected;
  final int completed;

  BookingsCount({
    this.all = 0,
    this.pending = 0,
    this.upcoming = 0,
    this.rejected = 0,
    this.completed = 0,
  });

  factory BookingsCount.fromJson(Map<String, dynamic> json) {
    return BookingsCount(
      all: (json['all'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      upcoming: (json['upcoming'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
    );
  }
}

class Financials {
  final num totalRevenue;

  Financials({this.totalRevenue = 0});

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      totalRevenue: json['totalRevenue'] is num ? json['totalRevenue'] : 0,
    );
  }
}

class PortfolioStats {
  final int totalPackages;
  final int totalServices;
  final int totalPortfolioItems;

  PortfolioStats({
    this.totalPackages = 0,
    this.totalServices = 0,
    this.totalPortfolioItems = 0,
  });

  factory PortfolioStats.fromJson(Map<String, dynamic> json) {
    return PortfolioStats(
      totalPackages: (json['totalPackages'] as num?)?.toInt() ?? 0,
      totalServices: (json['totalServices'] as num?)?.toInt() ?? 0,
      totalPortfolioItems: (json['totalPortfolioItems'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardSubscription {
  final bool isSubscriptionActive;
  final bool isExpired;
  final int daysRemaining;
  final String? planTitle;
  final String? planType;
  final String? subscriptionEndDate;

  DashboardSubscription({
    this.isSubscriptionActive = false,
    this.isExpired = true,
    this.daysRemaining = 0,
    this.planTitle,
    this.planType,
    this.subscriptionEndDate,
  });

  factory DashboardSubscription.fromJson(Map<String, dynamic> json) {
    return DashboardSubscription(
      isSubscriptionActive: json['isSubscriptionActive'] ?? false,
      isExpired: json['isExpired'] ?? true,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      planTitle: json['planTitle']?.toString(),
      planType: json['planType']?.toString(),
      subscriptionEndDate: json['subscriptionEndDate']?.toString(),
    );
  }
}

class RecentBooking {
  final String? id;
  final String? bookingId;
  final String? customerName;
  final String? serviceName;
  final String? eventDate;
  final String? status;
  final num? totalAmount;

  RecentBooking({
    this.id,
    this.bookingId,
    this.customerName,
    this.serviceName,
    this.eventDate,
    this.status,
    this.totalAmount,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      id: (json['_id'] ?? json['id'])?.toString(),
      bookingId: json['bookingId']?.toString(),
      customerName: json['customerName']?.toString(),
      serviceName: json['serviceName']?.toString(),
      eventDate: json['eventDate']?.toString(),
      status: json['status']?.toString(),
      totalAmount: json['totalAmount'] is num ? json['totalAmount'] : null,
    );
  }
}

class SubscriptionModel {
  String? id;
  String? title;
  String? name;
  String? type;
  int? durationInMonths;
  String? duration;
  num? price;
  String? description;
  int? stateId;
  String? createdAt;

  SubscriptionModel({
    this.id,
    this.title,
    this.name,
    this.type,
    this.durationInMonths,
    this.duration,
    this.price,
    this.description,
    this.stateId,
    this.createdAt,
  });

  String get displayName => (title?.trim().isNotEmpty == true)
      ? title!.trim()
      : ((name?.trim().isNotEmpty == true)
            ? name!.trim()
            : (type?.trim().isNotEmpty == true
                  ? type!.trim()
                  : 'Subscription Plan'));

  int get planPrice => price?.toInt() ?? 0;
  int? get durationMonth => durationInMonths;
  int? get durationMonths => durationInMonths;
  String get durations => durationLabel;
  String get durationLabel {
    if (duration?.trim().isNotEmpty == true) return duration!.trim();
    if (type?.trim().isNotEmpty == true) return type!.trim();
    final months = durationInMonths;
    return months == null ? '' : '$months Month${months == 1 ? '' : 's'}';
  }

  static int parseDurationMonths(Map<String, dynamic> json) {
    for (final key in const [
      'durationInMonths',
      'durationMonths',
      'durationMonth',
      'duration_months',
      'duration_month',
    ]) {
      final value = num.tryParse(json[key]?.toString() ?? '');
      if (value != null && value.isFinite && value > 0) return value.toInt();
    }
    for (final key in const ['type', 'duration', 'durations']) {
      final value = json[key]?.toString().toLowerCase() ?? '';
      final match = RegExp(r'(\d+)\s*(year|month)s?').firstMatch(value);
      if (match != null) {
        final count = int.parse(match.group(1)!);
        if (count > 0) return count * (match.group(2) == 'year' ? 12 : 1);
      }
    }
    return 1;
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString(),
      name: (json['title'] ?? json['name'])?.toString(),
      type: json['type']?.toString(),
      durationInMonths: parseDurationMonths(json),
      duration:
          (json['duration']?.toString().trim().isNotEmpty == true
                  ? json['duration']
                  : json['durations'])
              ?.toString(),
      price: json['price'] is num
          ? json['price']
          : num.tryParse(json['price']?.toString() ?? ''),
      description: json['description']?.toString(),
      stateId: json['stateId'] is num
          ? (json['stateId'] as num).toInt()
          : int.tryParse(json['stateId']?.toString() ?? ''),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (title != null) 'title': title,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (durationInMonths != null) 'durationInMonths': durationInMonths,
      if (duration != null) 'duration': duration,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
      if (stateId != null) 'stateId': stateId,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}

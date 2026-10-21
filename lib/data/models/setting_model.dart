class SettingModel {
  final String? id;
  final String? contactEmail;
  final String? contactPhone;
  final String? instagram;
  final String? google;
  final String? facebook;
  final String? happyCustomersCount;
  final String? happyCustomersLabel;
  final String? locationsCount;
  final String? locationsLabel;
  final String? eventVendorsCount;
  final String? eventVendorsLabel;
  final String? eventServicesCount;
  final String? eventServicesLabel;
  final String? copyright;

  SettingModel({
    this.id,
    this.contactEmail,
    this.contactPhone,
    this.instagram,
    this.google,
    this.facebook,
    this.happyCustomersCount,
    this.happyCustomersLabel,
    this.locationsCount,
    this.locationsLabel,
    this.eventVendorsCount,
    this.eventVendorsLabel,
    this.eventServicesCount,
    this.eventServicesLabel,
    this.copyright,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json, {String? copyright}) {
    return SettingModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      contactEmail: json['contactEmail']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      instagram: json['instagram']?.toString(),
      google: json['google']?.toString(),
      facebook: json['facebook']?.toString(),
      happyCustomersCount: json['happyCustomersCount']?.toString(),
      happyCustomersLabel: json['happyCustomersLabel']?.toString(),
      locationsCount: json['locationsCount']?.toString(),
      locationsLabel: json['locationsLabel']?.toString(),
      eventVendorsCount: json['eventVendorsCount']?.toString(),
      eventVendorsLabel: json['eventVendorsLabel']?.toString(),
      eventServicesCount: json['eventServicesCount']?.toString(),
      eventServicesLabel: json['eventServicesLabel']?.toString(),
      copyright: copyright ?? json['copyright']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'contactEmail': contactEmail,
    'contactPhone': contactPhone,
    'instagram': instagram,
    'google': google,
    'facebook': facebook,
    'happyCustomersCount': happyCustomersCount,
    'happyCustomersLabel': happyCustomersLabel,
    'locationsCount': locationsCount,
    'locationsLabel': locationsLabel,
    'eventVendorsCount': eventVendorsCount,
    'eventVendorsLabel': eventVendorsLabel,
    'eventServicesCount': eventServicesCount,
    'eventServicesLabel': eventServicesLabel,
    'copyright': copyright,
  };

  /// Default configuration matching current verified platform settings
  static SettingModel get defaultSettings => SettingModel(
        id: "6ad513469bb1f2746f42c3a0",
        contactEmail: "contactwidoora@gmail.com",
        contactPhone: "02269-622566 ",
        instagram: "https://www.instagram.com/widoora.co/",
        google: "https://widoora.com",
        facebook: "https://www.facebook.com/profile.php?id=61594680102038",
        happyCustomersCount: "200+",
        happyCustomersLabel: "Happy Customers",
        locationsCount: "50+",
        locationsLabel: "Locations",
        eventVendorsCount: "100+",
        eventVendorsLabel: "Event Vendors",
        eventServicesCount: "50+",
        eventServicesLabel: "Event Services",
        copyright: "www.widoora.com",
      );

  /// Numeric phone string suitable for tel: URI (e.g. 02269622566)
  String get cleanPhone {
    final raw = (contactPhone ?? '').trim();
    if (raw.isEmpty) return '02269622566';
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    return digits.isNotEmpty ? digits : '02269622566';
  }

  /// WhatsApp international formatted phone (e.g. 912269622566)
  String get whatsAppPhone {
    final rawDigits = cleanPhone.replaceAll('+', '');
    if (rawDigits.startsWith('91') && rawDigits.length > 10) {
      return rawDigits;
    }
    if (rawDigits.startsWith('0')) {
      return '91${rawDigits.substring(1)}';
    }
    return '91$rawDigits';
  }

  /// Clean display telephone string
  String get displayPhone => (contactPhone ?? '02269-622566').trim();

  /// Clean display contact email
  String get displayEmail => (contactEmail ?? 'contactwidoora@gmail.com').trim();

  /// Clean Instagram profile URL
  String get displayInstagram =>
      (instagram ?? 'https://www.instagram.com/widoora.co/').trim();

  /// Clean Facebook page URL
  String get displayFacebook =>
      (facebook ?? 'https://www.facebook.com/profile.php?id=61594680102038').trim();

  /// Clean Website / Google URL
  String get displayWebsite => (google ?? 'https://widoora.com').trim();

  /// Clean Copyright text
  String get displayCopyright => (copyright ?? 'www.widoora.com').trim();
}

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
}

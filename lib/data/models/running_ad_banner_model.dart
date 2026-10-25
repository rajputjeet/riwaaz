class RunningAdCategoryModel {
  final String? id;
  final String? name;

  RunningAdCategoryModel({this.id, this.name});

  factory RunningAdCategoryModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return RunningAdCategoryModel(
        id: (json['_id'] ?? json['id'])?.toString(),
        name: (json['name'] ?? json['title'])?.toString(),
      );
    } else if (json is String) {
      return RunningAdCategoryModel(name: json);
    }
    return RunningAdCategoryModel();
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (name != null) 'name': name,
    };
  }
}

class RunningAdVendorModel {
  final String? id;
  final String? businessName;
  final String? fullName;
  final String? profileImg;
  final String? city;
  final RunningAdCategoryModel? category;
  final bool isVerified;

  RunningAdVendorModel({
    this.id,
    this.businessName,
    this.fullName,
    this.profileImg,
    this.city,
    this.category,
    this.isVerified = false,
  });

  String get displayName {
    if (businessName != null && businessName!.trim().isNotEmpty) {
      return businessName!.trim();
    }
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    return 'Verified Wedding Partner';
  }

  String get categoryName => category?.name ?? 'Wedding Partner';

  factory RunningAdVendorModel.fromJson(Map<String, dynamic> json) {
    return RunningAdVendorModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      businessName: json['businessName']?.toString(),
      fullName: json['fullName']?.toString(),
      profileImg: (json['profileImg'] ?? json['profileImage'] ?? json['image'])?.toString(),
      city: json['city']?.toString(),
      category: json['category'] != null
          ? RunningAdCategoryModel.fromJson(json['category'])
          : null,
      isVerified: json['isVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (businessName != null) 'businessName': businessName,
      if (fullName != null) 'fullName': fullName,
      if (profileImg != null) 'profileImg': profileImg,
      if (city != null) 'city': city,
      if (category != null) 'category': category!.toJson(),
      'isVerified': isVerified,
    };
  }
}

class RunningAdBannerModel {
  final String? id;
  final String? title;
  final String? bannerUrl;
  final String? imageUrl;
  final String? image;
  final String? duration;
  final int? durationInDays;
  final String? startDate;
  final String? endDate;
  final String? status;
  final bool isSponsoredAd;
  final int? type;
  final RunningAdVendorModel? vendor;

  RunningAdBannerModel({
    this.id,
    this.title,
    this.bannerUrl,
    this.imageUrl,
    this.image,
    this.duration,
    this.durationInDays,
    this.startDate,
    this.endDate,
    this.status,
    this.isSponsoredAd = false,
    this.type,
    this.vendor,
  });

  String get effectiveImageUrl {
    if (bannerUrl != null && bannerUrl!.trim().isNotEmpty) return bannerUrl!.trim();
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) return imageUrl!.trim();
    if (image != null && image!.trim().isNotEmpty) return image!.trim();
    return '';
  }

  String? get vendorId => vendor?.id;

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    if (vendor?.businessName != null && vendor!.businessName!.trim().isNotEmpty) {
      return vendor!.businessName!.trim();
    }
    return 'Featured Partner Boost';
  }

  factory RunningAdBannerModel.fromJson(Map<String, dynamic> json) {
    final typeVal = json['type'] is num
        ? (json['type'] as num).toInt()
        : int.tryParse(json['type']?.toString() ?? '');

    final isSponsored = json['isSponsoredAd'] == true ||
        typeVal == 99 ||
        json['vendor'] != null;

    final bannerPath = (json['bannerUrl'] ??
            json['imageUrl'] ??
            json['image'] ??
            (json['adBanner'] is Map ? json['adBanner']['url'] : null))
        ?.toString();

    return RunningAdBannerModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString(),
      bannerUrl: bannerPath,
      imageUrl: json['imageUrl']?.toString() ?? bannerPath,
      image: json['image']?.toString() ?? bannerPath,
      duration: json['duration']?.toString(),
      durationInDays: json['durationInDays'] is num
          ? (json['durationInDays'] as num).toInt()
          : int.tryParse(json['durationInDays']?.toString() ?? ''),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      isSponsoredAd: isSponsored,
      type: typeVal,
      vendor: json['vendor'] is Map<String, dynamic>
          ? RunningAdVendorModel.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (title != null) 'title': title,
      if (bannerUrl != null) 'bannerUrl': bannerUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (image != null) 'image': image,
      if (duration != null) 'duration': duration,
      if (durationInDays != null) 'durationInDays': durationInDays,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (status != null) 'status': status,
      'isSponsoredAd': isSponsoredAd,
      if (type != null) 'type': type,
      if (vendor != null) 'vendor': vendor!.toJson(),
    };
  }
}

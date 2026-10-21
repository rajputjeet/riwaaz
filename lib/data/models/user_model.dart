class VendorProfileModel {
  String? applicationId;
  String? applicationStatus;
  String? businessName;
  String? ownerName;
  String? businessDescription;
  String? businessAddress;
  String? city;
  String? state;
  String? pincode;
  String? addressUrl;
  String? yearsOfExperience;
  String? categoryId;
  String? aadharFrontUrl;
  String? aadharBackUrl;
  String? liveSelfieUrl;
  List<dynamic>? packages;
  List<dynamic>? portfolio;
  List<dynamic>? services;

  // Subscription expiry fields (from GET /api/users/profile)
  bool? isExpiringSoon;
  int? daysLeft;
  int? daysRemaining;
  String? expiringMessage;
  String? subscriptionStatus;

  // Subscription plan fields (from login response)
  bool? isSubscriptionActive;
  String? subscriptionStartDate;
  String? subscriptionEndDate;
  String? subscriptionPlanTitle;
  String? subscriptionPlanType;
  int? subscriptionPlanDurationMonths;
  int? subscriptionPlanPrice;

  // Sponsored Ad fields (from GET /api/ad/active-vendors)
  bool? isAdActive;
  String? adTitle;
  String? adDuration;
  int? adDurationInDays;
  String? adStartDate;
  String? adEndDate;
  int? adDaysLeft;
  int? adPriority;
  String? adBadge;

  VendorProfileModel({
    this.applicationId,
    this.applicationStatus,
    this.businessName,
    this.ownerName,
    this.businessDescription,
    this.businessAddress,
    this.city,
    this.state,
    this.pincode,
    this.addressUrl,
    this.yearsOfExperience,
    this.categoryId,
    this.aadharFrontUrl,
    this.aadharBackUrl,
    this.liveSelfieUrl,
    this.packages,
    this.portfolio,
    this.services,
    this.isExpiringSoon,
    this.daysLeft,
    this.daysRemaining,
    this.expiringMessage,
    this.subscriptionStatus,
    this.isSubscriptionActive,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionPlanTitle,
    this.subscriptionPlanType,
    this.subscriptionPlanDurationMonths,
    this.subscriptionPlanPrice,
    this.isAdActive,
    this.adTitle,
    this.adDuration,
    this.adDurationInDays,
    this.adStartDate,
    this.adEndDate,
    this.adDaysLeft,
    this.adPriority,
    this.adBadge,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    // subscriptionPlanId can be a Map (populated) or a String (ID only)
    final planRaw = json['subscriptionPlanId'];
    final planMap = planRaw is Map<String, dynamic> ? planRaw : null;
    final docs = json['documents'] is Map<String, dynamic>
        ? json['documents'] as Map<String, dynamic>
        : null;

    String? extractDocUrl(dynamic doc) {
      if (doc == null) return null;
      if (doc is Map) return doc['url']?.toString();
      if (doc is String && doc.trim().isNotEmpty) return doc.trim();
      return null;
    }

    return VendorProfileModel(
      applicationId: json['applicationId']?.toString(),
      applicationStatus: json['applicationStatus']?.toString(),
      businessName: json['businessName']?.toString(),
      ownerName: json['ownerName']?.toString(),
      businessDescription: json['businessDescription']?.toString() ?? json['description']?.toString(),
      businessAddress: json['businessAddress']?.toString() ?? json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      addressUrl: json['addressUrl']?.toString(),
      yearsOfExperience: json['yearsOfExperience']?.toString(),
      categoryId: json['categoryId']?.toString(),
      aadharFrontUrl: extractDocUrl(docs?['aadharFront'] ?? json['aadharFront']),
      aadharBackUrl: extractDocUrl(docs?['aadharBack'] ?? json['aadharBack']),
      liveSelfieUrl: extractDocUrl(docs?['liveSelfie'] ?? json['liveSelfie']),
      packages: json['packages'] is List ? (json['packages'] as List) : null,
      portfolio: json['portfolio'] is List ? (json['portfolio'] as List) : null,
      services: json['services'] is List ? (json['services'] as List) : null,
      isExpiringSoon: json['isExpiringSoon'] as bool?,
      daysLeft: json['daysLeft'] is int
          ? json['daysLeft']
          : int.tryParse(json['daysLeft']?.toString() ?? ''),
      daysRemaining: json['daysRemaining'] is int
          ? json['daysRemaining']
          : int.tryParse(json['daysRemaining']?.toString() ?? ''),
      expiringMessage: json['expiringMessage']?.toString(),
      subscriptionStatus: json['subscriptionStatus']?.toString(),
      isSubscriptionActive: json['isSubscriptionActive'] as bool?,
      subscriptionStartDate: json['subscriptionStartDate']?.toString(),
      subscriptionEndDate: json['subscriptionEndDate']?.toString(),
      subscriptionPlanTitle: planMap?['title']?.toString() ?? planMap?['name']?.toString(),
      subscriptionPlanType: planMap?['type']?.toString(),
      subscriptionPlanDurationMonths: planMap?['durationInMonths'] is int
          ? planMap!['durationInMonths']
          : int.tryParse(planMap?['durationInMonths']?.toString() ?? ''),
      subscriptionPlanPrice: planMap?['price'] is int
          ? planMap!['price']
          : int.tryParse(planMap?['price']?.toString() ?? ''),
      isAdActive: json['isAdActive'] as bool?,
      adTitle: json['adTitle']?.toString(),
      adDuration: json['adDuration']?.toString(),
      adDurationInDays: json['adDurationInDays'] is int
          ? json['adDurationInDays']
          : int.tryParse(json['adDurationInDays']?.toString() ?? ''),
      adStartDate: json['adStartDate']?.toString(),
      adEndDate: json['adEndDate']?.toString(),
      adDaysLeft: json['adDaysLeft'] is int
          ? json['adDaysLeft']
          : int.tryParse(json['adDaysLeft']?.toString() ?? ''),
      adPriority: json['adPriority'] is int
          ? json['adPriority']
          : int.tryParse(json['adPriority']?.toString() ?? ''),
      adBadge: json['adBadge']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (applicationId != null) 'applicationId': applicationId,
      if (applicationStatus != null) 'applicationStatus': applicationStatus,
      if (businessName != null) 'businessName': businessName,
      if (ownerName != null) 'ownerName': ownerName,
      if (businessDescription != null) 'businessDescription': businessDescription,
      if (businessAddress != null) 'businessAddress': businessAddress,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (addressUrl != null) 'addressUrl': addressUrl,
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
      if (categoryId != null) 'categoryId': categoryId,
      if (aadharFrontUrl != null) 'aadharFront': {'url': aadharFrontUrl},
      if (aadharBackUrl != null) 'aadharBack': {'url': aadharBackUrl},
      if (liveSelfieUrl != null) 'liveSelfie': {'url': liveSelfieUrl},
      if (packages != null) 'packages': packages,
      if (portfolio != null) 'portfolio': portfolio,
      if (services != null) 'services': services,
      if (isExpiringSoon != null) 'isExpiringSoon': isExpiringSoon,
      if (daysLeft != null) 'daysLeft': daysLeft,
      if (daysRemaining != null) 'daysRemaining': daysRemaining,
      if (expiringMessage != null) 'expiringMessage': expiringMessage,
      if (subscriptionStatus != null) 'subscriptionStatus': subscriptionStatus,
      if (isSubscriptionActive != null) 'isSubscriptionActive': isSubscriptionActive,
      if (subscriptionStartDate != null) 'subscriptionStartDate': subscriptionStartDate,
      if (subscriptionEndDate != null) 'subscriptionEndDate': subscriptionEndDate,
      if (isAdActive != null) 'isAdActive': isAdActive,
      if (adTitle != null) 'adTitle': adTitle,
      if (adDuration != null) 'adDuration': adDuration,
      if (adDurationInDays != null) 'adDurationInDays': adDurationInDays,
      if (adStartDate != null) 'adStartDate': adStartDate,
      if (adEndDate != null) 'adEndDate': adEndDate,
      if (adDaysLeft != null) 'adDaysLeft': adDaysLeft,
      if (adPriority != null) 'adPriority': adPriority,
      if (adBadge != null) 'adBadge': adBadge,
    };
  }
}

class UserModel {
  String? id;
  String? fullName;
  String? email;
  String? mobile;
  String? password;
  String? profileImgUrl;
  int? roleId; // 2 = Customer, 3 = Vendor Partner
  bool? isVerified;
  int? otp;

  // Geographic / Address details
  String? address;
  String? city;
  String? state;
  String? pincode;
  String? about;
  String? bio;

  // Verification Documents (Vendors)
  String? aadharFrontUrl;
  String? aadharBackUrl;
  String? liveSelfieUrl;

  // Server returns all three; we treat accessToken as the primary bearer token
  String? token;
  String? accessToken;
  String? refreshToken;

  bool? isFeatured;
  int? adPriority;
  String? adBadge;

  VendorProfileModel? vendorProfile;

  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.mobile,
    this.password,
    this.profileImgUrl,
    this.roleId,
    this.isVerified,
    this.otp,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.about,
    this.bio,
    this.aadharFrontUrl,
    this.aadharBackUrl,
    this.liveSelfieUrl,
    this.token,
    this.accessToken,
    this.refreshToken,
    this.isFeatured,
    this.adPriority,
    this.adBadge,
    this.vendorProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawToken = json['accessToken']?.toString() ??
        json['token']?.toString();

    String? extractDocUrl(dynamic doc) {
      if (doc == null) return null;
      if (doc is Map) return doc['url']?.toString();
      if (doc is String && doc.trim().isNotEmpty) return doc.trim();
      return null;
    }

    final docs = json['documents'] is Map<String, dynamic>
        ? json['documents'] as Map<String, dynamic>
        : null;

    final vpMap = json['vendorProfile'] != null && json['vendorProfile'] is Map<String, dynamic>
        ? json['vendorProfile'] as Map<String, dynamic>
        : null;

    final resolvedCity = json['city']?.toString() ?? vpMap?['city']?.toString();
    final resolvedState = json['state']?.toString() ?? vpMap?['state']?.toString();
    final resolvedPincode = json['pincode']?.toString() ?? vpMap?['pincode']?.toString();
    final resolvedAddress = json['address']?.toString() ??
        json['businessAddress']?.toString() ??
        vpMap?['businessAddress']?.toString();

    return UserModel(
      id: (json['_id'] ?? json['userId'] ?? json['id'])?.toString(),
      fullName: json['fullName']?.toString() ?? vpMap?['ownerName']?.toString() ?? vpMap?['businessName']?.toString(),
      email: json['email']?.toString(),
      mobile: (json['mobile'] ?? json['phone'])?.toString(),
      password: json['password']?.toString(),
      profileImgUrl: () {
        final url = json['profileImgId'] is Map
            ? json['profileImgId']['url']?.toString()
            : (json['profileImg']?.toString() ?? json['avatar']?.toString());
        return (url != null && url.trim().isNotEmpty) ? url.trim() : null;
      }(),
      roleId: json['roleId'] is int
          ? json['roleId']
          : int.tryParse(json['roleId']?.toString() ?? ''),
      isVerified: json['isVerified'] ?? false,
      otp: json['otp'] is int
          ? json['otp']
          : int.tryParse(json['otp']?.toString() ?? ''),
      address: resolvedAddress,
      city: resolvedCity,
      state: resolvedState,
      pincode: resolvedPincode,
      about: json['about']?.toString() ?? json['bio']?.toString() ?? vpMap?['businessDescription']?.toString(),
      bio: json['bio']?.toString() ?? json['about']?.toString() ?? vpMap?['businessDescription']?.toString(),
      aadharFrontUrl: extractDocUrl(json['aadharFront'] ?? docs?['aadharFront'] ?? vpMap?['aadharFront']),
      aadharBackUrl: extractDocUrl(json['aadharBack'] ?? docs?['aadharBack'] ?? vpMap?['aadharBack']),
      liveSelfieUrl: extractDocUrl(json['liveSelfie'] ?? docs?['liveSelfie'] ?? vpMap?['liveSelfie']),
      token: rawToken,
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      isFeatured: json['isFeatured'] as bool?,
      adPriority: json['adPriority'] is int
          ? json['adPriority']
          : int.tryParse(json['adPriority']?.toString() ?? ''),
      adBadge: json['adBadge']?.toString(),
      vendorProfile: vpMap != null ? VendorProfileModel.fromJson(vpMap) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (mobile != null) 'mobile': mobile,
      if (password != null) 'password': password,
      if (roleId != null) 'roleId': roleId,
      if (isVerified != null) 'isVerified': isVerified,
      if (otp != null) 'otp': otp,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (about != null) 'about': about,
      if (bio != null) 'bio': bio,
      if (aadharFrontUrl != null) 'aadharFront': {'url': aadharFrontUrl},
      if (aadharBackUrl != null) 'aadharBack': {'url': aadharBackUrl},
      if (liveSelfieUrl != null) 'liveSelfie': {'url': liveSelfieUrl},
      if (token != null) 'token': token,
      if (accessToken != null) 'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (isFeatured != null) 'isFeatured': isFeatured,
      if (adPriority != null) 'adPriority': adPriority,
      if (adBadge != null) 'adBadge': adBadge,
      if (vendorProfile != null) 'vendorProfile': vendorProfile!.toJson(),
    };
  }

  bool get isCustomer => roleId == 2;
  bool get isVendor => roleId == 3 || roleId == 4;

  /// The bearer token to attach to Authorization header
  String? get bearerToken => accessToken ?? token;
}

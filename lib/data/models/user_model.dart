class VendorProfileModel {
  String? applicationId;
  String? applicationStatus;
  String? businessName;
  String? ownerName;
  String? businessDescription;
  String? businessAddress;
  String? city;
  List<dynamic>? packages;
  List<dynamic>? portfolio;
  List<dynamic>? services;

  VendorProfileModel({
    this.applicationId,
    this.applicationStatus,
    this.businessName,
    this.ownerName,
    this.businessDescription,
    this.businessAddress,
    this.city,
    this.packages,
    this.portfolio,
    this.services,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      applicationId: json['applicationId']?.toString(),
      applicationStatus: json['applicationStatus']?.toString(),
      businessName: json['businessName']?.toString(),
      ownerName: json['ownerName']?.toString(),
      businessDescription: json['businessDescription']?.toString() ?? json['description']?.toString(),
      businessAddress: json['businessAddress']?.toString() ?? json['address']?.toString(),
      city: json['city']?.toString(),
      packages: json['packages'] is List ? (json['packages'] as List) : null,
      portfolio: json['portfolio'] is List ? (json['portfolio'] as List) : null,
      services: json['services'] is List ? (json['services'] as List) : null,
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
      if (packages != null) 'packages': packages,
      if (portfolio != null) 'portfolio': portfolio,
      if (services != null) 'services': services,
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

  // Server returns all three; we treat accessToken as the primary bearer token
  String? token;
  String? accessToken;
  String? refreshToken;

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
    this.token,
    this.accessToken,
    this.refreshToken,
    this.vendorProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawToken = json['accessToken']?.toString() ??
        json['token']?.toString();
    return UserModel(
      id: (json['_id'] ?? json['userId'] ?? json['id'])?.toString(),
      fullName: json['fullName']?.toString(),
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
      token: rawToken,
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      vendorProfile: json['vendorProfile'] != null &&
              json['vendorProfile'] is Map<String, dynamic>
          ? VendorProfileModel.fromJson(json['vendorProfile'])
          : null,
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
      if (token != null) 'token': token,
      if (accessToken != null) 'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (vendorProfile != null) 'vendorProfile': vendorProfile!.toJson(),
    };
  }

  bool get isCustomer => roleId == 2;
  bool get isVendor => roleId == 3 || roleId == 4;

  /// The bearer token to attach to Authorization header
  String? get bearerToken => accessToken ?? token;
}

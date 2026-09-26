import 'user_model.dart';

class VendorApplicationModel {
  String? applicationId;
  String? applicationStatus; // "Pending" | "Under Review" | "Approved" | "Rejected"
  bool? isVerified;
  VendorProfileModel? vendorProfile;
  UserModel? user;

  VendorApplicationModel({
    this.applicationId,
    this.applicationStatus,
    this.isVerified,
    this.vendorProfile,
    this.user,
  });

  factory VendorApplicationModel.fromJson(Map<String, dynamic> json) {
    return VendorApplicationModel(
      applicationId: json['applicationId']?.toString(),
      applicationStatus: json['applicationStatus']?.toString(),
      isVerified: json['isVerified'] ?? false,
      vendorProfile: json['vendorProfile'] != null &&
              json['vendorProfile'] is Map<String, dynamic>
          ? VendorProfileModel.fromJson(json['vendorProfile'])
          : null,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (applicationId != null) 'applicationId': applicationId,
      if (applicationStatus != null) 'applicationStatus': applicationStatus,
      if (isVerified != null) 'isVerified': isVerified,
      if (vendorProfile != null) 'vendorProfile': vendorProfile!.toJson(),
      if (user != null) 'user': user!.toJson(),
    };
  }
}

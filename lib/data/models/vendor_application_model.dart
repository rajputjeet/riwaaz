import 'profile_completion_model.dart';
import 'user_model.dart';

class VendorApplicationModel {
  String? applicationId;
  String?
  applicationStatus; // "Pending" | "Under Review" | "Approved" | "Rejected"
  bool? isVerified;
  bool? isProfileCompleted;
  ProfileCompletionModel? profileCompletion;
  VendorProfileModel? vendorProfile;
  UserModel? user;

  VendorApplicationModel({
    this.applicationId,
    this.applicationStatus,
    this.isVerified,
    this.isProfileCompleted,
    this.profileCompletion,
    this.vendorProfile,
    this.user,
  });

  factory VendorApplicationModel.fromJson(Map<String, dynamic> json) {
    return VendorApplicationModel(
      applicationId: json['applicationId']?.toString(),
      applicationStatus: json['applicationStatus']?.toString(),
      isVerified: json['isVerified'] ?? false,
      isProfileCompleted: json['isProfileCompleted'] as bool?,
      profileCompletion: json['profileCompletion'] is Map
          ? ProfileCompletionModel.fromJson(
              Map<String, dynamic>.from(json['profileCompletion']),
            )
          : null,
      vendorProfile:
          json['vendorProfile'] != null &&
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
      if (isProfileCompleted != null) 'isProfileCompleted': isProfileCompleted,
      if (profileCompletion != null)
        'profileCompletion': profileCompletion!.toJson(),
      if (vendorProfile != null) 'vendorProfile': vendorProfile!.toJson(),
      if (user != null) 'user': user!.toJson(),
    };
  }
}

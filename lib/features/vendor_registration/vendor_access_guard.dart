import 'package:flutter/material.dart';
import '../../data/api_provider/user_api_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/shared/data_response.dart';

class VendorRegistrationProgress {
  final UserModel profile;
  const VendorRegistrationProgress(this.profile);

  Set<String> get requiredMissingFields =>
      (profile.profileCompletion?.missingFields.toSet() ?? <String>{})
        ..remove('email');

  // Older completion responses still require email. Ignore that specific gap
  // only when the actual mandatory contact fields are already present.
  bool get _optionalEmailGap =>
      profile.profileCompletion?.missingFields.contains('email') == true &&
      profile.fullName?.trim().isNotEmpty == true &&
      profile.mobile?.trim().isNotEmpty == true &&
      profile.vendorProfile?.ownerName?.trim().isNotEmpty == true &&
      !requiredMissingFields.any({'fullName', 'ownerName', 'mobile'}.contains);

  bool get profileComplete {
    final steps = profile.profileCompletion?.steps ?? const <String, bool>{};
    final requiredStepsComplete = !steps.entries.any(
      (step) =>
          !step.value && !(step.key == 'basicDetails' && _optionalEmailGap),
    );
    final onlyOptionalEmailBlocked =
        _optionalEmailGap &&
        steps['businessDetails'] == true &&
        steps['category'] == true &&
        steps['documents'] == true;
    return requiredMissingFields.isEmpty &&
        requiredStepsComplete &&
        (profile.isProfileCompleted == true || onlyOptionalEmailBlocked);
  }

  // Existing expired subscriptions belong in the dashboard's renewal flow.
  bool get hasPurchasedPlan =>
      profile.vendorProfile?.isSubscriptionActive == true ||
      DateTime.tryParse(profile.vendorProfile?.subscriptionStartDate ?? '') !=
          null ||
      DateTime.tryParse(profile.vendorProfile?.subscriptionEndDate ?? '') !=
          null;

  bool get canEnterDashboard =>
      profile.isVendor && profileComplete && hasPurchasedPlan;

  int get resumeStep {
    if (profileComplete) return 5;
    final completion = profile.profileCompletion;
    final missing = requiredMissingFields;
    if (completion?.steps['category'] == false ||
        missing.contains('categoryId'))
      return 1;
    if ((completion?.steps['basicDetails'] == false && !_optionalEmailGap) ||
        completion?.steps['businessDetails'] == false ||
        missing.intersection({
          'fullName',
          'ownerName',
          'mobile',
          'businessName',
          'city',
          'businessAddress',
          'state',
          'pincode',
        }).isNotEmpty)
      return 2;
    if (completion?.steps['documents'] == false ||
        missing.intersection({
          'aadharFront',
          'aadharBack',
          'liveSelfie',
          'pan',
          'aadharBackOrLiveSelfie',
        }).isNotEmpty)
      return 3;
    return 1;
  }
}

/// Every dashboard entrance checks the current profile, including restored sessions.
class VendorAccessGuard extends StatefulWidget {
  final Future<DataResponse<UserModel>> Function()? loadProfile;
  final Widget Function(BuildContext, UserModel) completedBuilder;
  final Widget Function(BuildContext, UserModel) incompleteBuilder;
  const VendorAccessGuard({
    super.key,
    this.loadProfile,
    required this.completedBuilder,
    required this.incompleteBuilder,
  });

  @override
  State<VendorAccessGuard> createState() => _VendorAccessGuardState();
}

class _VendorAccessGuardState extends State<VendorAccessGuard> {
  UserModel? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result =
          await (widget.loadProfile ?? UserApiProvider().getProfile)();
      if (!mounted) return;
      if (result.isSuccess != true ||
          result.data == null ||
          !result.data!.isVendor) {
        setState(() {
          _loading = false;
          _error =
              result.message ?? 'Could not check your profile. Please retry.';
        });
        return;
      }
      setState(() {
        _profile = result.data;
        _loading = false;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = 'Could not check your profile. Please retry.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _error != null) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _loading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    }
    final profile = _profile!;
    return VendorRegistrationProgress(profile).canEnterDashboard
        ? widget.completedBuilder(context, profile)
        : widget.incompleteBuilder(context, profile);
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/data/models/user_model.dart';
import 'package:shaadi_hub/data/shared/data_response.dart';
import 'package:shaadi_hub/features/vendor_registration/vendor_access_guard.dart';

UserModel profile({
  bool? completed,
  bool active = true,
  List<String> missing = const [],
  Map<String, bool> steps = const {},
}) => UserModel.fromJson({
  'roleId': 3,
  'fullName': 'Amit Verma',
  'mobile': '9812345678',
  'isVerified': true,
  if (completed != null) 'isProfileCompleted': completed,
  'profileCompletion': {'missingFields': missing, 'steps': steps},
  'vendorProfile': {
    'ownerName': 'Amit Verma',
    'applicationStatus': 'Approved',
    'isSubscriptionActive': active,
  },
});

Widget guard(Future<DataResponse<UserModel>> Function() load) => MaterialApp(
  home: VendorAccessGuard(
    loadProfile: load,
    completedBuilder: (_, _) => const Scaffold(body: Text('Vendor Home')),
    incompleteBuilder: (_, user) => Scaffold(
      body: Text(
        'Complete step ${VendorRegistrationProgress(user).resumeStep}',
      ),
    ),
  ),
);

void main() {
  test('approval and an active plan never bypass incomplete registration', () {
    final progress = VendorRegistrationProgress(
      profile(
        completed: false,
        missing: ['businessName', 'categoryId', 'aadharFront'],
      ),
    );
    expect(progress.canEnterDashboard, isFalse);
    expect(progress.resumeStep, 1);
  });

  test('missing details choose the first required registration step', () {
    expect(
      VendorRegistrationProgress(
        profile(completed: false, missing: ['mobile']),
      ).resumeStep,
      2,
    );
    expect(
      VendorRegistrationProgress(
        profile(completed: false, missing: ['city', 'pan']),
      ).resumeStep,
      2,
    );
    expect(
      VendorRegistrationProgress(
        profile(completed: false, missing: ['aadharBackOrLiveSelfie']),
      ).resumeStep,
      3,
    );
    expect(
      VendorRegistrationProgress(
        profile(completed: false, steps: {'documents': false}),
      ).resumeStep,
      3,
    );
  });

  test(
    'optional email alone allows subscription without bypassing payment',
    () {
      final user = profile(
        completed: false,
        active: false,
        missing: ['email'],
        steps: {
          'basicDetails': false,
          'businessDetails': true,
          'category': true,
          'documents': true,
        },
      );
      final progress = VendorRegistrationProgress(user);
      expect(progress.profileComplete, isTrue);
      expect(progress.resumeStep, 5);
      expect(progress.canEnterDashboard, isFalse);
      user.vendorProfile!.isSubscriptionActive = true;
      expect(progress.canEnterDashboard, isTrue);
    },
  );

  test(
    'optional email never hides missing documents or mandatory contact data',
    () {
      final user = profile(
        completed: false,
        missing: ['email', 'pan'],
        steps: {
          'basicDetails': false,
          'businessDetails': true,
          'category': true,
          'documents': false,
        },
      );
      final progress = VendorRegistrationProgress(user);
      expect(progress.profileComplete, isFalse);
      expect(progress.resumeStep, 3);
      user.mobile = '';
      expect(progress.profileComplete, isFalse);
      expect(progress.resumeStep, 2);
    },
  );

  testWidgets('blank optional email resumes at subscription after restart', (
    tester,
  ) async {
    await tester.pumpWidget(
      guard(
        () async => DataResponse(
          isSuccess: true,
          data: profile(
            completed: false,
            active: false,
            missing: ['email'],
            steps: {
              'basicDetails': false,
              'businessDetails': true,
              'category': true,
              'documents': true,
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Complete step 5'), findsOneWidget);
    expect(find.text('Complete step 2'), findsNothing);
    expect(find.text('Vendor Home'), findsNothing);
  });

  test('completion has conservative fallbacks and survives serialization', () {
    for (final data in [
      {
        'profileCompletion': {'isProfileCompleted': true},
      },
      {
        'vendorProfile': {'isProfileCompleted': true},
      },
    ]) {
      final user = UserModel.fromJson({'roleId': 3, ...data});
      expect(user.isProfileCompleted, isTrue);
      expect(UserModel.fromJson(user.toJson()).isProfileCompleted, isTrue);
    }
    final conflict = UserModel.fromJson({
      'isProfileCompleted': false,
      'vendorProfile': {'isProfileCompleted': true},
    });
    expect(conflict.isProfileCompleted, isFalse);
    expect(VendorRegistrationProgress(profile()).canEnterDashboard, isFalse);
    expect(
      VendorRegistrationProgress(
        profile(completed: true, missing: ['pan']),
      ).canEnterDashboard,
      isFalse,
    );
  });

  test(
    'first purchase is required but expired subscribers can access renewal',
    () {
      final unpaid = VendorRegistrationProgress(
        profile(completed: true, active: false),
      );
      expect(unpaid.canEnterDashboard, isFalse);
      expect(unpaid.resumeStep, 5);
      final expired = profile(completed: true, active: false);
      expired.vendorProfile!.subscriptionEndDate = '2020-01-01T00:00:00Z';
      expect(VendorRegistrationProgress(expired).canEnterDashboard, isTrue);
    },
  );

  testWidgets('restart waits for the server and blocks incomplete vendors', (
    tester,
  ) async {
    final pending = Completer<DataResponse<UserModel>>();
    await tester.pumpWidget(guard(() => pending.future));
    expect(find.text('Vendor Home'), findsNothing);
    pending.complete(
      DataResponse(
        isSuccess: true,
        data: profile(completed: false, missing: ['pan']),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Complete step 3'), findsOneWidget);
    expect(find.text('Vendor Home'), findsNothing);
  });

  testWidgets(
    'failed profile request stays blocked and retry checks fresh status',
    (tester) async {
      var requests = 0;
      await tester.pumpWidget(
        guard(() async {
          requests++;
          return requests == 1
              ? DataResponse(
                  isSuccess: false,
                  message: 'Connection unavailable',
                )
              : DataResponse(isSuccess: true, data: profile(completed: true));
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('Vendor Home'), findsNothing);
      expect(find.text('Connection unavailable'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(requests, 2);
      expect(find.text('Vendor Home'), findsOneWidget);
    },
  );

  testWidgets(
    'missing completion metadata does not use approval as a fallback',
    (tester) async {
      await tester.pumpWidget(
        guard(() async => DataResponse(isSuccess: true, data: profile())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Vendor Home'), findsNothing);
      expect(find.text('Complete step 1'), findsOneWidget);
    },
  );
}

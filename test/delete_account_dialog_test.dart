import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/shared/widgets/delete_account_dialog.dart';

void main() {
  testWidgets('requires a reason and retains it after an API failure', (
    tester,
  ) async {
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeleteAccountDialog(
            onDelete: (reason) async {
              submitted = reason;
              return 'Please try again later.';
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Delete Permanently'));
    await tester.pump();
    expect(submitted, isNull);
    expect(find.text('Please enter a reason to continue.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '  No longer needed  ');
    await tester.tap(find.text('Delete Permanently'));
    await tester.pumpAndSettle();
    expect(submitted, 'No longer needed');
    expect(find.text('Please try again later.'), findsOneWidget);
    expect(find.text('Keep Account'), findsOneWidget);
  });

  testWidgets('Keep Account closes without deleting', (tester) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => DeleteAccountDialog.show(
                context: context,
                isVendor: true,
                onDelete: (_) async {
                  called = true;
                  return null;
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Vendor Account?'), findsOneWidget);
    await tester.tap(find.text('Keep Account'));
    await tester.pumpAndSettle();
    expect(called, isFalse);
    expect(find.byType(DeleteAccountDialog), findsNothing);
  });
}

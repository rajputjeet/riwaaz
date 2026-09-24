import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/main.dart';

void main() {
  testWidgets('Riwaaz app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RiwaazApp());
    expect(find.byType(RiwaazApp), findsOneWidget);
    // Pump through splash timers
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 500));
  });
}

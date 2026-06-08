import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/main.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AttendanceScannerApp());

    // Verify that our app renders the DashboardScreen.
    expect(find.byType(AttendanceScannerApp), findsOneWidget);
  });
}

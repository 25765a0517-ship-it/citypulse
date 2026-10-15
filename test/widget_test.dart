import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citypulse/main.dart';

void main() {
  testWidgets('CityPulse app boots into ProviderScope with MaterialApp.router', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CityPulseApp(),
      ),
    );

    // Pump frames to render UI
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify app builds without crashing
    expect(find.byType(CityPulseApp), findsOneWidget);

    // Complete splash timer
    await tester.pump(const Duration(seconds: 3));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fitness_geni/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen displays properly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Check if progress indicator is present
    expect(find.text('Step 1 of 5'), findsOneWidget);

    // Check if weight screen is showing
    expect(find.text('What\'s your current weight?'), findsOneWidget);
  });
}

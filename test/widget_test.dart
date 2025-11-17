// C:/dev/flutter_projects/deluxe/test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Correctly import the main app file.
// Note: The path should be relative to the 'test' directory.
import 'package:deluxe/main.dart';

void main() {
  // Group tests related to the app startup and initial screen.
  group('App Startup Smoke Test', () {

    // This test verifies that the app initializes and displays the initial screen without crashing.
    testWidgets('should display the initial AgeGateWrapper screen with title', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      // FIX: Replaced the non-existent 'MyApp' with our actual root widget, 'ItalVibesApp'.
      await tester.pumpWidget(const ItalVibesApp());

      // After the first frame, we expect to see our placeholder UI.
      // This verifies that the theme loads and the home widget is rendered.
      expect(find.text('ITALVIBES'), findsOneWidget);
      expect(find.text('Age Gate Check...'), findsOneWidget);

      // Verify that a CircularProgressIndicator is present, confirming the loading state.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify that the old counter text is NOT present.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsNothing);
    });

  });
}

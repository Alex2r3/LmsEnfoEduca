// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enfoeduca/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap in a MultiProvider if necessary, but MyApp already does that in main()
    // However, for testing, we might need a simpler setup or mock the providers.
    // For now, let's just check if it pumps.
    await tester.pumpWidget(const MyApp());

    // Verify that our app name is present on the login screen.
    expect(find.text('EnfoEduca'), findsAtLeast(1));
    expect(find.text('INGRESAR'), findsOneWidget);
  });
}

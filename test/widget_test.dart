import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boredom/main.dart';

void main() {
  testWidgets('Boredom app boots without crashing', (WidgetTester tester) async {
    // Mock SharedPreferences so StorageService never touches the real
    // platform channel, which does not exist in the test environment.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BoredomApp());

    // First render: still waiting for progress to load from storage (see
    // _AppGate in main.dart), so the loading indicator shows first.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Give init() (SharedPreferences reads) time to finish. Deliberately
    // not pumpAndSettle(): CircularProgressIndicator has an infinite
    // animation that would never let pumpAndSettle() complete.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('YOU ARE BORED.'), findsOneWidget);
  });
}

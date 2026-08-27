import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boredom/main.dart';

void main() {
  testWidgets('Boredom app boots without crashing', (WidgetTester tester) async {
    // Mock SharedPreferences biar StorageService nggak nabrak platform
    // channel asli yang nggak ada di environment test.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BoredomApp());

    // Render pertama: masih nunggu progress ke-load dari storage (lihat
    // _AppGate di main.dart), jadi yang muncul duluan loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Kasih waktu buat init() (baca SharedPreferences) kelar. Sengaja
    // nggak pakai pumpAndSettle() karena CircularProgressIndicator punya
    // animasi tak-terhingga yang bikin pumpAndSettle() nggak pernah selesai.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('YOU ARE BORED.'), findsOneWidget);
  });
}

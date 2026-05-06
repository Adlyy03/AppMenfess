// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfess_app/core/neo_brutalism_theme.dart';

void main() {
  testWidgets('Neo-brutalism theme loads correctly', (WidgetTester tester) async {
    // Build a simple widget with the theme
    await tester.pumpWidget(
      MaterialApp(
        theme: NeoBrutalismTheme.theme,
        home: const Scaffold(
          body: Center(
            child: Text('Test App'),
          ),
        ),
      ),
    );

    // Verify that the widget renders
    expect(find.text('Test App'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Theme colors are correctly defined', (WidgetTester tester) async {
    // Test that theme colors are not null and have expected values
    expect(NeoBrutalismTheme.yellow, equals(const Color(0xFFFFD600)));
    expect(NeoBrutalismTheme.red, equals(const Color(0xFFFF3B3B)));
    expect(NeoBrutalismTheme.blue, equals(const Color(0xFF0057FF)));
    expect(NeoBrutalismTheme.black, equals(const Color(0xFF000000)));
    expect(NeoBrutalismTheme.white, equals(const Color(0xFFFFFFFF)));
    expect(NeoBrutalismTheme.green, equals(const Color(0xFF00FF00)));
  });

  testWidgets('Border constants are correctly defined', (WidgetTester tester) async {
    // Test border width constants
    expect(NeoBrutalismTheme.borderWidth, equals(4.0));
    expect(NeoBrutalismTheme.borderWidthThin, equals(3.0));
    expect(NeoBrutalismTheme.borderRadius, equals(0.0));
  });
}

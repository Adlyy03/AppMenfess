import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfess_app/widgets/user/share_bottom_sheet.dart';
import 'package:menfess_app/models/menfess_model.dart';
import 'package:menfess_app/core/neo_brutalism_theme.dart';

void main() {
  group('ShareBottomSheet Widget Tests', () {
    late MenfessModel testMenfess;

    setUp(() {
      testMenfess = MenfessModel(
        id: 'test-menfess-123',
        userId: 'user-456',
        message: 'This is a test menfess message for sharing functionality',
        likeCount: 5,
        viewCount: 10,
        commentCount: 3,
        isBookmarked: false,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
    });

    testWidgets('should display share bottom sheet with all options', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: NeoBrutalismTheme.theme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ShareBottomSheet.show(context, testMenfess),
                child: const Text('Show Share Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the bottom sheet
      await tester.tap(find.text('Show Share Sheet'));
      await tester.pumpAndSettle();

      // Verify that the bottom sheet is displayed
      expect(find.text('BAGIKAN MENFESS'), findsOneWidget);
      expect(find.text('PREVIEW:'), findsOneWidget);
      expect(find.text('PILIH CARA BERBAGI:'), findsOneWidget);

      // Verify share options are present
      expect(find.text('BAGIKAN UMUM'), findsOneWidget);
      expect(find.text('WHATSAPP'), findsOneWidget);
      expect(find.text('SALIN LINK'), findsOneWidget);
      expect(find.text('QR CODE'), findsOneWidget);
    });

    testWidgets('should display menfess preview correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeoBrutalismTheme.theme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ShareBottomSheet.show(context, testMenfess),
                child: const Text('Show Share Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Share Sheet'));
      await tester.pumpAndSettle();

      // Verify menfess stats are displayed
      expect(find.textContaining('💬 3'), findsOneWidget); // comment count
      expect(find.textContaining('❤️ 5'), findsOneWidget); // like count
      expect(find.textContaining('👀 10'), findsOneWidget); // view count
    });

    testWidgets('should truncate long messages in preview', (WidgetTester tester) async {
      // Create a menfess with a very long message
      final longMenfess = testMenfess.copyWith(
        message: 'A' * 100, // 100 characters
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: NeoBrutalismTheme.theme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ShareBottomSheet.show(context, longMenfess),
                child: const Text('Show Share Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Share Sheet'));
      await tester.pumpAndSettle();

      // Verify that the message is truncated (should contain "...")
      expect(find.textContaining('...'), findsOneWidget);
    });

    testWidgets('should display share link preview', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeoBrutalismTheme.theme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ShareBottomSheet.show(context, testMenfess),
                child: const Text('Show Share Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Share Sheet'));
      await tester.pumpAndSettle();

      // Verify that the share link is displayed
      expect(find.textContaining('https://menfess.skanic.com/p/test-menfess-123'), findsOneWidget);
    });

    testWidgets('should close when close button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeoBrutalismTheme.theme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ShareBottomSheet.show(context, testMenfess),
                child: const Text('Show Share Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Share Sheet'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is open
      expect(find.text('BAGIKAN MENFESS'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify bottom sheet is closed
      expect(find.text('BAGIKAN MENFESS'), findsNothing);
    });
  });
}
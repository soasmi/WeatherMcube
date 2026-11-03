import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mcube/features/weather/widgets/weather_search_bar.dart';

void main() {
  group('WeatherSearchBar Widget Tests', () {
    testWidgets(
      'rejects empty and whitespace-only searches without calling callback',
      (WidgetTester tester) async {
        String? submittedQuery;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeatherSearchBar(
                onSearch: (query) => submittedQuery = query,
              ),
            ),
          ),
        );

        // Tap SEARCH button while empty
        await tester.tap(find.text('SEARCH'));
        await tester.pump();
        expect(submittedQuery, isNull);

        // Enter only spaces and tap SEARCH
        await tester.enterText(find.byType(TextField), '     ');
        await tester.tap(find.text('SEARCH'));
        await tester.pump();
        expect(submittedQuery, isNull);
      },
    );

    testWidgets('trims input and triggers onSearch callback on submit', (
      WidgetTester tester,
    ) async {
      String? submittedQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherSearchBar(onSearch: (query) => submittedQuery = query),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '  London  ');
      await tester.tap(find.text('SEARCH'));
      await tester.pump();

      expect(submittedQuery, equals('London'));
    });

    testWidgets('clear button clears input text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WeatherSearchBar(onSearch: (_) {}))),
      );

      await tester.enterText(find.byType(TextField), 'Paris');
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.text('Paris'), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });
}

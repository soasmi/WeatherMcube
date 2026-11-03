import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mcube/features/weather/widgets/theme_selector_sheet.dart';

void main() {
  group('ThemeSelectorSheet Widget Tests', () {
    testWidgets('renders all 3 theme options and triggers callback on tap', (
      WidgetTester tester,
    ) async {
      ThemeMode? selectedMode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ThemeSelectorSheet.show(
                      context: context,
                      currentMode: ThemeMode.system,
                      onSelectMode: (mode) => selectedMode = mode,
                    );
                  },
                  child: const Text('OPEN THEME'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN THEME'));
      await tester.pumpAndSettle();

      expect(find.text('APPEARANCE & THEME'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Matte Carbon (Dark)'), findsOneWidget);
      expect(find.text('Industrial Chalk (Light)'), findsOneWidget);

      await tester.tap(find.text('Matte Carbon (Dark)'));
      await tester.pumpAndSettle();

      expect(selectedMode, equals(ThemeMode.dark));
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_mcube/app.dart';
import 'package:weather_mcube/features/weather/providers/weather_provider.dart';

void main() {
  testWidgets('WeatherApp smoke test renders search and empty state', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const WeatherApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('METEO'), findsOneWidget);
    expect(find.text('MCUBE'), findsOneWidget);
    expect(find.text('SEARCH'), findsOneWidget);
    expect(find.text('NO ACTIVE WEATHER TELEMETRY'), findsOneWidget);
  });
}

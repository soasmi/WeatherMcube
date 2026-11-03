import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mcube/core/utils/temperature_formatter.dart';
import 'package:weather_mcube/data/models/current_weather.dart';
import 'package:weather_mcube/data/models/forecast_day.dart';
import 'package:weather_mcube/data/models/location_item.dart';
import 'package:weather_mcube/data/models/weather_data.dart';
import 'package:weather_mcube/features/weather/widgets/current_weather_view.dart';

void main() {
  group('CurrentWeatherView Widget Tests', () {
    final sampleData = WeatherData(
      location: const LocationItem(
        id: 1,
        name: 'Monte Carlo',
        latitude: 43.73,
        longitude: 7.42,
        country: 'Monaco',
        countryCode: 'MC',
      ),
      current: CurrentWeather(
        time: DateTime.parse('2026-11-03T14:30:00'),
        temperature: 22.4,
        relativeHumidity: 60,
        weatherCode: 0,
        windSpeed: 15.0,
      ),
      dailyForecast: [
        ForecastDay(
          date: DateTime.parse('2026-11-03'),
          weatherCode: 0,
          maxTemp: 24.0,
          minTemp: 16.0,
        ),
      ],
      fetchedAt: DateTime.parse('2026-11-03T14:30:00'),
      isFromCache: false,
    );

    testWidgets(
      'renders location, formatted temp, and telemetry metrics in Celsius',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CurrentWeatherView(
                data: sampleData,
                unit: TemperatureUnit.celsius,
              ),
            ),
          ),
        );

        expect(find.text('Monte Carlo'), findsOneWidget);
        expect(find.text('Monaco'), findsOneWidget);
        expect(find.text('22°C'), findsOneWidget);
        expect(find.text('CLEAR SKY'), findsOneWidget);
        expect(find.text('60%'), findsOneWidget);
        expect(find.text('COMFORTABLE'), findsOneWidget);
        expect(find.text('15.0 km/h'), findsOneWidget);
        expect(find.text('MODERATE BREEZE'), findsOneWidget);
      },
    );

    testWidgets('renders formatted temp and wind speed in Fahrenheit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeatherView(
              data: sampleData,
              unit: TemperatureUnit.fahrenheit,
            ),
          ),
        ),
      );

      // 22.4°C -> 72°F
      expect(find.text('72°F'), findsOneWidget);
      // 15 km/h -> 9.3 mph
      expect(find.text('9.3 mph'), findsOneWidget);
    });
  });
}

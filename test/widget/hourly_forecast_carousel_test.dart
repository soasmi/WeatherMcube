import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mcube/core/utils/temperature_formatter.dart';
import 'package:weather_mcube/data/models/hourly_forecast_item.dart';
import 'package:weather_mcube/features/weather/widgets/hourly_forecast_carousel.dart';

void main() {
  group('HourlyForecastCarousel Widget Tests', () {
    final sampleHourly = [
      HourlyForecastItem(
        time: DateTime.now(),
        temperature: 15.0,
        humidity: 60,
        precipitationProbability: 0,
        weatherCode: 0,
        uvIndex: 2.5,
      ),
      HourlyForecastItem(
        time: DateTime.now().add(const Duration(hours: 1)),
        temperature: 16.5,
        humidity: 65,
        precipitationProbability: 45,
        weatherCode: 61,
        uvIndex: 5.0,
      ),
      HourlyForecastItem(
        time: DateTime.now().add(const Duration(hours: 2)),
        temperature: 14.0,
        humidity: 70,
        precipitationProbability: 70,
        weatherCode: 63,
        uvIndex: 7.5,
      ),
    ];

    testWidgets(
      'renders NOW pill, temperatures, and precipitation probabilities',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HourlyForecastCarousel(
                hourlyForecast: sampleHourly,
                unit: TemperatureUnit.celsius,
              ),
            ),
          ),
        );

        expect(find.text('24-HOUR FORECAST & TELEMETRY'), findsOneWidget);
        expect(find.text('NOW'), findsOneWidget);
        expect(find.text('15°C'), findsOneWidget);
        expect(find.text('17°C'), findsOneWidget);
        expect(find.text('45%'), findsOneWidget);
        expect(find.text('70%'), findsOneWidget);
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mcube/core/utils/temperature_formatter.dart';

void main() {
  group('WeatherUnits', () {
    test('converts Celsius to Fahrenheit accurately', () {
      expect(
        WeatherUnits.toTargetTemperature(0, TemperatureUnit.fahrenheit),
        32,
      );
      expect(
        WeatherUnits.toTargetTemperature(20, TemperatureUnit.fahrenheit),
        68,
      );
      expect(
        WeatherUnits.toTargetTemperature(100, TemperatureUnit.fahrenheit),
        212,
      );
    });

    test('formats temperature with correct symbol', () {
      expect(
        WeatherUnits.formatTemperature(21.4, TemperatureUnit.celsius),
        '21°C',
      );
      expect(
        WeatherUnits.formatTemperature(21.4, TemperatureUnit.fahrenheit),
        '71°F',
      );
    });

    test('formats wind speed according to selected unit', () {
      expect(
        WeatherUnits.formatWindSpeed(10.0, TemperatureUnit.celsius),
        '10.0 km/h',
      );
      expect(
        WeatherUnits.formatWindSpeed(10.0, TemperatureUnit.fahrenheit),
        '6.2 mph',
      );
    });
  });
}

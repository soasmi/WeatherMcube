import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mcube/data/models/current_weather.dart';
import 'package:weather_mcube/data/models/forecast_day.dart';
import 'package:weather_mcube/data/models/location_item.dart';
import 'package:weather_mcube/data/models/weather_data.dart';

void main() {
  group('Model Parsing & Serialization', () {
    test('LocationItem parses correctly and formats subtitle', () {
      final jsonWithAdmin = {
        'id': 2950159,
        'name': 'Berlin',
        'latitude': 52.52,
        'longitude': 13.41,
        'country': 'Germany',
        'admin1': 'State of Berlin',
        'country_code': 'DE',
      };

      final item = LocationItem.fromJson(jsonWithAdmin);
      expect(item.id, 2950159);
      expect(item.name, 'Berlin');
      expect(item.latitude, 52.52);
      expect(item.longitude, 13.41);
      expect(item.country, 'Germany');
      expect(item.admin1, 'State of Berlin');
      expect(item.countryCode, 'DE');
      expect(item.subtitle, 'State of Berlin, Germany');

      final jsonWithoutAdmin = {
        'id': 12345,
        'name': 'Monaco',
        'latitude': 43.73,
        'longitude': 7.42,
        'country': 'Monaco',
        'admin1': null,
      };

      final monaco = LocationItem.fromJson(jsonWithoutAdmin);
      expect(monaco.subtitle, 'Monaco');
    });

    test('CurrentWeather parses numeric values safely', () {
      final json = {
        'time': '2026-11-03T10:00',
        'temperature_2m': 14.5,
        'relative_humidity_2m': 65,
        'weather_code': 3,
        'wind_speed_10m': 18.2,
      };

      final current = CurrentWeather.fromJson(json);
      expect(current.temperature, 14.5);
      expect(current.relativeHumidity, 65);
      expect(current.weatherCode, 3);
      expect(current.windSpeed, 18.2);
    });

    test('ForecastDay parses parallel arrays safely', () {
      final day = ForecastDay.fromParallelArrays(
        dateString: '2026-11-04',
        rawCode: 61,
        rawMax: 16.8,
        rawMin: 8.2,
      );

      expect(day.weatherCode, 61);
      expect(day.maxTemp, 16.8);
      expect(day.minTemp, 8.2);
    });

    test(
      'WeatherData serializes to JSON and restores accurately for cache',
      () {
        const location = LocationItem(
          id: 100,
          name: 'Tokyo',
          latitude: 35.68,
          longitude: 139.76,
          country: 'Japan',
          admin1: 'Tokyo',
          countryCode: 'JP',
        );

        final current = CurrentWeather(
          time: DateTime.parse('2026-11-03T12:00:00'),
          temperature: 19.0,
          relativeHumidity: 50,
          weatherCode: 0,
          windSpeed: 8.5,
        );

        final forecast = [
          ForecastDay(
            date: DateTime.parse('2026-11-03'),
            weatherCode: 0,
            maxTemp: 20.0,
            minTemp: 12.0,
          ),
          ForecastDay(
            date: DateTime.parse('2026-11-04'),
            weatherCode: 2,
            maxTemp: 21.0,
            minTemp: 13.0,
          ),
        ];

        final original = WeatherData(
          location: location,
          current: current,
          dailyForecast: forecast,
          fetchedAt: DateTime.parse('2026-11-03T12:00:00'),
          isFromCache: false,
        );

        final json = original.toJson();
        final restored = WeatherData.fromJson(json);

        expect(restored.location.name, 'Tokyo');
        expect(restored.location.latitude, 35.68);
        expect(restored.current.temperature, 19.0);
        expect(restored.dailyForecast.length, 2);
        expect(restored.dailyForecast[1].maxTemp, 21.0);
      },
    );
  });
}

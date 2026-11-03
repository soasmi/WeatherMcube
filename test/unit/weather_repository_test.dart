import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_mcube/core/errors/app_exceptions.dart';
import 'package:weather_mcube/data/models/current_weather.dart';
import 'package:weather_mcube/data/models/forecast_day.dart';
import 'package:weather_mcube/data/models/location_item.dart';
import 'package:weather_mcube/data/models/weather_data.dart';
import 'package:weather_mcube/data/repositories/weather_repository.dart';
import 'package:weather_mcube/data/services/open_meteo_api_client.dart';
import 'package:weather_mcube/data/services/weather_storage_service.dart';

void main() {
  group('WeatherRepository Cache & Fallback', () {
    const testLocation = LocationItem(
      id: 1,
      name: 'Amsterdam',
      latitude: 52.37,
      longitude: 4.89,
      country: 'Netherlands',
    );

    test('saves fresh weather data to local storage on success', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = WeatherStorageService(prefs);

      final forecastPayload = jsonEncode({
        'current': {
          'time': '2026-11-03T12:00',
          'temperature_2m': 11.0,
          'relative_humidity_2m': 80,
          'weather_code': 1,
          'wind_speed_10m': 12.0,
        },
        'daily': {
          'time': ['2026-11-03'],
          'weather_code': [1],
          'temperature_2m_max': [13.0],
          'temperature_2m_min': [7.0],
        },
      });

      final mockClient = MockClient((request) async {
        return http.Response(forecastPayload, 200);
      });

      final apiClient = OpenMeteoApiClient(client: mockClient);
      final repo = WeatherRepository(
        apiClient: apiClient,
        storageService: storage,
      );

      final result = await repo.fetchWeather(location: testLocation);

      expect(result.location.name, 'Amsterdam');
      expect(result.isFromCache, isFalse);

      final cached = storage.getLastSavedWeather();
      expect(cached, isNotNull);
      expect(cached!.location.name, 'Amsterdam');
      expect(cached.isFromCache, isTrue);
    });

    test(
      'returns cached weather with isFromCache=true when network fails',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = WeatherStorageService(prefs);

        // Pre-populate storage with valid cached data
        final initialData = WeatherData(
          location: testLocation,
          current: CurrentWeather(
            time: DateTime.now(),
            temperature: 10.0,
            relativeHumidity: 70,
            weatherCode: 0,
            windSpeed: 5.0,
            apparentTemperature: 8.5,
            surfacePressure: 1015.0,
          ),
          dailyForecast: [
            ForecastDay(
              date: DateTime.now(),
              weatherCode: 0,
              maxTemp: 12.0,
              minTemp: 6.0,
            ),
          ],
          fetchedAt: DateTime.now().subtract(const Duration(hours: 2)),
          isFromCache: true,
        );
        await storage.saveWeather(initialData);

        // Network client throws 500 error
        final mockClient = MockClient((request) async {
          return http.Response('Server Down', 500);
        });

        final apiClient = OpenMeteoApiClient(client: mockClient);
        final repo = WeatherRepository(
          apiClient: apiClient,
          storageService: storage,
        );

        final fallbackData = await repo.fetchWeather(location: testLocation);

        expect(fallbackData.location.name, 'Amsterdam');
        expect(fallbackData.isFromCache, isTrue);

        // Verify the storage was NOT corrupted or overwritten with empty data
        final cachedAfterError = storage.getLastSavedWeather();
        expect(cachedAfterError, isNotNull);
        expect(cachedAfterError!.location.name, 'Amsterdam');
      },
    );

    test(
      'rethrows WeatherException when network fails and no cache exists',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = WeatherStorageService(prefs);

        final mockClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final apiClient = OpenMeteoApiClient(client: mockClient);
        final repo = WeatherRepository(
          apiClient: apiClient,
          storageService: storage,
        );

        expect(
          () => repo.fetchWeather(location: testLocation),
          throwsA(isA<WeatherException>()),
        );
      },
    );
  });
}

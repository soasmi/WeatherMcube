import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_mcube/core/errors/app_exceptions.dart';
import 'package:weather_mcube/data/models/location_item.dart';
import 'package:weather_mcube/data/services/open_meteo_api_client.dart';

void main() {
  group('OpenMeteoApiClient', () {
    test(
      'searchCities returns empty list for blank query without HTTP call',
      () async {
        var called = false;
        final mockClient = MockClient((request) async {
          called = true;
          return http.Response('{}', 200);
        });

        final client = OpenMeteoApiClient(client: mockClient);
        final results = await client.searchCities('   ');

        expect(called, isFalse);
        expect(results, isEmpty);
      },
    );

    test('searchCities parses results successfully', () async {
      final mockJson = jsonEncode({
        'results': [
          {
            'id': 2950159,
            'name': 'Berlin',
            'latitude': 52.52,
            'longitude': 13.41,
            'country': 'Germany',
            'admin1': 'State of Berlin',
            'country_code': 'DE',
          },
        ],
      });

      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['name'], 'Berlin');
        expect(request.url.queryParameters['count'], '5');
        return http.Response(mockJson, 200);
      });

      final client = OpenMeteoApiClient(client: mockClient);
      final results = await client.searchCities('Berlin');

      expect(results.length, 1);
      expect(results.first.name, 'Berlin');
      expect(results.first.country, 'Germany');
    });

    test(
      'searchCities handles nonexistent city missing results field gracefully',
      () async {
        final mockJson = jsonEncode({'generationtime_ms': 0.1});

        final mockClient = MockClient((request) async {
          return http.Response(mockJson, 200);
        });

        final client = OpenMeteoApiClient(client: mockClient);
        final results = await client.searchCities('notrealcity12345');

        expect(results, isEmpty);
      },
    );

    test('searchCities throws WeatherException on 500 server error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final client = OpenMeteoApiClient(client: mockClient);

      expect(
        () => client.searchCities('Rome'),
        throwsA(isA<WeatherException>()),
      );
    });

    test(
      'fetchWeather parses forecast and daily parallel arrays correctly',
      () async {
        const location = LocationItem(
          id: 1,
          name: 'London',
          latitude: 51.5,
          longitude: -0.12,
          country: 'United Kingdom',
        );

        final forecastPayload = jsonEncode({
          'current': {
            'time': '2026-11-03T11:00',
            'temperature_2m': 12.5,
            'relative_humidity_2m': 75,
            'weather_code': 2,
            'wind_speed_10m': 14.0,
          },
          'daily': {
            'time': ['2026-11-03', '2026-11-04'],
            'weather_code': [2, 3],
            'temperature_2m_max': [14.0, 13.5],
            'temperature_2m_min': [8.0, 7.5],
          },
        });

        final mockClient = MockClient((request) async {
          return http.Response(forecastPayload, 200);
        });

        final client = OpenMeteoApiClient(client: mockClient);
        final weather = await client.fetchWeather(location);

        expect(weather.location.name, 'London');
        expect(weather.current.temperature, 12.5);
        expect(weather.current.weatherCode, 2);
        expect(weather.dailyForecast.length, 2);
        expect(weather.dailyForecast.first.maxTemp, 14.0);
      },
    );
  });
}

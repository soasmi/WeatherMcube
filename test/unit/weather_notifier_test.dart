import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_mcube/data/models/current_weather.dart';
import 'package:weather_mcube/data/models/forecast_day.dart';
import 'package:weather_mcube/data/models/location_item.dart';
import 'package:weather_mcube/data/models/weather_data.dart';
import 'package:weather_mcube/data/repositories/weather_repository.dart';
import 'package:weather_mcube/data/services/open_meteo_api_client.dart';
import 'package:weather_mcube/data/services/weather_storage_service.dart';
import 'package:weather_mcube/features/weather/providers/weather_provider.dart';
import 'package:weather_mcube/features/weather/providers/weather_state.dart';

class FakeWeatherRepository extends WeatherRepository {
  final Map<String, List<LocationItem>> searchMap;
  final Duration searchDelay;

  FakeWeatherRepository({
    required super.apiClient,
    required super.storageService,
    required this.searchMap,
    this.searchDelay = Duration.zero,
  });

  @override
  Future<List<LocationItem>> searchLocations(String query) async {
    if (searchDelay > Duration.zero) {
      await Future.delayed(searchDelay);
    }
    return searchMap[query] ?? [];
  }

  @override
  Future<WeatherData> fetchWeather({
    required LocationItem location,
    bool forceRefresh = false,
  }) async {
    return WeatherData(
      location: location,
      current: CurrentWeather(
        time: DateTime.now(),
        temperature: 22.0,
        relativeHumidity: 55,
        weatherCode: 0,
        windSpeed: 10.0,
        apparentTemperature: 21.0,
        surfacePressure: 1014.0,
      ),
      dailyForecast: [
        ForecastDay(
          date: DateTime.now(),
          weatherCode: 0,
          maxTemp: 24.0,
          minTemp: 16.0,
        ),
      ],
      fetchedAt: DateTime.now(),
      isFromCache: false,
    );
  }
}

void main() {
  group('WeatherNotifier State & Concurrency Tests', () {
    test('initializes with WeatherInitialState when cache is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final state = container.read(weatherNotifierProvider);
      expect(state, isA<WeatherInitialState>());
    });

    test(
      'sets WeatherLocationsDisambiguationState when multiple cities match',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = WeatherStorageService(prefs);

        const berlin1 = LocationItem(
          id: 1,
          name: 'Berlin',
          latitude: 52.52,
          longitude: 13.41,
          country: 'Germany',
        );
        const berlin2 = LocationItem(
          id: 2,
          name: 'Berlin',
          latitude: 44.46,
          longitude: -71.18,
          country: 'United States',
        );

        final fakeRepo = FakeWeatherRepository(
          apiClient: OpenMeteoApiClient(),
          storageService: storage,
          searchMap: {
            'Berlin': [berlin1, berlin2],
          },
        );

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            weatherRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );

        final notifier = container.read(weatherNotifierProvider.notifier);
        await notifier.searchCity('Berlin');

        final finalState = container.read(weatherNotifierProvider);
        expect(finalState, isA<WeatherLocationsDisambiguationState>());
        final disambiguation =
            finalState as WeatherLocationsDisambiguationState;
        expect(disambiguation.locations.length, 2);
      },
    );

    test('overlapping searches: newer search result is preserved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = WeatherStorageService(prefs);

      const slowCity = LocationItem(
        id: 10,
        name: 'SlowCity',
        latitude: 10.0,
        longitude: 10.0,
        country: 'Slowland',
      );
      const fastCity = LocationItem(
        id: 20,
        name: 'FastCity',
        latitude: 20.0,
        longitude: 20.0,
        country: 'Fastland',
      );

      final fakeRepo = _DelayedFakeRepo(
        apiClient: OpenMeteoApiClient(),
        storageService: storage,
        slowLocation: slowCity,
        fastLocation: fastCity,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          weatherRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final notifier = container.read(weatherNotifierProvider.notifier);

      // Trigger slow search first
      final future1 = notifier.searchCity('SlowCity');
      // Trigger fast search immediately after
      final future2 = notifier.searchCity('FastCity');

      await Future.wait([future1, future2]);

      final finalState = container.read(weatherNotifierProvider);
      expect(finalState, isA<WeatherSuccessState>());
      final success = finalState as WeatherSuccessState;
      // FastCity was the NEWER search, so its result MUST be preserved!
      expect(success.weatherData.location.name, 'FastCity');
    });
  });
}

class _DelayedFakeRepo extends FakeWeatherRepository {
  final LocationItem slowLocation;
  final LocationItem fastLocation;

  _DelayedFakeRepo({
    required super.apiClient,
    required super.storageService,
    required this.slowLocation,
    required this.fastLocation,
  }) : super(searchMap: {});

  @override
  Future<List<LocationItem>> searchLocations(String query) async {
    if (query == 'SlowCity') {
      await Future.delayed(const Duration(milliseconds: 150));
      return [slowLocation];
    } else {
      await Future.delayed(const Duration(milliseconds: 20));
      return [fastLocation];
    }
  }
}

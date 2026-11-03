import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_mcube/data/repositories/weather_repository.dart';
import 'package:weather_mcube/data/services/open_meteo_api_client.dart';
import 'package:weather_mcube/data/services/weather_storage_service.dart';

void main() {
  group('Live Open-Meteo End-to-End Integration', () {
    test('searches real city and fetches live forecast data', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = WeatherStorageService(prefs);
      final client = OpenMeteoApiClient(timeout: const Duration(seconds: 25));
      final repo = WeatherRepository(
        apiClient: client,
        storageService: storage,
      );

      // 1. Live geocoding search for 'Berlin'
      final searchResults = await repo.searchLocations('Berlin');
      expect(searchResults, isNotEmpty);
      final selectedCity = searchResults.first;
      expect(selectedCity.name, contains('Berlin'));
      expect(selectedCity.latitude, isNotNull);
      expect(selectedCity.longitude, isNotNull);

      // 2. Live forecast fetch
      final weather = await repo.fetchWeather(location: selectedCity);
      expect(weather.location.name, contains('Berlin'));
      expect(weather.current.temperature, isNotNull);
      expect(weather.current.relativeHumidity, greaterThanOrEqualTo(0));
      expect(weather.current.windSpeed, greaterThanOrEqualTo(0));
      expect(weather.dailyForecast.length, equals(5));
      expect(weather.isFromCache, isFalse);

      // 3. Verify local cache was populated
      final cached = repo.getCachedWeather();
      expect(cached, isNotNull);
      expect(cached!.location.name, contains('Berlin'));

      client.close();
    });

    test('handles live nonexistent city query with empty results', () async {
      final client = OpenMeteoApiClient(timeout: const Duration(seconds: 25));
      final results = await client.searchCities('xyzqwertynonexistentcity987');
      expect(results, isEmpty);
      client.close();
    });
  });
}

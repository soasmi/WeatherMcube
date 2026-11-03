import '../../core/errors/app_exceptions.dart';
import '../models/location_item.dart';
import '../models/weather_data.dart';
import '../services/open_meteo_api_client.dart';
import '../services/weather_storage_service.dart';

class WeatherRepository {
  final OpenMeteoApiClient _apiClient;
  final WeatherStorageService _storageService;

  WeatherRepository({
    required OpenMeteoApiClient apiClient,
    required WeatherStorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService;

  Future<List<LocationItem>> searchLocations(String query) async {
    return await _apiClient.searchCities(query);
  }

  Future<WeatherData> fetchWeather({
    required LocationItem location,
    bool forceRefresh = false,
  }) async {
    try {
      final fresh = await _apiClient.fetchWeather(location);
      await _storageService.saveWeather(fresh);
      await _storageService.addRecentLocation(location);
      return fresh;
    } catch (e) {
      final cached = _storageService.getLastSavedWeather();
      // If we have cached data and network failed, provide cached data with indicator
      if (cached != null) {
        return cached.copyWith(isFromCache: true);
      }

      if (e is WeatherException) {
        rethrow;
      }
      throw WeatherException('Unable to load weather: $e');
    }
  }

  WeatherData? getCachedWeather() {
    return _storageService.getLastSavedWeather();
  }

  List<LocationItem> getRecentLocations() {
    return _storageService.getRecentLocations();
  }
}

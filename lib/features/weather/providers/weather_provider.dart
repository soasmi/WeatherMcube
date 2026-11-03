import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../data/models/location_item.dart';
import '../../../data/models/weather_data.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../../data/services/open_meteo_api_client.dart';
import '../../../data/services/weather_storage_service.dart';
import 'settings_provider.dart';
import 'weather_state.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final openMeteoApiClientProvider = Provider<OpenMeteoApiClient>((ref) {
  final client = OpenMeteoApiClient();
  ref.onDispose(client.close);
  return client;
});

final weatherStorageServiceProvider = Provider<WeatherStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WeatherStorageService(prefs);
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final apiClient = ref.watch(openMeteoApiClientProvider);
  final storageService = ref.watch(weatherStorageServiceProvider);
  return WeatherRepository(
    apiClient: apiClient,
    storageService: storageService,
  );
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final storage = ref.watch(weatherStorageServiceProvider);
  return SettingsNotifier(storage);
});

final recentSearchesProvider = Provider<List<LocationItem>>((ref) {
  ref.watch(weatherNotifierProvider);
  final repo = ref.watch(weatherRepositoryProvider);
  return repo.getRecentLocations();
});

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final repo = ref.watch(weatherRepositoryProvider);
  return WeatherNotifier(repo);
});

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository _repository;
  int _currentRequestId = 0;

  WeatherNotifier(this._repository) : super(const WeatherInitialState()) {
    _restoreCachedWeather();
  }

  WeatherData? get _currentData {
    return switch (state) {
      WeatherSuccessState(:final weatherData) => weatherData,
      WeatherLoadingDataState(:final previousData) => previousData,
      WeatherLocationsDisambiguationState(:final previousData) => previousData,
      WeatherErrorState(:final cachedData) => cachedData,
      _ => null,
    };
  }

  void _restoreCachedWeather() {
    final cached = _repository.getCachedWeather();
    if (cached != null) {
      state = WeatherSuccessState(cached.copyWith(isFromCache: true));
    } else {
      state = const WeatherInitialState();
    }
  }

  Future<void> searchCity(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final requestId = ++_currentRequestId;
    final previousData = _currentData;
    state = WeatherSearchingLocationsState(trimmed);

    try {
      final results = await _repository.searchLocations(trimmed);
      if (requestId != _currentRequestId) return;

      if (results.isEmpty) {
        state = WeatherErrorState(
          message:
              'No locations found matching "$trimmed". Please verify the spelling.',
          isNotFound: true,
          cachedData: previousData,
        );
        return;
      }

      if (results.length == 1) {
        await selectLocation(results.first);
      } else {
        state = WeatherLocationsDisambiguationState(
          query: trimmed,
          locations: results,
          previousData: previousData,
        );
      }
    } on WeatherException catch (e) {
      if (requestId != _currentRequestId) return;
      state = WeatherErrorState(
        message: e.message,
        isNetworkError: e.isNetworkError,
        isNotFound: e.isNotFound,
        cachedData: previousData,
      );
    } catch (e) {
      if (requestId != _currentRequestId) return;
      state = WeatherErrorState(
        message: 'An unexpected error occurred. Please try again.',
        cachedData: previousData,
      );
    }
  }

  Future<void> selectLocation(LocationItem location) async {
    final requestId = ++_currentRequestId;
    final previousData = _currentData;
    state = WeatherLoadingDataState(
      location: location,
      previousData: previousData,
    );

    try {
      final weather = await _repository.fetchWeather(location: location);
      if (requestId != _currentRequestId) return;

      state = WeatherSuccessState(weather);
    } on WeatherException catch (e) {
      if (requestId != _currentRequestId) return;
      state = WeatherErrorState(
        message: e.message,
        isNetworkError: e.isNetworkError,
        isNotFound: e.isNotFound,
        cachedData: previousData,
      );
    } catch (e) {
      if (requestId != _currentRequestId) return;
      state = WeatherErrorState(
        message: 'Could not retrieve forecast for ${location.name}.',
        cachedData: previousData,
      );
    }
  }

  Future<void> refresh() async {
    final current = _currentData;
    if (current == null) return;
    await selectLocation(current.location);
  }

  void cancelDisambiguation() {
    final previous = _currentData;
    if (previous != null) {
      state = WeatherSuccessState(previous);
    } else {
      state = const WeatherInitialState();
    }
  }

  void resetToInitial() {
    state = const WeatherInitialState();
  }
}

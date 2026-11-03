import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../data/models/location_item.dart';
import '../../../data/models/weather_data.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../../data/services/open_meteo_api_client.dart';
import '../../../data/services/weather_storage_service.dart';
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

final recentSearchesProvider = Provider<List<LocationItem>>((ref) {
  ref.watch(weatherNotifierProvider);
  final repo = ref.watch(weatherRepositoryProvider);
  return repo.getRecentLocations();
});

class WeatherNotifier extends Notifier<WeatherState> {
  int _currentRequestId = 0;

  @override
  WeatherState build() {
    final repo = ref.watch(weatherRepositoryProvider);
    final cached = repo.getCachedWeather();
    if (cached != null) {
      return WeatherSuccessState(cached.copyWith(isFromCache: true));
    }
    return const WeatherInitialState();
  }

  WeatherData? get _currentData {
    final currentState = state;
    if (currentState is WeatherSuccessState) {
      return currentState.weatherData;
    } else if (currentState is WeatherLoadingDataState) {
      return currentState.previousData;
    } else if (currentState is WeatherLocationsDisambiguationState) {
      return currentState.previousData;
    } else if (currentState is WeatherErrorState) {
      return currentState.cachedData;
    }
    return null;
  }

  Future<void> searchCity(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final repo = ref.read(weatherRepositoryProvider);
    final requestId = ++_currentRequestId;
    final previousData = _currentData;
    state = WeatherSearchingLocationsState(trimmed);

    try {
      final results = await repo.searchLocations(trimmed);
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
    final repo = ref.read(weatherRepositoryProvider);
    final requestId = ++_currentRequestId;
    final previousData = _currentData;
    state = WeatherLoadingDataState(
      location: location,
      previousData: previousData,
    );

    try {
      final weather = await repo.fetchWeather(location: location);
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

final weatherNotifierProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);

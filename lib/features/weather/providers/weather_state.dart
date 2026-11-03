import '../../../data/models/location_item.dart';
import '../../../data/models/weather_data.dart';

sealed class WeatherState {
  const WeatherState();
}

class WeatherInitialState extends WeatherState {
  const WeatherInitialState();
}

class WeatherSearchingLocationsState extends WeatherState {
  final String query;
  const WeatherSearchingLocationsState(this.query);
}

class WeatherLocationsDisambiguationState extends WeatherState {
  final String query;
  final List<LocationItem> locations;
  final WeatherData? previousData;

  const WeatherLocationsDisambiguationState({
    required this.query,
    required this.locations,
    this.previousData,
  });
}

class WeatherLoadingDataState extends WeatherState {
  final LocationItem location;
  final WeatherData? previousData;

  const WeatherLoadingDataState({
    required this.location,
    this.previousData,
  });
}

class WeatherSuccessState extends WeatherState {
  final WeatherData weatherData;

  const WeatherSuccessState(this.weatherData);
}

class WeatherErrorState extends WeatherState {
  final String message;
  final bool isNetworkError;
  final bool isNotFound;
  final WeatherData? cachedData;

  const WeatherErrorState({
    required this.message,
    this.isNetworkError = false,
    this.isNotFound = false,
    this.cachedData,
  });
}

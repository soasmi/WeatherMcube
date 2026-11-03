class WeatherException implements Exception {
  final String message;
  final bool isNetworkError;
  final bool isNotFound;

  const WeatherException(
    this.message, {
    this.isNetworkError = false,
    this.isNotFound = false,
  });

  factory WeatherException.noInternet() => const WeatherException(
        'No internet connection. Please check your network settings.',
        isNetworkError: true,
      );

  factory WeatherException.timeout() => const WeatherException(
        'The request timed out. Please try again in a moment.',
        isNetworkError: true,
      );

  factory WeatherException.cityNotFound(String query) => WeatherException(
        'No locations found matching "$query". Please verify the spelling.',
        isNotFound: true,
      );

  factory WeatherException.serverError(int statusCode) => WeatherException(
        'Weather service returned status code $statusCode. Please try again.',
      );

  factory WeatherException.malformedData() => const WeatherException(
        'Unable to parse weather data. The service format may have changed.',
      );

  @override
  String toString() => message;
}

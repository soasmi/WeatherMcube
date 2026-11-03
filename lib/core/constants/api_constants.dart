class ApiConstants {
  ApiConstants._();

  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  static const int geocodingCount = 5;
  static const int forecastDays = 5;
  static const Duration requestTimeout = Duration(seconds: 15);

  static const String currentParameters =
      'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,surface_pressure';
  static const String hourlyParameters =
      'temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,uv_index';
  static const String dailyParameters =
      'weather_code,temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_sum';
  static const String defaultTimezone = 'auto';
}

import 'current_weather.dart';
import 'forecast_day.dart';
import 'location_item.dart';

class WeatherData {
  final LocationItem location;
  final CurrentWeather current;
  final List<ForecastDay> dailyForecast;
  final DateTime fetchedAt;
  final bool isFromCache;

  const WeatherData({
    required this.location,
    required this.current,
    required this.dailyForecast,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  WeatherData copyWith({
    LocationItem? location,
    CurrentWeather? current,
    List<ForecastDay>? dailyForecast,
    DateTime? fetchedAt,
    bool? isFromCache,
  }) {
    return WeatherData(
      location: location ?? this.location,
      current: current ?? this.current,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  factory WeatherData.fromApiResponse({
    required LocationItem location,
    required Map<String, dynamic> forecastJson,
    bool isFromCache = false,
  }) {
    final currentJson = forecastJson['current'] as Map<String, dynamic>? ?? {};
    final current = CurrentWeather.fromJson(currentJson);

    final dailyJson = forecastJson['daily'] as Map<String, dynamic>? ?? {};
    final timeList = (dailyJson['time'] as List?)?.cast<String>() ?? [];
    final codeList = dailyJson['weather_code'] as List? ?? [];
    final maxList = dailyJson['temperature_2m_max'] as List? ?? [];
    final minList = dailyJson['temperature_2m_min'] as List? ?? [];

    final forecastDays = <ForecastDay>[];
    final count = timeList.length;

    for (var i = 0; i < count; i++) {
      forecastDays.add(
        ForecastDay.fromParallelArrays(
          dateString: timeList[i],
          rawCode: i < codeList.length ? codeList[i] as num? : null,
          rawMax: i < maxList.length ? maxList[i] as num? : null,
          rawMin: i < minList.length ? minList[i] as num? : null,
        ),
      );
    }

    return WeatherData(
      location: location,
      current: current,
      dailyForecast: forecastDays,
      fetchedAt: DateTime.now(),
      isFromCache: isFromCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location.toJson(),
        'current': current.toJson(),
        'daily_forecast': dailyForecast.map((d) => d.toJson()).toList(),
        'fetched_at': fetchedAt.toIso8601String(),
        'is_from_cache': isFromCache,
      };

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final forecastList = (json['daily_forecast'] as List?) ?? [];
    return WeatherData(
      location: LocationItem.fromJson(
        Map<String, dynamic>.from(json['location'] as Map? ?? {}),
      ),
      current: CurrentWeather.fromJson(
        Map<String, dynamic>.from(json['current'] as Map? ?? {}),
      ),
      dailyForecast: forecastList
          .map((item) =>
              ForecastDay.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      fetchedAt: json['fetched_at'] != null
          ? DateTime.tryParse(json['fetched_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isFromCache: json['is_from_cache'] as bool? ?? true,
    );
  }
}

import 'current_weather.dart';
import 'forecast_day.dart';
import 'hourly_forecast_item.dart';
import 'location_item.dart';

class WeatherData {
  final LocationItem location;
  final CurrentWeather current;
  final List<ForecastDay> dailyForecast;
  final List<HourlyForecastItem> hourlyForecast;
  final DateTime fetchedAt;
  final bool isFromCache;

  const WeatherData({
    required this.location,
    required this.current,
    required this.dailyForecast,
    this.hourlyForecast = const [],
    required this.fetchedAt,
    this.isFromCache = false,
  });

  WeatherData copyWith({
    LocationItem? location,
    CurrentWeather? current,
    List<ForecastDay>? dailyForecast,
    List<HourlyForecastItem>? hourlyForecast,
    DateTime? fetchedAt,
    bool? isFromCache,
  }) {
    return WeatherData(
      location: location ?? this.location,
      current: current ?? this.current,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
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
    final uvMaxList = dailyJson['uv_index_max'] as List? ?? [];
    final precipSumList = dailyJson['precipitation_sum'] as List? ?? [];

    final forecastDays = <ForecastDay>[];
    final count = timeList.length;

    for (var i = 0; i < count; i++) {
      forecastDays.add(
        ForecastDay.fromParallelArrays(
          dateString: timeList[i],
          rawCode: i < codeList.length ? codeList[i] as num? : null,
          rawMax: i < maxList.length ? maxList[i] as num? : null,
          rawMin: i < minList.length ? minList[i] as num? : null,
          rawUvMax: i < uvMaxList.length ? uvMaxList[i] as num? : null,
          rawPrecipSum:
              i < precipSumList.length ? precipSumList[i] as num? : null,
        ),
      );
    }

    // Parse hourly forecast (next 24 hours)
    final hourlyJson = forecastJson['hourly'] as Map<String, dynamic>? ?? {};
    final hourlyTimes = (hourlyJson['time'] as List?)?.cast<String>() ?? [];
    final hourlyTemps = hourlyJson['temperature_2m'] as List? ?? [];
    final hourlyHumidities = hourlyJson['relative_humidity_2m'] as List? ?? [];
    final hourlyPrecipProbs =
        hourlyJson['precipitation_probability'] as List? ?? [];
    final hourlyCodes = hourlyJson['weather_code'] as List? ?? [];
    final hourlyUvs = hourlyJson['uv_index'] as List? ?? [];

    final hourlyItems = <HourlyForecastItem>[];
    final now = DateTime.now();

    // Find index of current hour
    var startIndex = 0;
    for (var i = 0; i < hourlyTimes.length; i++) {
      final parsed = DateTime.tryParse(hourlyTimes[i]);
      if (parsed != null &&
          parsed.isAfter(now.subtract(const Duration(minutes: 59)))) {
        startIndex = i;
        break;
      }
    }

    final endIndex = (startIndex + 24).clamp(0, hourlyTimes.length);
    for (var i = startIndex; i < endIndex; i++) {
      hourlyItems.add(
        HourlyForecastItem.fromParallelArrays(
          timeString: hourlyTimes[i],
          rawTemp: i < hourlyTemps.length ? hourlyTemps[i] as num? : null,
          rawHumidity:
              i < hourlyHumidities.length ? hourlyHumidities[i] as num? : null,
          rawPrecipProb:
              i < hourlyPrecipProbs.length
                  ? hourlyPrecipProbs[i] as num?
                  : null,
          rawCode: i < hourlyCodes.length ? hourlyCodes[i] as num? : null,
          rawUv: i < hourlyUvs.length ? hourlyUvs[i] as num? : null,
        ),
      );
    }

    return WeatherData(
      location: location,
      current: current,
      dailyForecast: forecastDays,
      hourlyForecast: hourlyItems,
      fetchedAt: DateTime.now(),
      isFromCache: isFromCache,
    );
  }

  Map<String, dynamic> toJson() => {
    'location': location.toJson(),
    'current': current.toJson(),
    'daily_forecast': dailyForecast.map((d) => d.toJson()).toList(),
    'hourly_forecast': hourlyForecast.map((h) => h.toJson()).toList(),
    'fetched_at': fetchedAt.toIso8601String(),
    'is_from_cache': isFromCache,
  };

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final forecastList = (json['daily_forecast'] as List?) ?? [];
    final hourlyList = (json['hourly_forecast'] as List?) ?? [];

    return WeatherData(
      location: LocationItem.fromJson(
        Map<String, dynamic>.from(json['location'] as Map? ?? {}),
      ),
      current: CurrentWeather.fromJson(
        Map<String, dynamic>.from(json['current'] as Map? ?? {}),
      ),
      dailyForecast:
          forecastList
              .map(
                (item) => ForecastDay.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
      hourlyForecast:
          hourlyList
              .map(
                (item) => HourlyForecastItem.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
      fetchedAt:
          json['fetched_at'] != null
              ? DateTime.tryParse(json['fetched_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      isFromCache: json['is_from_cache'] as bool? ?? true,
    );
  }
}

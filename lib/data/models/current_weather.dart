class CurrentWeather {
  final DateTime time;
  final double temperature;
  final int relativeHumidity;
  final int weatherCode;
  final double windSpeed;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time:
          json['time'] != null
              ? DateTime.tryParse(json['time'].toString()) ?? DateTime.now()
              : DateTime.now(),
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? -1,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'temperature_2m': temperature,
    'relative_humidity_2m': relativeHumidity,
    'weather_code': weatherCode,
    'wind_speed_10m': windSpeed,
  };
}

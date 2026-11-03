class CurrentWeather {
  final DateTime time;
  final double temperature;
  final int relativeHumidity;
  final int weatherCode;
  final double windSpeed;
  final double apparentTemperature;
  final double surfacePressure;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.apparentTemperature,
    required this.surfacePressure,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final temp = (json['temperature_2m'] as num?)?.toDouble() ?? 0.0;
    return CurrentWeather(
      time:
          json['time'] != null
              ? DateTime.tryParse(json['time'].toString()) ?? DateTime.now()
              : DateTime.now(),
      temperature: temp,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? -1,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? temp,
      surfacePressure:
          (json['surface_pressure'] as num?)?.toDouble() ?? 1013.25,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'temperature_2m': temperature,
    'relative_humidity_2m': relativeHumidity,
    'weather_code': weatherCode,
    'wind_speed_10m': windSpeed,
    'apparent_temperature': apparentTemperature,
    'surface_pressure': surfacePressure,
  };
}

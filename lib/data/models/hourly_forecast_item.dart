class HourlyForecastItem {
  final DateTime time;
  final double temperature;
  final int humidity;
  final int precipitationProbability;
  final int weatherCode;
  final double uvIndex;

  const HourlyForecastItem({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.uvIndex,
  });

  String get uvRiskLevel {
    if (uvIndex < 3.0) return 'LOW';
    if (uvIndex < 6.0) return 'MODERATE';
    if (uvIndex < 8.0) return 'HIGH';
    if (uvIndex < 11.0) return 'VERY HIGH';
    return 'EXTREME';
  }

  factory HourlyForecastItem.fromParallelArrays({
    required String timeString,
    required num? rawTemp,
    required num? rawHumidity,
    required num? rawPrecipProb,
    required num? rawCode,
    required num? rawUv,
  }) {
    return HourlyForecastItem(
      time: DateTime.tryParse(timeString) ?? DateTime.now(),
      temperature: rawTemp?.toDouble() ?? 0.0,
      humidity: rawHumidity?.toInt() ?? 0,
      precipitationProbability: rawPrecipProb?.toInt() ?? 0,
      weatherCode: rawCode?.toInt() ?? -1,
      uvIndex: rawUv?.toDouble() ?? 0.0,
    );
  }

  factory HourlyForecastItem.fromJson(Map<String, dynamic> json) {
    return HourlyForecastItem(
      time:
          json['time'] != null
              ? DateTime.tryParse(json['time'].toString()) ?? DateTime.now()
              : DateTime.now(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      precipitationProbability:
          (json['precipitation_probability'] as num?)?.toInt() ?? 0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? -1,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'temperature': temperature,
    'humidity': humidity,
    'precipitation_probability': precipitationProbability,
    'weather_code': weatherCode,
    'uv_index': uvIndex,
  };
}

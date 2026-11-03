class ForecastDay {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final double uvIndexMax;
  final double precipitationSum;

  const ForecastDay({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    this.uvIndexMax = 0.0,
    this.precipitationSum = 0.0,
  });

  factory ForecastDay.fromParallelArrays({
    required String dateString,
    required num? rawCode,
    required num? rawMax,
    required num? rawMin,
    num? rawUvMax,
    num? rawPrecipSum,
  }) {
    return ForecastDay(
      date: DateTime.tryParse(dateString) ?? DateTime.now(),
      weatherCode: rawCode?.toInt() ?? -1,
      maxTemp: rawMax?.toDouble() ?? 0.0,
      minTemp: rawMin?.toDouble() ?? 0.0,
      uvIndexMax: rawUvMax?.toDouble() ?? 0.0,
      precipitationSum: rawPrecipSum?.toDouble() ?? 0.0,
    );
  }

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date:
          json['date'] != null
              ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
              : DateTime.now(),
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? -1,
      maxTemp: (json['max_temp'] as num?)?.toDouble() ?? 0.0,
      minTemp: (json['min_temp'] as num?)?.toDouble() ?? 0.0,
      uvIndexMax: (json['uv_index_max'] as num?)?.toDouble() ?? 0.0,
      precipitationSum: (json['precipitation_sum'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weather_code': weatherCode,
    'max_temp': maxTemp,
    'min_temp': minTemp,
    'uv_index_max': uvIndexMax,
    'precipitation_sum': precipitationSum,
  };
}

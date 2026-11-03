class ForecastDay {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;

  const ForecastDay({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
  });

  factory ForecastDay.fromParallelArrays({
    required String dateString,
    required num? rawCode,
    required num? rawMax,
    required num? rawMin,
  }) {
    return ForecastDay(
      date: DateTime.tryParse(dateString) ?? DateTime.now(),
      weatherCode: rawCode?.toInt() ?? -1,
      maxTemp: rawMax?.toDouble() ?? 0.0,
      minTemp: rawMin?.toDouble() ?? 0.0,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weather_code': weatherCode,
    'max_temp': maxTemp,
    'min_temp': minTemp,
  };
}

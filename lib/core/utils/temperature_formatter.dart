enum TemperatureUnit {
  celsius('°C'),
  fahrenheit('°F');

  final String symbol;
  const TemperatureUnit(this.symbol);
}

class WeatherUnits {
  WeatherUnits._();

  static double toTargetTemperature(double celsius, TemperatureUnit unit) {
    return switch (unit) {
      TemperatureUnit.celsius => celsius,
      TemperatureUnit.fahrenheit => (celsius * 9 / 5) + 32,
    };
  }

  static String formatTemperature(double celsius, TemperatureUnit unit) {
    final value = toTargetTemperature(celsius, unit);
    return '${value.round()}${unit.symbol}';
  }

  static String formatWindSpeed(double kmh, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      final mph = kmh * 0.621371;
      return '${mph.toStringAsFixed(1)} mph';
    }
    return '${kmh.toStringAsFixed(1)} km/h';
  }
}

import 'package:flutter/material.dart';

class WeatherCondition {
  final String description;
  final IconData icon;
  final String codeGroup;

  const WeatherCondition({
    required this.description,
    required this.icon,
    required this.codeGroup,
  });
}

class WmoCodeMapper {
  WmoCodeMapper._();

  static const WeatherCondition _fallbackCondition = WeatherCondition(
    description: 'Unknown',
    icon: Icons.cloud_outlined,
    codeGroup: 'unknown',
  );

  static WeatherCondition map(int? code) {
    if (code == null) return _fallbackCondition;

    return switch (code) {
      0 => const WeatherCondition(
        description: 'Clear Sky',
        icon: Icons.wb_sunny_rounded,
        codeGroup: 'clear',
      ),
      1 => const WeatherCondition(
        description: 'Mainly Clear',
        icon: Icons.wb_sunny_outlined,
        codeGroup: 'partly_cloudy',
      ),
      2 => const WeatherCondition(
        description: 'Partly Cloudy',
        icon: Icons.cloud_queue_rounded,
        codeGroup: 'partly_cloudy',
      ),
      3 => const WeatherCondition(
        description: 'Overcast',
        icon: Icons.cloud_rounded,
        codeGroup: 'cloudy',
      ),
      45 => const WeatherCondition(
        description: 'Foggy',
        icon: Icons.foggy,
        codeGroup: 'fog',
      ),
      48 => const WeatherCondition(
        description: 'Depositing Rime Fog',
        icon: Icons.foggy,
        codeGroup: 'fog',
      ),
      51 => const WeatherCondition(
        description: 'Light Drizzle',
        icon: Icons.water_drop_outlined,
        codeGroup: 'drizzle',
      ),
      53 => const WeatherCondition(
        description: 'Moderate Drizzle',
        icon: Icons.water_drop_outlined,
        codeGroup: 'drizzle',
      ),
      55 => const WeatherCondition(
        description: 'Dense Drizzle',
        icon: Icons.water_drop_rounded,
        codeGroup: 'drizzle',
      ),
      56 || 57 => const WeatherCondition(
        description: 'Freezing Drizzle',
        icon: Icons.severe_cold_rounded,
        codeGroup: 'freezing_rain',
      ),
      61 => const WeatherCondition(
        description: 'Slight Rain',
        icon: Icons.water_drop_outlined,
        codeGroup: 'rain',
      ),
      63 => const WeatherCondition(
        description: 'Moderate Rain',
        icon: Icons.water_drop_rounded,
        codeGroup: 'rain',
      ),
      65 => const WeatherCondition(
        description: 'Heavy Rain',
        icon: Icons.grain_rounded,
        codeGroup: 'heavy_rain',
      ),
      66 || 67 => const WeatherCondition(
        description: 'Freezing Rain',
        icon: Icons.severe_cold_rounded,
        codeGroup: 'freezing_rain',
      ),
      71 => const WeatherCondition(
        description: 'Slight Snow Fall',
        icon: Icons.ac_unit_rounded,
        codeGroup: 'snow',
      ),
      73 => const WeatherCondition(
        description: 'Moderate Snow Fall',
        icon: Icons.ac_unit_rounded,
        codeGroup: 'snow',
      ),
      75 => const WeatherCondition(
        description: 'Heavy Snow Fall',
        icon: Icons.ac_unit_rounded,
        codeGroup: 'heavy_snow',
      ),
      77 => const WeatherCondition(
        description: 'Snow Grains',
        icon: Icons.ac_unit_outlined,
        codeGroup: 'snow',
      ),
      80 => const WeatherCondition(
        description: 'Slight Rain Showers',
        icon: Icons.shower_rounded,
        codeGroup: 'rain_showers',
      ),
      81 => const WeatherCondition(
        description: 'Moderate Rain Showers',
        icon: Icons.shower_rounded,
        codeGroup: 'rain_showers',
      ),
      82 => const WeatherCondition(
        description: 'Violent Rain Showers',
        icon: Icons.shower_rounded,
        codeGroup: 'rain_showers',
      ),
      85 || 86 => const WeatherCondition(
        description: 'Snow Showers',
        icon: Icons.snowing,
        codeGroup: 'snow',
      ),
      95 => const WeatherCondition(
        description: 'Thunderstorm',
        icon: Icons.thunderstorm_rounded,
        codeGroup: 'thunderstorm',
      ),
      96 => const WeatherCondition(
        description: 'Thunderstorm With Slight Hail',
        icon: Icons.thunderstorm_rounded,
        codeGroup: 'thunderstorm',
      ),
      99 => const WeatherCondition(
        description: 'Thunderstorm With Heavy Hail',
        icon: Icons.thunderstorm_rounded,
        codeGroup: 'thunderstorm',
      ),
      _ => _fallbackCondition,
    };
  }
}

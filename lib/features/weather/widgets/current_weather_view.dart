import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/temperature_formatter.dart';
import '../../../core/utils/wmo_code_mapper.dart';
import '../../../data/models/weather_data.dart';

class CurrentWeatherView extends StatelessWidget {
  final WeatherData data;
  final TemperatureUnit unit;

  const CurrentWeatherView({super.key, required this.data, required this.unit});

  String _getHumidityStatus(int humidity) {
    if (humidity < 35) return 'LOW / DRY';
    if (humidity <= 65) return 'COMFORTABLE';
    if (humidity <= 80) return 'HUMID';
    return 'VERY HUMID';
  }

  String _getWindStatus(double kmh) {
    if (kmh < 12) return 'LIGHT BREEZE';
    if (kmh < 29) return 'MODERATE BREEZE';
    if (kmh < 50) return 'STRONG BREEZE';
    return 'GALE FORCE';
  }

  String _getPressureStatus(double hpa) {
    if (hpa < 1000) return 'LOW PRESSURE';
    if (hpa <= 1020) return 'NORMAL BARO';
    return 'HIGH PRESSURE';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final condition = WmoCodeMapper.map(data.current.weatherCode);
    final tempStr = WeatherUnits.formatTemperature(
      data.current.temperature,
      unit,
    );
    final feelsLikeStr = WeatherUnits.formatTemperature(
      data.current.apparentTemperature,
      unit,
    );
    final windStr = WeatherUnits.formatWindSpeed(data.current.windSpeed, unit);
    final humidityStr = '${data.current.relativeHumidity}%';
    final pressureStr =
        '${data.current.surfacePressure.toStringAsFixed(0)} hPa';
    final formattedTime = DateFormat(
      'EEEE, MMM d • HH:mm',
    ).format(data.current.time);

    // Today's min/max from first day of forecast if present
    final todayForecast =
        data.dailyForecast.isNotEmpty ? data.dailyForecast.first : null;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Location name, Country badge, and coordinates
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            data.location.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color:
                                  isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (data.location.country.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              data.location.countryCode ??
                                  data.location.country,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color:
                                    isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.location.subtitle.isNotEmpty
                          ? data.location.subtitle
                          : formattedTime,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'COORD',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color:
                          isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                    ),
                  ),
                  Text(
                    '${data.location.latitude.toStringAsFixed(2)}°N',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color:
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    '${data.location.longitude.toStringAsFixed(2)}°E',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color:
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Hero: Big temperature and Weather Condition
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tempStr,
                style: TextStyle(
                  fontSize: 68,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -3.0,
                  height: 0.9,
                  color:
                      isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(condition.icon, size: 26, color: accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            condition.description.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color:
                                  isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (todayForecast != null)
                      Text(
                        'Range: ${WeatherUnits.formatTemperature(todayForecast.minTemp, unit)} / ${WeatherUnits.formatTemperature(todayForecast.maxTemp, unit)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 16),

          // Row 1 Metrics: Humidity and Wind Speed
          Row(
            children: [
              // Humidity Metric
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 15,
                            color:
                                isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'HUMIDITY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color:
                                  isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        humidityStr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getHumidityStatus(data.current.relativeHumidity),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Wind Speed Metric
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.air_rounded,
                            size: 15,
                            color:
                                isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'WIND SPEED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color:
                                  isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        windStr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getWindStatus(data.current.windSpeed),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2 Metrics: Apparent Temp & Atmospheric Pressure
          Row(
            children: [
              // Feels Like
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.thermostat_outlined,
                            size: 15,
                            color:
                                isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FEELS LIKE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color:
                                  isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feelsLikeStr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'CALCULATED HEAT/CHILL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Pressure
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 15,
                            color:
                                isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PRESSURE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color:
                                  isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pressureStr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getPressureStatus(data.current.surfacePressure),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

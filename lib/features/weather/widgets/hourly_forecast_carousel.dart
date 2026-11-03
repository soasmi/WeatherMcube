import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/temperature_formatter.dart';
import '../../../core/utils/wmo_code_mapper.dart';
import '../../../data/models/hourly_forecast_item.dart';

class HourlyForecastCarousel extends StatelessWidget {
  final List<HourlyForecastItem> hourlyForecast;
  final TemperatureUnit unit;

  const HourlyForecastCarousel({
    super.key,
    required this.hourlyForecast,
    required this.unit,
  });

  Color _getUvColor(double uv) {
    if (uv < 3.0) return const Color(0xFF10B981); // Low - green
    if (uv < 6.0) return const Color(0xFFFBBF24); // Moderate - yellow
    if (uv < 8.0) return const Color(0xFFF97316); // High - orange
    if (uv < 11.0) return const Color(0xFFEF4444); // Very high - red
    return const Color(0xFFA855F7); // Extreme - purple
  }

  @override
  Widget build(BuildContext context) {
    if (hourlyForecast.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '24-HOUR FORECAST & TELEMETRY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color:
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'HOURLY RADAR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 14),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = hourlyForecast[index];
                final condition = WmoCodeMapper.map(item.weatherCode);
                final timeLabel =
                    index == 0 ? 'NOW' : DateFormat('HH:mm').format(item.time);
                final tempStr = WeatherUnits.formatTemperature(
                  item.temperature,
                  unit,
                );
                final isNow = index == 0;

                return Container(
                  width: 82,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isNow
                            ? (isDark
                                ? AppColors.darkAccentMuted
                                : AppColors.lightAccentMuted)
                            : cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isNow ? accentColor : borderColor,
                      width: isNow ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isNow ? FontWeight.w900 : FontWeight.w700,
                          letterSpacing: 0.5,
                          color:
                              isNow
                                  ? accentColor
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                        ),
                      ),
                      Icon(
                        condition.icon,
                        size: 20,
                        color:
                            isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                      ),
                      Text(
                        tempStr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                        ),
                      ),
                      // Precipitation and UV badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (item.precipitationProbability > 0) ...[
                            Icon(
                              Icons.water_drop_rounded,
                              size: 10,
                              color:
                                  isDark
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item.precipitationProbability}%',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color:
                                    isDark
                                        ? const Color(0xFF93C5FD)
                                        : const Color(0xFF1D4ED8),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getUvColor(item.uvIndex),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'UV ${item.uvIndex.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color:
                                    isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

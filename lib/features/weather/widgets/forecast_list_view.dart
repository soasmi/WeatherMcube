import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/temperature_formatter.dart';
import '../../../core/utils/wmo_code_mapper.dart';
import '../../../data/models/forecast_day.dart';

class ForecastListView extends StatelessWidget {
  final List<ForecastDay> forecast;
  final TemperatureUnit unit;

  const ForecastListView({
    super.key,
    required this.forecast,
    required this.unit,
  });

  String _formatDayTitle(DateTime date, int index) {
    if (index == 0) return 'TODAY';
    if (index == 1) return 'TOMORROW';
    return DateFormat('EEE').format(date).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    // Find global min and max across all 5 days for the relative temperature indicator
    var globalMin = double.infinity;
    var globalMax = -double.infinity;
    for (final day in forecast) {
      if (day.minTemp < globalMin) globalMin = day.minTemp;
      if (day.maxTemp > globalMax) globalMax = day.maxTemp;
    }
    if (globalMin >= globalMax) {
      globalMax = globalMin + 1;
    }

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
                Icons.calendar_today_outlined,
                size: 14,
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '5-DAY FORECAST OUTLOOK',
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
              Text(
                'MIN / MAX',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color:
                      isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 4),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: forecast.length,
            separatorBuilder:
                (_, __) => Divider(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  height: 1,
                ),
            itemBuilder: (context, index) {
              final item = forecast[index];
              final condition = WmoCodeMapper.map(item.weatherCode);
              final dayLabel = _formatDayTitle(item.date, index);
              final dateLabel = DateFormat('MMM d').format(item.date);

              final minStr = WeatherUnits.formatTemperature(item.minTemp, unit);
              final maxStr = WeatherUnits.formatTemperature(item.maxTemp, unit);

              // Calculate relative bar position
              final range = globalMax - globalMin;
              final startRatio = ((item.minTemp - globalMin) / range).clamp(
                0.0,
                1.0,
              );
              final endRatio = ((item.maxTemp - globalMin) / range).clamp(
                0.0,
                1.0,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    // Day and date column
                    SizedBox(
                      width: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color:
                                  isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Weather Icon and condition description
                    Expanded(
                      child: Row(
                        children: [
                          Icon(condition.icon, size: 20, color: accentColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              condition.description,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Min Temp
                    SizedBox(
                      width: 38,
                      child: Text(
                        minStr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),

                    // Visual Temperature Range Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        width: 50,
                        height: 4,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            final left = startRatio * w;
                            final width = ((endRatio - startRatio) * w).clamp(
                              6.0,
                              w,
                            );

                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? AppColors.darkCard
                                            : AppColors.lightCard,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Positioned(
                                  left: left,
                                  width: width,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // Max Temp
                    SizedBox(
                      width: 38,
                      child: Text(
                        maxStr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

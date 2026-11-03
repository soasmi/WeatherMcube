import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/hourly_forecast_item.dart';

class UvAndPrecipitationCard extends StatelessWidget {
  final List<HourlyForecastItem> hourly;
  final double uvIndexMax;
  final double precipitationSum;
  final double surfacePressure;

  const UvAndPrecipitationCard({
    super.key,
    required this.hourly,
    required this.uvIndexMax,
    required this.precipitationSum,
    required this.surfacePressure,
  });

  String _getUvAdvisory(double uv) {
    if (uv < 3.0) {
      return 'Low danger. Enjoy outdoor activities safely.';
    }
    if (uv < 6.0) {
      return 'Moderate risk. Wear sunglasses and SPF 30+ sunscreen.';
    }
    if (uv < 8.0) {
      return 'High risk. Seek shade during midday hours.';
    }
    if (uv < 11.0) {
      return 'Very high risk. Cover up and avoid prolonged sun exposure.';
    }
    return 'Extreme risk! Stay indoors or take full protective measures.';
  }

  Color _getUvColor(double uv) {
    if (uv < 3.0) return const Color(0xFF10B981);
    if (uv < 6.0) return const Color(0xFFFBBF24);
    if (uv < 8.0) return const Color(0xFFF97316);
    if (uv < 11.0) return const Color(0xFFEF4444);
    return const Color(0xFFA855F7);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final currentUv = hourly.isNotEmpty ? hourly.first.uvIndex : uvIndexMax;
    final effectiveUv = currentUv > 0 ? currentUv : uvIndexMax;
    final uvColor = _getUvColor(effectiveUv);
    final chartItems = hourly.take(12).toList();

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
                Icons.wb_sunny_outlined,
                size: 14,
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'UV INDEX & PRECIPITATION RADAR',
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
                'MAX TODAY ${uvIndexMax.toStringAsFixed(1)}',
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
          const SizedBox(height: 16),

          // UV Telemetry Meter
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Text(
                      effectiveUv.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: uvColor,
                      ),
                    ),
                    Text(
                      'UV INDEX',
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
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: uvColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hourly.isNotEmpty
                              ? hourly.first.uvRiskLevel
                              : 'MODERATE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: uvColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getUvAdvisory(effectiveUv),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 5-segment UV spectrum meter
                    Row(
                      children: List.generate(5, (index) {
                        final active = (effectiveUv / 2.5).floor() >= index;
                        final segmentColor = switch (index) {
                          0 => const Color(0xFF10B981),
                          1 => const Color(0xFFFBBF24),
                          2 => const Color(0xFFF97316),
                          3 => const Color(0xFFEF4444),
                          _ => const Color(0xFFA855F7),
                        };
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color:
                                  active
                                      ? segmentColor
                                      : (isDark
                                          ? const Color(0xFF23262F)
                                          : const Color(0xFFD5D8E0)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 12-Hour Precipitation Probability Bar Chart
          if (chartItems.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '12-HOUR PRECIPITATION PROBABILITY (%)',
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
                const Spacer(),
                if (precipitationSum > 0)
                  Text(
                    '24H SUM: ${precipitationSum.toStringAsFixed(1)} mm',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF2563EB),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 86,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    chartItems.map((item) {
                      final prob = item.precipitationProbability;
                      final barHeight = ((prob / 100.0) * 44).clamp(4.0, 44.0);
                      final timeLabel = DateFormat('HH').format(item.time);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                prob > 0 ? '$prob%' : '',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark
                                          ? const Color(0xFF93C5FD)
                                          : const Color(0xFF1D4ED8),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color:
                                      prob > 0
                                          ? (isDark
                                              ? const Color(0xFF3B82F6)
                                              : const Color(0xFF2563EB))
                                          : (isDark
                                              ? const Color(0xFF272A33)
                                              : const Color(0xFFD1D5DB)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeLabel,
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
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

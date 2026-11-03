import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/location_item.dart';

class RecentSearchesView extends StatelessWidget {
  final List<LocationItem> recentLocations;
  final ValueChanged<LocationItem> onSelect;

  const RecentSearchesView({
    super.key,
    required this.recentLocations,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (recentLocations.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 13,
                color:
                    isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'RECENTLY SEARCHED',
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  recentLocations.map((loc) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => onSelect(loc),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loc.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                ),
                              ),
                              if (loc.countryCode != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  loc.countryCode!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

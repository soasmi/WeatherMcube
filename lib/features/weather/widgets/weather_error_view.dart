import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class WeatherErrorView extends StatelessWidget {
  final String message;
  final bool isNetworkError;
  final bool isNotFound;
  final VoidCallback onRetry;

  const WeatherErrorView({
    super.key,
    required this.message,
    this.isNetworkError = false,
    this.isNotFound = false,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final IconData icon =
        isNetworkError
            ? Icons.wifi_off_rounded
            : isNotFound
            ? Icons.search_off_rounded
            : Icons.error_outline_rounded;

    final String title =
        isNetworkError
            ? 'NO NETWORK CONNECTION'
            : isNotFound
            ? 'LOCATION NOT FOUND'
            : 'FETCH ERROR';

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2B1616) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFFFECACA),
                ),
              ),
              child: Center(
                child: Icon(icon, size: 24, color: AppColors.errorRed),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color:
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TRY AGAIN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

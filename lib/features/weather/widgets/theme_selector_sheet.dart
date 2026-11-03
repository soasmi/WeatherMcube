import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ThemeSelectorSheet extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onSelectMode;

  const ThemeSelectorSheet({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
  });

  static Future<void> show({
    required BuildContext context,
    required ThemeMode currentMode,
    required ValueChanged<ThemeMode> onSelectMode,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => ThemeSelectorSheet(
            currentMode: currentMode,
            onSelectMode: onSelectMode,
          ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return InkWell(
      onTap: () {
        onSelectMode(mode);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDark
                      ? AppColors.darkAccentMuted
                      : AppColors.lightAccentMuted)
                  : cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color:
                      isSelected
                          ? accentColor
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 20, color: accentColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'APPEARANCE & THEME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color:
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                splashRadius: 16,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildOption(
            context: context,
            mode: ThemeMode.system,
            title: 'System Default',
            subtitle: 'Automatically adapts to your device day/night settings',
            icon: Icons.brightness_auto_rounded,
            isSelected: currentMode == ThemeMode.system,
          ),
          _buildOption(
            context: context,
            mode: ThemeMode.dark,
            title: 'Matte Carbon (Dark)',
            subtitle:
                'High-contrast obsidian theme with racing speed-lime accents',
            icon: Icons.dark_mode_rounded,
            isSelected: currentMode == ThemeMode.dark,
          ),
          _buildOption(
            context: context,
            mode: ThemeMode.light,
            title: 'Industrial Chalk (Light)',
            subtitle:
                'Clean daylight aesthetic with precision dark slate contrast',
            icon: Icons.light_mode_rounded,
            isSelected: currentMode == ThemeMode.light,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/temperature_formatter.dart';
import '../../../data/models/weather_data.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/weather_state.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/forecast_list_view.dart';
import '../widgets/hourly_forecast_carousel.dart';
import '../widgets/location_selection_dialog.dart';
import '../widgets/offline_banner.dart';
import '../widgets/recent_searches_view.dart';
import '../widgets/theme_selector_sheet.dart';
import '../widgets/uv_and_precipitation_card.dart';
import '../widgets/weather_empty_state.dart';
import '../widgets/weather_error_view.dart';
import '../widgets/weather_search_bar.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  Widget _buildWeatherTelemetry(WeatherData data, TemperatureUnit unit) {
    final todayForecast =
        data.dailyForecast.isNotEmpty ? data.dailyForecast.first : null;

    return Column(
      children: [
        CurrentWeatherView(data: data, unit: unit),
        if (data.hourlyForecast.isNotEmpty) ...[
          const SizedBox(height: 16),
          HourlyForecastCarousel(
            hourlyForecast: data.hourlyForecast,
            unit: unit,
          ),
          const SizedBox(height: 16),
          UvAndPrecipitationCard(
            hourly: data.hourlyForecast,
            uvIndexMax: todayForecast?.uvIndexMax ?? 0.0,
            precipitationSum: todayForecast?.precipitationSum ?? 0.0,
            surfacePressure: data.current.surfacePressure,
          ),
        ],
        const SizedBox(height: 16),
        ForecastListView(forecast: data.dailyForecast, unit: unit),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final isSearching = weatherState is WeatherSearchingLocationsState;
    final isLoadingData = weatherState is WeatherLoadingDataState;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'METEO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'MCUBE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color:
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Unit toggle button (°C / °F)
          InkWell(
            onTap: () {
              ref.read(settingsProvider.notifier).toggleTemperatureUnit();
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  settings.unit == TemperatureUnit.celsius ? '°C' : '°F',
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
            ),
          ),

          // Theme selector button with dedicated modal sheet
          IconButton(
            tooltip: 'Appearance & Theme',
            icon: Icon(
              switch (settings.themeMode) {
                ThemeMode.dark => Icons.dark_mode_rounded,
                ThemeMode.light => Icons.light_mode_rounded,
                ThemeMode.system => Icons.brightness_auto_rounded,
              },
              size: 20,
              color:
                  isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
            ),
            onPressed: () {
              ThemeSelectorSheet.show(
                context: context,
                currentMode: settings.themeMode,
                onSelectMode: (mode) {
                  ref.read(settingsProvider.notifier).setThemeMode(mode);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: accentColor,
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          onRefresh: () async {
            await ref.read(weatherNotifierProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Field with GPS Button
                WeatherSearchBar(
                  isLoading: isSearching || isLoadingData,
                  onCurrentLocation: () {
                    ref
                        .read(weatherNotifierProvider.notifier)
                        .fetchCurrentLocationWeather();
                  },
                  onSearch: (query) {
                    ref
                        .read(weatherNotifierProvider.notifier)
                        .searchCity(query);
                  },
                ),

                // Recent searches
                RecentSearchesView(
                  recentLocations: recentSearches,
                  onSelect: (loc) {
                    ref
                        .read(weatherNotifierProvider.notifier)
                        .selectLocation(loc);
                  },
                ),

                const SizedBox(height: 14),

                // Active State Handling
                switch (weatherState) {
                  WeatherInitialState() => WeatherEmptyState(
                    onSelectPreset: (city) {
                      ref
                          .read(weatherNotifierProvider.notifier)
                          .searchCity(city);
                    },
                  ),

                  WeatherSearchingLocationsState(:final query) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(accentColor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'SEARCHING FOR "$query"...',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
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

                  WeatherLocationsDisambiguationState(
                    :final query,
                    :final locations,
                    :final previousData,
                  ) =>
                    Column(
                      children: [
                        LocationSelectionDialog(
                          query: query,
                          locations: locations,
                          onSelect: (loc) {
                            ref
                                .read(weatherNotifierProvider.notifier)
                                .selectLocation(loc);
                          },
                          onCancel: () {
                            ref
                                .read(weatherNotifierProvider.notifier)
                                .cancelDisambiguation();
                          },
                        ),
                        if (previousData != null) ...[
                          const SizedBox(height: 12),
                          _buildWeatherTelemetry(previousData, settings.unit),
                        ],
                      ],
                    ),

                  WeatherLoadingDataState(
                    :final location,
                    :final previousData,
                  ) =>
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'FETCHING FORECAST FOR ${location.name.toUpperCase()}...',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color:
                                      isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (previousData != null)
                          _buildWeatherTelemetry(previousData, settings.unit),
                      ],
                    ),

                  WeatherSuccessState(:final weatherData) => Column(
                    children: [
                      if (weatherData.isFromCache)
                        OfflineBanner(
                          cachedAt: weatherData.fetchedAt,
                          isRefreshing: isLoadingData,
                          onRetry: () {
                            ref
                                .read(weatherNotifierProvider.notifier)
                                .refresh();
                          },
                        ),
                      _buildWeatherTelemetry(weatherData, settings.unit),
                    ],
                  ),

                  WeatherErrorState(
                    :final message,
                    :final isNetworkError,
                    :final isNotFound,
                    :final cachedData,
                  ) =>
                    Column(
                      children: [
                        if (cachedData != null) ...[
                          OfflineBanner(
                            cachedAt: cachedData.fetchedAt,
                            isRefreshing: isLoadingData,
                            onRetry: () {
                              ref
                                  .read(weatherNotifierProvider.notifier)
                                  .refresh();
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? const Color(0xFF261212)
                                      : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isDark
                                        ? const Color(0xFF7F1D1D)
                                        : const Color(0xFFFECACA),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 15,
                                  color: AppColors.errorRed,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? const Color(0xFFFCA5A5)
                                              : const Color(0xFF991B1B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildWeatherTelemetry(cachedData, settings.unit),
                        ] else
                          WeatherErrorView(
                            message: message,
                            isNetworkError: isNetworkError,
                            isNotFound: isNotFound,
                            onRetry: () {
                              ref
                                  .read(weatherNotifierProvider.notifier)
                                  .resetToInitial();
                            },
                          ),
                      ],
                    ),
                },
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

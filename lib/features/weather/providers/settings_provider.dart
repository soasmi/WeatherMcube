import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/temperature_formatter.dart';
import '../../../data/services/weather_storage_service.dart';

class SettingsState {
  final TemperatureUnit unit;
  final ThemeMode themeMode;

  const SettingsState({
    required this.unit,
    required this.themeMode,
  });

  SettingsState copyWith({
    TemperatureUnit? unit,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      unit: unit ?? this.unit,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final WeatherStorageService _storageService;

  SettingsNotifier(this._storageService)
      : super(
          SettingsState(
            unit: _parseUnit(_storageService.getTemperatureUnit()),
            themeMode: _parseThemeMode(_storageService.getThemeMode()),
          ),
        );

  static TemperatureUnit _parseUnit(String? raw) {
    if (raw == 'fahrenheit') return TemperatureUnit.fahrenheit;
    return TemperatureUnit.celsius;
  }

  static ThemeMode _parseThemeMode(String? raw) {
    return switch (raw) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  void toggleTemperatureUnit() {
    final next = state.unit == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    state = state.copyWith(unit: next);
    _storageService.saveTemperatureUnit(next.name);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _storageService.saveThemeMode(mode.name);
  }

  void cycleThemeMode() {
    final next = switch (state.themeMode) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
    };
    setThemeMode(next);
  }
}

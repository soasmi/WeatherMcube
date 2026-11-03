import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_item.dart';
import '../models/weather_data.dart';

class WeatherStorageService {
  static const String _cachedWeatherKey = 'weather_mcube_cached_weather';
  static const String _recentLocationsKey = 'weather_mcube_recent_locations';
  static const String _temperatureUnitKey = 'weather_mcube_temp_unit';
  static const String _themeModeKey = 'weather_mcube_theme_mode';

  final SharedPreferences _prefs;

  WeatherStorageService(this._prefs);

  Future<void> saveWeather(WeatherData data) async {
    final jsonMap = data.toJson();
    jsonMap['is_from_cache'] = true;
    final jsonString = jsonEncode(jsonMap);
    await _prefs.setString(_cachedWeatherKey, jsonString);
  }

  WeatherData? getLastSavedWeather() {
    final raw = _prefs.getString(_cachedWeatherKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return WeatherData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> addRecentLocation(LocationItem item) async {
    final currentList = getRecentLocations();
    final updated = [
      item,
      ...currentList.where((loc) =>
          loc.latitude != item.latitude || loc.longitude != item.longitude),
    ].take(6).toList();

    final jsonList = updated.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_recentLocationsKey, jsonList);
  }

  List<LocationItem> getRecentLocations() {
    final rawList = _prefs.getStringList(_recentLocationsKey);
    if (rawList == null || rawList.isEmpty) return [];

    final result = <LocationItem>[];
    for (final item in rawList) {
      try {
        result.add(LocationItem.fromJson(jsonDecode(item)));
      } catch (_) {}
    }
    return result;
  }

  Future<void> saveTemperatureUnit(String unit) async {
    await _prefs.setString(_temperatureUnitKey, unit);
  }

  String? getTemperatureUnit() {
    return _prefs.getString(_temperatureUnitKey);
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(_themeModeKey);
  }
}

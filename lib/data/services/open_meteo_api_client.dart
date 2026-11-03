import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/location_item.dart';
import '../models/weather_data.dart';

class OpenMeteoApiClient {
  final http.Client _client;
  final Duration _timeout;

  OpenMeteoApiClient({http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? ApiConstants.requestTimeout;

  Future<List<LocationItem>> searchCities(String query) async {
    final sanitized = query.trim();
    if (sanitized.isEmpty) {
      return const [];
    }

    final uri = Uri.parse(
      '${ApiConstants.geocodingBaseUrl}?name=${Uri.encodeComponent(sanitized)}&count=${ApiConstants.geocodingCount}',
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherException.serverError(response.statusCode);
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final results = data['results'] as List?;

      if (results == null || results.isEmpty) {
        return const [];
      }

      return results
          .map((item) => LocationItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on SocketException {
      throw WeatherException.noInternet();
    } on TimeoutException {
      throw WeatherException.timeout();
    } on FormatException {
      throw WeatherException.malformedData();
    } on WeatherException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('ClientException')) {
        throw WeatherException.noInternet();
      }
      throw WeatherException('Unexpected error searching for city: $e');
    }
  }

  Future<WeatherData> fetchWeather(LocationItem location) async {
    final queryParams = {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': ApiConstants.currentParameters,
      'daily': ApiConstants.dailyParameters,
      'forecast_days': ApiConstants.forecastDays.toString(),
      'timezone': ApiConstants.defaultTimezone,
    };

    final uri = Uri.parse(
      ApiConstants.forecastBaseUrl,
    ).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherException.serverError(response.statusCode);
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      return WeatherData.fromApiResponse(
        location: location,
        forecastJson: data,
        isFromCache: false,
      );
    } on SocketException {
      throw WeatherException.noInternet();
    } on TimeoutException {
      throw WeatherException.timeout();
    } on FormatException {
      throw WeatherException.malformedData();
    } on WeatherException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('ClientException')) {
        throw WeatherException.noInternet();
      }
      throw WeatherException('Unexpected error fetching weather: $e');
    }
  }

  void close() {
    _client.close();
  }
}

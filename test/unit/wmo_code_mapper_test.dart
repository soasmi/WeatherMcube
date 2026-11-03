import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mcube/core/utils/wmo_code_mapper.dart';

void main() {
  group('WmoCodeMapper', () {
    test('maps code 0 to Clear Sky with sunny icon', () {
      final condition = WmoCodeMapper.map(0);
      expect(condition.description, 'Clear Sky');
      expect(condition.codeGroup, 'clear');
      expect(condition.icon, Icons.wb_sunny_rounded);
    });

    test('maps cloud codes 1, 2, 3 correctly', () {
      expect(WmoCodeMapper.map(1).description, 'Mainly Clear');
      expect(WmoCodeMapper.map(2).description, 'Partly Cloudy');
      expect(WmoCodeMapper.map(3).description, 'Overcast');
    });

    test('maps fog codes 45, 48 correctly', () {
      expect(WmoCodeMapper.map(45).description, 'Foggy');
      expect(WmoCodeMapper.map(48).description, 'Depositing Rime Fog');
    });

    test('maps drizzle codes 51, 53, 55 correctly', () {
      expect(WmoCodeMapper.map(51).description, 'Light Drizzle');
      expect(WmoCodeMapper.map(53).description, 'Moderate Drizzle');
      expect(WmoCodeMapper.map(55).description, 'Dense Drizzle');
    });

    test('maps rain codes 61, 63, 65 correctly', () {
      expect(WmoCodeMapper.map(61).description, 'Slight Rain');
      expect(WmoCodeMapper.map(63).description, 'Moderate Rain');
      expect(WmoCodeMapper.map(65).description, 'Heavy Rain');
    });

    test('maps snow codes 71, 73, 75 correctly', () {
      expect(WmoCodeMapper.map(71).description, 'Slight Snow Fall');
      expect(WmoCodeMapper.map(73).description, 'Moderate Snow Fall');
      expect(WmoCodeMapper.map(75).description, 'Heavy Snow Fall');
    });

    test('maps showers 80, 81, 82 correctly', () {
      expect(WmoCodeMapper.map(80).description, 'Slight Rain Showers');
      expect(WmoCodeMapper.map(81).description, 'Moderate Rain Showers');
      expect(WmoCodeMapper.map(82).description, 'Violent Rain Showers');
    });

    test('maps thunderstorm codes 95, 96, 99 correctly', () {
      expect(WmoCodeMapper.map(95).description, 'Thunderstorm');
      expect(
        WmoCodeMapper.map(96).description,
        'Thunderstorm With Slight Hail',
      );
      expect(WmoCodeMapper.map(99).description, 'Thunderstorm With Heavy Hail');
    });

    test('maps unknown or null code to fallback Unknown', () {
      final nullCondition = WmoCodeMapper.map(null);
      expect(nullCondition.description, 'Unknown');
      expect(nullCondition.icon, Icons.cloud_outlined);

      final invalidCodeCondition = WmoCodeMapper.map(9999);
      expect(invalidCodeCondition.description, 'Unknown');
    });
  });
}

import 'package:geolocator/geolocator.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/location_item.dart';

class LocationService {
  Future<LocationItem> getCurrentDeviceLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const WeatherException(
        'Location services are disabled on your device. Please enable GPS in settings.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const WeatherException(
          'Location permission was denied. You can still search by city name.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const WeatherException(
        'Location permissions are permanently denied. Please enable location permissions in system settings.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationItem(
        id: -1,
        name: 'My Location',
        latitude: double.parse(position.latitude.toStringAsFixed(4)),
        longitude: double.parse(position.longitude.toStringAsFixed(4)),
        country: 'Local Device GPS',
        countryCode: 'GPS',
        admin1:
            '${position.latitude.toStringAsFixed(2)}°, ${position.longitude.toStringAsFixed(2)}°',
      );
    } catch (e) {
      throw WeatherException(
        'Unable to determine device coordinates: ${e.toString().replaceAll('Exception:', '')}',
      );
    }
  }
}

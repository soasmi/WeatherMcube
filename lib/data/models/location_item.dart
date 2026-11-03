class LocationItem {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;
  final String? countryCode;

  const LocationItem({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
    this.countryCode,
  });

  String get subtitle {
    final parts = <String>[];
    if (admin1 != null && admin1!.trim().isNotEmpty) {
      parts.add(admin1!.trim());
    }
    if (country.trim().isNotEmpty) {
      parts.add(country.trim());
    }
    return parts.join(', ');
  }

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: (json['id'] as num?)?.toInt() ??
          DateTime.now().microsecondsSinceEpoch,
      name: (json['name'] as String?)?.trim() ?? 'Unknown Location',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?)?.trim() ?? '',
      admin1: json['admin1'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
        'country_code': countryCode,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(id, latitude, longitude);
}

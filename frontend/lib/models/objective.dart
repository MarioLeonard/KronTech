import 'package:latlong2/latlong.dart';

class Objective {
  const Objective({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.longDescription,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    required this.category,
    required this.rating,
    required this.openingHours,
    required this.address,
  });

  final String id;
  final String name;
  final String shortDescription;
  final String longDescription;
  final String imageUrl;
  final double lat;
  final double lng;
  final String category;
  final double rating;
  final String openingHours;
  final String address;

  LatLng get latLng => LatLng(lat, lng);

  Map<String, dynamic> toJson() => {
        'id': id,
        'lat': lat,
        'lng': lng,
      };
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String type;
  final String name;
  final String description;
  final GeoPoint location;
  final String imageUrl;

  Station({
    required this.type,
    required this.name,
    required this.description,
    required this.location,
    this.imageUrl = '',
  });

  factory Station.fromMap(Map<String, dynamic> data, {String? docId}) {
    return Station(
      type: data['type'] ?? 'Station',
      name: data['name'] ?? 'Station',
      description: data['description'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
    };
  }
}
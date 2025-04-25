import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String id;
  final String type;
  final String name;
  final String description;
  final GeoPoint location;
  final List<String> amenities;
  final String imageUrl;
  final double rating;

  Station({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.location,
    this.amenities = const [],
    this.imageUrl = '',
    this.rating = 0.0,
  });

  factory Station.fromMap(Map<String, dynamic> data, {String? docId}) {
    return Station(
      id: docId ?? data['id'] ?? '',
      type: data['type'] ?? 'Station',
      name: data['name'] ?? 'Station',
      description: data['description'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      amenities: List<String>.from(data['amenities'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'location': location,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }
}
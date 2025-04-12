import 'package:metro_zoomin/databaseconnection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String type;
  final String name;
  final String description;
  final GeoPoint location;

  Station({required this.type, required this.name, required this.description,
    required this.location});

  factory Station.fromMap(Map<String, dynamic> data) {
    return Station(
      type: data['type'] ?? 'Station',
      name: data['name'] ?? 'Station',
      description: data['description'],
      location: data['location'],
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrozoomin/Models/Station.dart';
import 'dart:math' as math;

class StationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all stations
  Future<List<Station>> getAllStations() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('stations').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Station.fromMap(data, docId: doc.id);
      }).toList();
    } catch (e) {
      print('Error getting stations: $e');
      return [];
    }
  }

  // Get station by ID
  Future<Station?> getStationById(String stationId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('stations').doc(stationId).get();

      if (doc.exists) {
        return Station.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      }

      return null;
    } catch (e) {
      print('Error getting station: $e');
      return null;
    }
  }

  // Get nearby stations based on user location
  Future<List<Station>> getNearbyStations(GeoPoint userLocation, double radiusInKm) async {
    try {
      // This is a simplified approach. For production, consider using GeoFirestore or similar
      final QuerySnapshot snapshot = await _firestore.collection('stations').get();

      final List<Station> allStations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Station.fromMap(data, docId: doc.id);
      }).toList();

      // Filter stations based on distance
      return allStations.where((station) {
        final double distance = _calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            station.location.latitude,
            station.location.longitude
        );

        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      print('Error getting nearby stations: $e');
      return [];
    }
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
            math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
                math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  String username;
  String email;
  String phone;
  String gender;
  String photoUrl;
  final DateTime createdAt;
  List<String> favoriteStations;
  int pin;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phone = '',
    this.gender = 'Prefer not to say',
    this.photoUrl = '',
    required this.createdAt,
    this.favoriteStations = const [],
    this.pin = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return UserModel(
      id: id,
      username: data['username'] ?? 'User',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? 'Prefer not to say',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      favoriteStations: List<String>.from(data['favoriteStations'] ?? []),
      pin: data['pin'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'gender': gender,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'favoriteStations': favoriteStations,
      'pin': pin,
    };
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('users').doc(id).set(toMap());
  }
}
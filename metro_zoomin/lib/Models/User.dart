import 'package:metro_zoomin/databaseconnection.dart';

class User {
  String username;
  String password;
  final DateTime dob;
  String email;
  String phone;
  String gender;
  int pin;

  User({required this.username, required this.password, required this.dob, required this.email,
    this.phone = '0', this.gender = 'Prefer not to say', this.pin = 0});

  Future<void> insertUser() async {
    DatabaseHelper.addUser(username, password, dob, email, phone, gender, pin);
  }

  Future<void> updateUser(String id) async {
    DatabaseHelper.updateUser(id, username, password, email, phone, gender, pin);
  }

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      username: data['username'] ?? 'username',
      password: data['password'] ?? 'password',
      dob: data['dob'],
      email: data['email'] ?? '',
      phone: data['phone'] ?? '000-000-0000',
      gender: data['gender'] ?? 'Prefer not to say',
      pin: data['pin'] ?? 0,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/User.dart';
import '../Models/Station.dart';

class DatabaseHelper {
  static CollectionReference users = FirebaseFirestore.instance.collection('users');
  static CollectionReference stations = FirebaseFirestore.instance.collection('stations');

  static Future<void> addUser(String username, String password, DateTime dob, String email, String phone, String gender, int pin) async {
    if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty) {
      try {
        await users.add({
          'username': username,
          'password': password,
          'dob': dob,
          'email': email,
          'phone': phone,
          'gender': gender,
          'pin': pin,
        });
        print('User $username added successfully.');
      } catch (error) {
        print('Failed to add user $username to the Firestore: $error');
      }
    }
  }

  static Future<void> updateUser(String id, String newUsername, String newPassword, String newEmail, String newPhone, String newGender, int newPin) async {
    if (newUsername.isNotEmpty && newPassword.isNotEmpty && newEmail.isNotEmpty) {
      try {
        await users.doc(id).update({
          'username': newUsername,
          'password': newPassword,
          'email': newEmail,
          'phone': newPhone,
          'gender': newGender,
          'pin': newPin,
        });
        print('User $newUsername updated successfully');
      } catch (error) {
        print('Failed to update the user $newUsername in the Firestore: $error');
      }
    }
  }

  static Future<UserModel?> getUser(String id) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot snapshot = await firestore.collection('Users').doc(id).get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        print('User found: $userData');
        return UserModel.fromMap(userData, id: id);
      } else {
        print('User does not exist');
      }
    } catch (e) {
      print('Error retrieving user: $e');
    }
    return null;
  }

  static Future<Station?> getStation(String id) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot snapshot = await firestore.collection('Station').doc(id).get();

      if (snapshot.exists) {
        Map<String, dynamic> stationData = snapshot.data() as Map<String, dynamic>;
        print('Station found: $stationData');
        return Station.fromMap(stationData, docId: id);
      } else {
        print('Station does not exist');
      }
    } catch (e) {
      print('Error retrieving station: $e');
    }
    return null;
  }
}
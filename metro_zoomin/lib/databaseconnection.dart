import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference stations = FirebaseFirestore.instance.collection('stations');

  Future<void> addUser(String username, String password, DateTime dob, String email, int phone, String gender, String pin) async {
    if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty) {
      try {
        await users.add({
          'username': username,
          'password': password,
          'dob': dob,
          'email': email,
          'phone': phone,
          'gender': gender,
          'ping': pin,
        });
        print('User $username added successfully.');
      } catch (error) {
        print('Failed to add user $username to the Firestore: $error');
      }
    }
  }

  Future<void> updateUser(String id, String newUsername, String newPassword, String newEmail, int newPhone, String newGender, String newPin) async {
    if (newUsername.isNotEmpty && newPassword.isNotEmpty && newEmail.isNotEmpty) {
      try {
        await users.doc(id).update({
          'username': newUsername,
          'password': newPassword,
          'email': newEmail,
          'phone': newPhone,
          'gender': newGender,
          'ping': newPin,
        });
        print('User $newUsername updated successfully');
      } catch (error) {
        print('Failed to update the user $newUsername in the Firestore: $error');
      }
    }
  }
}
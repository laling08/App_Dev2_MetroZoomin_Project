import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SocialProvider {
  google,
  facebook,
  //twitter,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing in with email and password: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (result.user != null) {
        await _createUserDocument(result.user!);
      }

      return result.user;
    } catch (e) {
      print('Error signing up with email and password: $e');
      return null;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'username': user.displayName ?? user.email?.split('@')[0] ?? 'User',
      'createdAt': FieldValue.serverTimestamp(),
      'photoURL': user.photoURL,
    });
  }

  // Sign in with social provider
  Future<User?> signInWithSocialProvider(SocialProvider provider) async {
    try {
      late final UserCredential authResult;

      switch (provider) {
        case SocialProvider.google:
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser == null) return null;

          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          authResult = await _auth.signInWithCredential(credential);
          break;

        case SocialProvider.facebook:
          final LoginResult loginResult = await FacebookAuth.instance.login();
          if (loginResult.status != LoginStatus.success) return null;

          final OAuthCredential credential = FacebookAuthProvider.credential(
            loginResult.accessToken!.token,
          );

          authResult = await _auth.signInWithCredential(credential);
          break;
      //
      // case SocialProvider.twitter:
      //   final twitterLogin = TwitterLogin(
      //     apiKey: 'YOUR_TWITTER_API_KEY',
      //     apiSecretKey: 'YOUR_TWITTER_API_SECRET_KEY',
      //     redirectURI: 'metrozoomin://',
      //   );
      //
      //   final authResult = await twitterLogin.login();
      //   if (authResult.status != TwitterLoginStatus.loggedIn) return null;
      //
      //   final OAuthCredential credential = TwitterAuthProvider.credential(
      //     accessToken: authResult.authToken!,
      //     secret: authResult.authTokenSecret!,
      //   );
      //
      //   final userCredential = await _auth.signInWithCredential(credential);
      //
      //   // Create user document in Firestore
      //   if (userCredential.user != null) {
      //     await _createUserDocument(userCredential.user!);
      //   }
      //
      //   return userCredential.user;
      }

      // Create user document in Firestore for Google and Facebook
      if (authResult.user != null) {
        await _createUserDocument(authResult.user!);
      }

      return authResult.user;
    } catch (e) {
      print('Error signing in with social provider: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? phone,
    String? gender,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update auth profile
        if (displayName != null || photoURL != null) {
          await user.updateDisplayName(displayName);
          await user.updatePhotoURL(photoURL);
        }

        // Update Firestore document
        final Map<String, dynamic> userData = {};
        if (displayName != null) userData['username'] = displayName;
        if (photoURL != null) userData['photoURL'] = photoURL;
        if (phone != null) userData['phone'] = phone;
        if (gender != null) userData['gender'] = gender;

        await _firestore.collection('users').doc(user.uid).update(userData);
      }
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }
}

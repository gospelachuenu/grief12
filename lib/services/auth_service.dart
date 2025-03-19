import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

enum LoginStatus { success, error, cancelled }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Generate 5-digit user ID
  String _generateUserId() {
    Random random = Random();
    return random.nextInt(90000).toString().padLeft(5, '0');
  }

  // Create user profile in Firestore
  Future<void> createUserProfile(String uid, String email, {String? name, String? surname}) async {
    final String userId = _generateUserId();
    
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'name': name ?? '',
      'surname': surname ?? '',
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Email Sign Up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user profile with generated ID
      await createUserProfile(userCredential.user!.uid, email, name: userCredential.user!.displayName, surname: userCredential.user!.displayName);
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email Sign In
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<LoginStatus> signInWithGoogle() async {
    try {
      // Start the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return LoginStatus.cancelled;

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create/update user document
      await _createUserDocument(userCredential.user!);

      return LoginStatus.success;
    } catch (e) {
      print('Google sign in error: $e');
      return LoginStatus.error;
    }
  }

  // Facebook Sign In
  Future<LoginStatus> signInWithFacebook() async {
    try {
      // Start the Facebook sign-in flow
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        // Get access token
        final AccessToken accessToken = result.accessToken!;

        // Create credential
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.token,
        );

        // Sign in to Firebase
        final userCredential = await _auth.signInWithCredential(credential);
        
        // Create/update user document
        await _createUserDocument(userCredential.user!);

        return LoginStatus.success;
      } else if (result.status == LoginStatus.cancelled) {
        return LoginStatus.cancelled;
      } else {
        return LoginStatus.error;
      }
    } catch (e) {
      print('Facebook sign in error: $e');
      return LoginStatus.error;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Error signing out');
    }
  }

  // Create/Update user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    
    final userData = {
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastSignIn': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Use set with merge to update existing documents
    await userDoc.set(userData, SetOptions(merge: true));
  }

  // Handle Firebase Auth Exceptions
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return Exception('The password provided is too weak.');
        case 'email-already-in-use':
          return Exception('An account already exists for that email.');
        case 'user-not-found':
          return Exception('No user found for that email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'invalid-email':
          return Exception('The email address is badly formatted.');
        default:
          return Exception(e.message ?? 'An unknown error occurred.');
      }
    }
    return Exception('An unknown error occurred.');
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      if (currentUser != null) {
        await currentUser!.updateDisplayName(displayName);
        await currentUser!.updatePhotoURL(photoURL);
        
        // Update Firestore document
        await _firestore.collection('users').doc(currentUser!.uid).update({
          if (displayName != null) 'displayName': displayName,
          if (photoURL != null) 'photoURL': photoURL,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send verification email
  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
} 
// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method untuk Login
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return {'success': true, 'message': 'Login successful!'};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return {'success': false, 'message': 'Incorrect email or password.'};
      }
      return {'success': false, 'message': 'An error occurred. Please try again.'};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Method untuk Register
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String username,
    required String name,
  }) async {
    try {
      // 1. Buat user di Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan informasi tambahan ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'name': name,
        'email': email,
      });

      return {'success': true, 'message': 'Registration successful!'};

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {'success': false, 'message': 'The password provided is too weak.'};
      } else if (e.code == 'email-already-in-use') {
        return {'success': false, 'message': 'An account already exists for that email.'};
      }
       return {'success': false, 'message': 'An error occurred: ${e.message}'};
    } catch (e) {
       return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }
}
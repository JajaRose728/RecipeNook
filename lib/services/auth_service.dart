import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sign up with username & password
  Future<void> signUp(String username, String password) async {
    final docRef = _db.collection('users').doc(username);

    final doc = await docRef.get();
    if (doc.exists) {
      throw Exception("Username already exists");
    }

    await docRef.set({
      'password': password, // store plain text (for demo only)
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Login with username & password
  Future<void> login(String username, String password) async {
    final doc = await _db.collection('users').doc(username).get();

    if (!doc.exists) {
      throw Exception("Username not found");
    }

    if (doc.data()!['password'] != password) {
      throw Exception("Incorrect password");
    }

    // login success
  }
}

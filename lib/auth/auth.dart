import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;
  String get userId => currentUser?.uid ?? '';
  late DocumentSnapshot? userDoc = null;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> getUserDoc() async {
    if (currentUser != null) {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser?.email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        userDoc = userQuery.docs.first;
      }
      else {
        userDoc = null;
      }
    }
  }

  Future<String?> getUserField(String field) async {
    await getUserDoc();
    return userDoc?[field];
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ INSCRIPTION
  Future<String?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = result.user!.uid;
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'createdAt': DateTime.now(),
      });
      return role;
    } on FirebaseAuthException catch (e) {
      print('Erreur inscription: $e');
      rethrow; // propage l'erreur pour l'afficher dans l'UI
    } catch (e) {
      print('Erreur inconnue: $e');
      rethrow;
    }
  }

  // ✅ CONNEXION
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = result.user!.uid;
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      String role = doc['role'];
      return role;
    } catch (e) {
      print('Erreur connexion: $e');
      return null;
    }
  }

  // ✅ DÉCONNEXION
  Future<void> logout() async {
    await _auth.signOut();
  }
}

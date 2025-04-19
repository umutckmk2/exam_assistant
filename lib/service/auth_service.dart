import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignIn? _googleSignIn;
  bool _initialized = false;

  // Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get settings from Firestore
      final settingsDoc =
          await _firestore.collection('app').doc('settings').get();

      if (settingsDoc.exists) {
        final data = settingsDoc.data();
        final clientId = data?['googleClientId'] as String?;

        if (clientId != null) {
          _googleSignIn = GoogleSignIn(clientId: clientId, scopes: ['email']);
          _initialized = true;
        }
      }
    } catch (e) {
      // Fallback to default initialization
      _googleSignIn = GoogleSignIn(scopes: ['email']);
      _initialized = true;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  // Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      return null;
    }
  }

  // Unlink provider
  Future<void> unlinkProvider(String providerId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.unlink(providerId);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn?.signOut() ?? Future.value(),
      ]);
    } catch (e) {
      rethrow;
    }
  }
}

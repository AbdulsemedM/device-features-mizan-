import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get curentUser => _auth.currentUser;

  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      throw "An error ocurred while loging in. Please try again.";
    }
  }

  Future<UserCredential> signupWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      throw "An error ocurred while signing up. Please try again.";
    }
  }

Future<void> signout()async{
  try {
    await _auth.signOut();
  } catch (e) {
    throw "An error ocurred while signing out. Please try again.";
  }
}

Future<void> resetPassword(String email)async{

try {
  await _auth.sendPasswordResetEmail(email: email);
} catch (e) {
  throw "An error ocurred while resetting password. Please try again.";
}
}

}

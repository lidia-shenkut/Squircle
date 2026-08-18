import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserCredential> registerWithEmail(String email, String password);
  Future<void> registerWithPhone(String phoneNumber, {
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(PhoneAuthCredential credential) verificationCompleted,
  });
  Future<UserCredential> verifyPhoneOtp(String verificationId, String smsCode);
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  User? get currentUser;
}

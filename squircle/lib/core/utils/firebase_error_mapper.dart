import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static String fromAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this credential.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'phone-number-already-exists':
        return 'This phone number is already registered.';
      case 'invalid-phone-number':
        return 'The phone number format is invalid.';
      case 'session-expired':
        return 'Your session has expired. Please sign in again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  static String fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You don\'t have access to this content.';
      case 'not-found':
        return 'The requested content was not found.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'storage/unauthorized':
        return 'File upload failed. Check file type and size.';
      case 'storage/canceled':
        return 'Upload was cancelled.';
      case 'storage/unknown':
        return 'An unknown storage error occurred.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static String fromException(Object e) {
    if (e is FirebaseAuthException) return fromAuthException(e);
    return 'Something went wrong. Please try again.';
  }
}

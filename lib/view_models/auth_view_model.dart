import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

// ViewModel that manages authentication state and communicates with AuthService.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  // Returns whether an authentication operation is in progress.
  bool get isLoading {
    return _isLoading;
  }

  // Returns the current error message, or null if no error.
  String? get error {
    return _error;
  }

  // Updates the loading state and notifies listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Updates the error message and notifies listeners.
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Attempts to log in with the given email and password.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      // Call the auth service to sign in.
      await _authService.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      // Map the Firebase error to a user-friendly message.
      _setError(_mapFirebaseError(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Attempts to register a new account with the given email and password.
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      // Call the auth service to sign up.
      await _authService.signUp(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      // Map the Firebase error to a user-friendly message.
      _setError(_mapFirebaseError(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }


  // Signs out the current user.
  Future<void> logout() {
    return _authService.signOut();
  }

  // Converts a FirebaseAuthException error code to a human-readable string.
  String _mapFirebaseError(FirebaseAuthException e) {
    if (e.code == 'invalid-email') {
      return 'Invalid email format.';
    }
    if (e.code == 'user-disabled') {
      return 'This account is disabled.';
    }
    if (e.code == 'user-not-found') {
      return 'No user found for this email.';
    }
    if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      return 'Invalid email or password.';
    }
    if (e.code == 'email-already-in-use') {
      return 'This email is already in use.';
    }
    if (e.code == 'email-in-use-use-login') {
      return 'This email already exists. Please log in instead.';
    }
    if (e.code == 'weak-password') {
      return 'Password must be at least 6 characters.';
    }
    if (e.code == 'too-many-requests') {
      return 'Too many attempts. Please try again in a few minutes.';
    }
    if (e.code == 'network-request-failed') {
      return 'Network error. Please check your internet connection.';
    }
    if (e.message != null) {
      return e.message!;
    }
    return 'Authentication failed.';
  }
}

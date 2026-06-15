import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Handles all Firebase Authentication and user profile operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ensures every authenticated account has a user profile document in Firestore.
  Future<void> ensureUserProfile(User user) async {
    // Reference the user document by UID.
    DocumentReference<Map<String, dynamic>> docRef =
        _firestore.collection('users').doc(user.uid);
    DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

    // If the profile already exists, do nothing.
    if (doc.exists) {
      return;
    }

    // Create a default profile with the user email.
    String email = (user.email ?? '').trim();
    Map<String, dynamic> defaultProfile = {
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await docRef.set(defaultProfile);
  }

  // Signs in a user with email and password credentials.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    // Attempt to sign in with Firebase Auth.
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Verify that a user object was returned.
    User? user = credential.user;
    if (user == null) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Invalid email or password.',
      );
    }

    // Ensure the user has a Firestore profile document.
    await ensureUserProfile(user);
    return credential;
  }

  // Registers a new user account with email and password.
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    String normalizedEmail = email.trim();
    String normalizedPassword = password.trim();

    try {
      // Attempt to create a new Firebase Auth account.
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: normalizedPassword,
      );

      // Verify that a user object was returned.
      User? user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Invalid email or password.',
        );
      }

      // Ensure the user has a Firestore profile document.
      await ensureUserProfile(user);
      return credential;
    } on FirebaseAuthException catch (e) {
      // If the email is already in use, try signing in instead.
      if (e.code != 'email-already-in-use') {
        rethrow;
      }

      try {
        return await signIn(email: normalizedEmail, password: normalizedPassword);
      } on FirebaseAuthException catch (signInError) {
        // If sign-in also fails, inform the user to use login.
        if (signInError.code == 'wrong-password' ||
            signInError.code == 'invalid-credential') {
          throw FirebaseAuthException(
            code: 'email-in-use-use-login',
            message: 'This email is already registered. Please log in.',
          );
        }
        rethrow;
      }
    }
  }


  // Signs out the currently authenticated user.
  Future<void> signOut() {
    return _auth.signOut();
  }
}
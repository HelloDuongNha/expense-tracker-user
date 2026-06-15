import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Service for managing settings/account operations: password change, logout.
class SettingsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _rootRef = FirebaseDatabase.instance.ref();

  // Reauthenticates the user and updates their password.
  Future<void> changePassword(String oldPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user found');
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  // Signs out the current user.
  Future<void> logout() {
    return _auth.signOut();
  }

  // Removes current user project memberships and clears favorite projects.
  Future<void> resetDatabaseForCurrentUser() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    String uid = user.uid;
    Map<String, Object?> updates = <String, Object?>{
      'UserFavorites/$uid': null,
    };

    DataSnapshot snapshot = await _rootRef.child('AdminProjects').get();
    if (snapshot.value is Map) {
      Map<dynamic, dynamic> adminMap = snapshot.value as Map<dynamic, dynamic>;
      for (MapEntry<dynamic, dynamic> adminEntry in adminMap.entries) {
        dynamic adminUid = adminEntry.key;
        dynamic adminData = adminEntry.value;
        if (adminData is! Map || adminData['projects'] is! Map) {
          continue;
        }

        Map<dynamic, dynamic> projectsMap = adminData['projects'] as Map<dynamic, dynamic>;
        for (MapEntry<dynamic, dynamic> projectEntry in projectsMap.entries) {
          dynamic projectCode = projectEntry.key;
          dynamic projectData = projectEntry.value;
          if (projectData is! Map || projectData['participants'] is! Map) {
            continue;
          }

          Map<dynamic, dynamic> participants = projectData['participants'] as Map<dynamic, dynamic>;
          if (participants.containsKey(uid)) {
            updates['AdminProjects/$adminUid/projects/$projectCode/participants/$uid'] = null;
          }
        }
      }
    }

    await _rootRef.update(updates);
  }

  // Maps a Firebase auth error code to a user-friendly message.
  String mapAuthError(String code) {
    if (code == 'wrong-password' || code == 'invalid-credential') {
      return 'Current password is incorrect.';
    }
    if (code == 'weak-password') {
      return 'New password is too weak (min 6 chars).';
    }
    if (code == 'requires-recent-login') {
      return 'Please log out and log in again before changing your password.';
    }
    return 'Failed to change password. ($code)';
  }
}

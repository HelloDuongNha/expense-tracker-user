import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Manages favorite (pinned) projects stored in Firebase Realtime Database.
class FavoritesService {
  // Returns a database reference to the current user favorites node.
  static DatabaseReference _userFavRef() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return FirebaseDatabase.instance.ref('UserFavorites/$uid');
  }

  // Loads all favorite project keys for the current user from Firebase.
  static Future<Set<String>> loadFavorites() async {
    try {
      DataSnapshot snapshot = await _userFavRef().get();
      if (snapshot.value is Map) {
        Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        // Build a set of favorite keys using a for loop.
        Set<String> favoriteKeys = {};
        for (dynamic key in map.keys) {
          favoriteKeys.add(key.toString());
        }
        return favoriteKeys;
      }
    } catch (_) {
      // Silently handle errors and return empty set.
    }
    return {};
  }

  // Toggles a project as favorite: adds if not present, removes if present.
  static Future<Set<String>> toggleFavorite(String projectKey, Set<String> current) async {
    Set<String> updated = Set<String>.from(current);
    try {
      if (updated.contains(projectKey)) {
        // Remove the project from favorites.
        await _userFavRef().child(projectKey).remove();
        updated.remove(projectKey);
      } else {
        // Add the project to favorites.
        await _userFavRef().child(projectKey).set(true);
        updated.add(projectKey);
      }
    } catch (_) {
      // Silently handle errors.
    }
    return updated;
  }

  // Builds a unique key for a project using admin UID and project code.
  static String projectKey(String adminUid, String projectCode) {
    return '${adminUid}_$projectCode';
  }
}

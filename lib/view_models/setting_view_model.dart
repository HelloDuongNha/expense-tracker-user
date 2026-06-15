import 'package:expense_user/services/settings_service.dart';
import 'package:flutter/foundation.dart';

// ViewModel for the settings screen: manages account operations and preferences.
class SettingViewModel extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _isChangingPassword = false;
  bool _isResettingDatabase = false;
  String? _errorMessage;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get isChangingPassword => _isChangingPassword;
  bool get isResettingDatabase => _isResettingDatabase;
  String? get errorMessage => _errorMessage;

  // Toggles notifications preference.
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  // Toggles dark mode preference.
  void toggleDarkMode() {
    _darkModeEnabled = !_darkModeEnabled;
    notifyListeners();
  }

  // Changes the user's password after validation.
  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    // Validate inputs.
    if (oldPassword.isEmpty) {
      _errorMessage = 'Current password is required';
      notifyListeners();
      return;
    }

    if (newPassword.isEmpty) {
      _errorMessage = 'New password is required';
      notifyListeners();
      return;
    }

    if (newPassword.length < 6) {
      _errorMessage = 'New password must be at least 6 characters';
      notifyListeners();
      return;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return;
    }

    try {
      _isChangingPassword = true;
      _errorMessage = null;
      notifyListeners();

      await _settingsService.changePassword(oldPassword, newPassword);

      _isChangingPassword = false;
      notifyListeners();
    } catch (e) {
      _isChangingPassword = false;

      if (e is FirebaseAuthException) {
        _errorMessage = _settingsService.mapAuthError(e.code);
      } else {
        _errorMessage = e.toString();
      }

      notifyListeners();
      rethrow;
    }
  }

  // Clears current user's joined project links and favorites.
  Future<void> resetDatabase() async {
    try {
      _isResettingDatabase = true;
      _errorMessage = null;
      notifyListeners();

      await _settingsService.resetDatabaseForCurrentUser();

      _isResettingDatabase = false;
      notifyListeners();
    } catch (e) {
      _isResettingDatabase = false;
      _errorMessage = 'Failed to reset database';
      notifyListeners();
      rethrow;
    }
  }

  // Logs out the current user.
  Future<void> logout() async {
    try {
      await _settingsService.logout();
    } catch (e) {
      _errorMessage = 'Failed to log out';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Dummy FirebaseAuthException for reference since we're catching the actual exception.
class FirebaseAuthException implements Exception {
  final String code;
  final String? message;

  FirebaseAuthException({required this.code, this.message});

  @override
  String toString() => message ?? 'FirebaseAuthException: $code';
}

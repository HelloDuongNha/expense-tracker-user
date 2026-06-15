import 'package:expense_user/services/expense_service.dart';
import 'package:expense_user/services/location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ViewModel for the add expense screen: manages form state, validation, and saving.
class ExpenseFormViewModel extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final LocationService _locationService = LocationService();

  final String projectCode;
  final String adminUid;

  // Form state
  String _currency = 'USD';
  String _expenseType = 'Travel';
  String _paymentMethod = 'Cash';
  String _paymentStatus = 'Paid';

  bool _isSaving = false;
  bool _isFetchingLocation = false;
  String? _errorMessage;

  // Dropdowns and lists
  static const List<String> currencies = ['USD', 'EUR', 'VND'];
  static const List<String> categories = ['Travel', 'Food', 'Hotel', 'Transport', 'Office', 'Other'];
  static const List<String> methods = ['Cash', 'Bank Transfer', 'Credit Card', 'Debit Card', 'E-Wallet'];

  ExpenseFormViewModel({
    required this.projectCode,
    required this.adminUid,
  });

  // Getters
  String get currency => _currency;
  String get expenseType => _expenseType;
  String get paymentMethod => _paymentMethod;
  String get paymentStatus => _paymentStatus;
  bool get isSaving => _isSaving;
  bool get isFetchingLocation => _isFetchingLocation;
  String? get errorMessage => _errorMessage;

  // Setters for dropdown selections
  void setCurrency(String value) {
    _currency = value;
    notifyListeners();
  }

  void setExpenseType(String value) {
    _expenseType = value;
    notifyListeners();
  }

  void setPaymentMethod(String value) {
    _paymentMethod = value;
    notifyListeners();
  }

  void setPaymentStatus(String value) {
    _paymentStatus = value;
    notifyListeners();
  }

  // Generates a unique expense ID from current timestamp.
  String generateExpenseId() {
    int value = DateTime.now().millisecondsSinceEpoch % 100000;
    return 'EXP-${value.toString().padLeft(5, '0')}';
  }

  // Returns display name or email of the current Firebase user.
  String getDefaultClaimantName() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return '';
    }
    String displayName = (user.displayName ?? '').trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }
    String email = (user.email ?? '').trim();
    if (email.isNotEmpty) {
      return email;
    }
    return '';
  }

  // Fetches the current device location.
  Future<String> fetchCurrentLocation() async {
    try {
      _isFetchingLocation = true;
      notifyListeners();

      final location = await _locationService.getCurrentLocation();
      String address = await _locationService.reverseGeocode(
        location.latitude,
        location.longitude,
      );

      _isFetchingLocation = false;
      notifyListeners();

      return address;
    } catch (e) {
      _isFetchingLocation = false;
      _errorMessage = 'Could not get location. Try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Saves the expense to Firebase.
  Future<void> saveExpense({
    required String expenseId,
    required double amount,
    required String expenseDate,
    required String claimant,
    required String description,
    required String location,
  }) async {
    if (expenseId.isEmpty ||
        amount <= 0 ||
        expenseDate.isEmpty ||
        claimant.isEmpty) {
      _errorMessage = 'Please fill in all required fields.';
      notifyListeners();
      return;
    }

    try {
      _isSaving = true;
      _errorMessage = null;
      notifyListeners();

      await _expenseService.saveExpense(
        adminUid: adminUid,
        expenseId: expenseId,
        projectCode: projectCode,
        amount: amount,
        currency: _currency,
        expenseDate: expenseDate,
        expenseType: _expenseType,
        paymentMethod: _paymentMethod,
        claimant: claimant,
        paymentStatus: _paymentStatus,
        description: description,
        location: location,
      );

      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'Failed to save expense.';
      notifyListeners();
      rethrow;
    }
  }

  // Validates the amount input.
  bool validateAmount(String amountStr) {
    double? amount = double.tryParse(amountStr.trim());
    return amount != null && amount > 0;
  }

  @override
  void dispose() {
    super.dispose();
  }
}



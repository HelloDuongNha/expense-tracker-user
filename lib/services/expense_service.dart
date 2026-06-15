import 'package:expense_user/models/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Service for managing expense operations: saving, fetching.
class ExpenseService {
  // Saves an expense to Firebase under the admin's account.
  Future<void> saveExpense({
    required String adminUid,
    required String expenseId,
    required String projectCode,
    required double amount,
    required String currency,
    required String expenseDate,
    required String expenseType,
    required String paymentMethod,
    required String claimant,
    required String paymentStatus,
    required String description,
    required String location,
  }) async {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      throw Exception('No user authenticated');
    }

    DatabaseReference expenseRef = FirebaseDatabase.instance.ref(
      'AdminProjects/$adminUid/expenses/$expenseId',
    );

    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> payload = {
      'expenseId': expenseId,
      'projectCode': projectCode,
      'amount': amount,
      'currency': currency,
      'expenseDate': expenseDate,
      'expenseType': expenseType,
      'paymentMethod': paymentMethod,
      'claimant': claimant,
      'paymentStatus': paymentStatus,
      'id': now % 100000,
      'isSynced': false,
      'updatedAt': now,
      'description': description,
      'location': location,
    };

    try {
      await expenseRef.set(payload);
    } catch (_) {
      throw Exception('Failed to save expense');
    }
  }

  // Fetches expenses for a specific project from Firebase.
  Future<List<ExpenseModel>> fetchProjectExpenses(
    String adminUid,
    String projectCode,
  ) async {
    try {
      DatabaseReference expensesRef = FirebaseDatabase.instance
          .ref('AdminProjects/$adminUid/expenses');

      DataSnapshot snapshot = await expensesRef.get();
      Map<dynamic, dynamic>? root = snapshot.value as Map<dynamic, dynamic>?;

      List<ExpenseModel> result = [];
      if (root == null) {
        return result;
      }

      for (MapEntry<dynamic, dynamic> entry in root.entries) {
        dynamic data = entry.value;
        if (data is! Map) {
          continue;
        }

        ExpenseModel expense = ExpenseModel.fromMap(
          Map<dynamic, dynamic>.from(data),
          entry.key.toString(),
        );

        if (expense.projectCode == projectCode) {
          result.add(expense);
        }
      }

      return result;
    } catch (_) {
      throw Exception('Failed to fetch expenses');
    }
  }

  // Stream of expenses for a specific project.
  Stream<List<ExpenseModel>> projectExpensesStream(
    String adminUid,
    String projectCode,
  ) {
    DatabaseReference expensesRef = FirebaseDatabase.instance
        .ref('AdminProjects/$adminUid/expenses');

    return expensesRef.onValue.map((DatabaseEvent event) {
      Map<dynamic, dynamic>? root = event.snapshot.value as Map<dynamic, dynamic>?;

      List<ExpenseModel> result = [];
      if (root == null) {
        return result;
      }

      for (MapEntry<dynamic, dynamic> entry in root.entries) {
        dynamic data = entry.value;
        if (data is! Map) {
          continue;
        }

        ExpenseModel expense = ExpenseModel.fromMap(
          Map<dynamic, dynamic>.from(data),
          entry.key.toString(),
        );

        if (expense.projectCode == projectCode) {
          result.add(expense);
        }
      }

      return result;
    });
  }
}


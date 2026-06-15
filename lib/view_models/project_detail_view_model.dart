import 'package:expense_user/models/expense_model.dart';
import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/services/expense_service.dart';
import 'package:expense_user/services/project_service.dart';
import 'package:flutter/foundation.dart';

// ViewModel for the project detail screen: manages expenses, sorting, and leave project.
class ProjectDetailViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final ExpenseService _expenseService = ExpenseService();

  final ProjectModel project;

  List<ExpenseModel> _expenses = [];
  bool _sortNewestFirst = true;
  bool _isLeavingProject = false;
  bool _isLoadingExpenses = true;

  ProjectDetailViewModel({required this.project});

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  bool get sortNewestFirst => _sortNewestFirst;
  bool get isLeavingProject => _isLeavingProject;
  bool get isLoadingExpenses => _isLoadingExpenses;

  // Initializes the viewmodel: listens to expenses.
  void initialize() {
    _listenToExpenses();
  }

  // Listens to Firebase expense changes.
  void _listenToExpenses() {
    _expenseService.projectExpensesStream(project.adminUid, project.projectCode).listen(
      (List<ExpenseModel> loadedExpenses) {
        _expenses = loadedExpenses;
        _isLoadingExpenses = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingExpenses = false;
        notifyListeners();
      },
    );
  }

  // Toggles the sort order between newest first and oldest first.
  void toggleSortOrder() {
    _sortNewestFirst = !_sortNewestFirst;
    notifyListeners();
  }

  // Sorts expenses by updatedAt timestamp based on current sort direction.
  List<ExpenseModel> getSortedExpenses() {
    List<ExpenseModel> sorted = List<ExpenseModel>.from(_expenses);
    sorted.sort((ExpenseModel a, ExpenseModel b) {
      if (_sortNewestFirst) {
        // Newest first: higher timestamp comes first.
        return b.updatedAt.compareTo(a.updatedAt);
      } else {
        // Oldest first: lower timestamp comes first.
        return a.updatedAt.compareTo(b.updatedAt);
      }
    });
    return sorted;
  }

  // Calculates the total spent and remaining budget.
  ({double totalSpent, double remaining}) calculateBudget() {
    double totalSpent = 0;
    for (int i = 0; i < _expenses.length; i++) {
      totalSpent = totalSpent + _expenses[i].amount;
    }
    double remaining = project.budget - totalSpent;
    return (totalSpent: totalSpent, remaining: remaining);
  }

  // Removes the current user from this project.
  Future<void> leaveProject() async {
    try {
      _isLeavingProject = true;
      notifyListeners();

      await _projectService.leaveProject(project.adminUid, project.projectCode);

      _isLeavingProject = false;
      notifyListeners();
    } catch (e) {
      _isLeavingProject = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}


import 'package:expense_user/app_colors.dart';
import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/view_models/project_detail_view_model.dart';
import 'package:expense_user/views/expense/add_expense_screen.dart';
import 'package:expense_user/views/expense/expense_card.dart';
import 'package:expense_user/views/expense/expense_details_sheet.dart';
import 'package:expense_user/views/project/project_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Screen showing project details and its expense list.
class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() {
    return _ProjectDetailScreenState();
  }
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late ProjectDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProjectDetailViewModel(project: widget.project);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Ask the user to confirm leaving the current project.
  Future<bool> _showLeaveProjectDialog() async {
    bool? shouldLeave = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Leave Project'),
          content: const Text('Do you want to leave this project?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    if (shouldLeave == true) {
      return true;
    }
    return false;
  }

  // Remove current user from this project.
  Future<void> _leaveProject() async {
    bool shouldLeave = await _showLeaveProjectDialog();
    if (!shouldLeave) {
      return;
    }

    try {
      await _viewModel.leaveProject();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You left this project.')),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to leave project.')),
        );
      }
    }
  }

  // Builds the main screen layout with Provider.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectDetailViewModel>.value(
      value: _viewModel,
      child: Consumer<ProjectDetailViewModel>(
        builder: (BuildContext context, ProjectDetailViewModel vm, Widget? child) {
          return Scaffold(
            backgroundColor: AppColors.screenBackground,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
              title: Text(widget.project.projectCode),
              leading: const BackButton(),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'details') {
                      showProjectDetailsSheet(context, widget.project);
                    }
                    if (value == 'leave') {
                      _leaveProject();
                    }
                  },
                  itemBuilder: (BuildContext popupContext) {
                    return <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'details',
                        child: Text('View this project details'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'leave',
                        child: Text(
                          'Leave this project',
                          style: TextStyle(color: AppColors.errorRed),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: vm.isLoadingExpenses
                ? const Center(child: CircularProgressIndicator())
                : _buildBodyContent(vm),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext routeContext) {
                      return AddExpenseScreen(
                        projectCode: widget.project.projectCode,
                        adminUid: widget.project.adminUid,
                      );
                    },
                  ),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(ProjectDetailViewModel vm) {
    final sortedExpenses = vm.getSortedExpenses();
    final budget = vm.calculateBudget();

    // Build the expense list content widget.
    Widget expenseListWidget;
    if (sortedExpenses.isEmpty) {
      expenseListWidget = const Center(child: Text('No expenses for this project.'));
    } else {
      expenseListWidget = ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 96),
        itemCount: sortedExpenses.length,
        itemBuilder: (BuildContext context, int index) {
          var expense = sortedExpenses[index];
          return ExpenseCard(
            expense: expense,
            onTap: () {
              showExpenseDetailsSheet(context, expense);
            },
          );
        },
      );
    }

    return Column(
      children: [
        _ProjectSummaryCard(
          project: widget.project,
          remainingBudget: budget.remaining,
        ),
        // Header row with "Project Expense" title and sort toggle button.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Project Expense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Animated sort toggle button.
              GestureDetector(
                onTap: () {
                  _viewModel.toggleSortOrder();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedRotation(
                    turns: _viewModel.sortNewestFirst ? 0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: const Icon(
                      Icons.arrow_upward,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: expenseListWidget),
      ],
    );
  }
}

// Private widget showing the project summary card with budget information.
class _ProjectSummaryCard extends StatelessWidget {
  final ProjectModel project;
  final double remainingBudget;

  const _ProjectSummaryCard({
    required this.project,
    required this.remainingBudget,
  });

  // Builds the project summary card layout.
  @override
  Widget build(BuildContext context) {
    NumberFormat format = NumberFormat('#,##0.00');

    // Determine remaining budget color.
    Color remainingColor;
    if (remainingBudget < 0) {
      remainingColor = AppColors.errorRed;
    } else {
      remainingColor = AppColors.successGreenDark;
    }

    // Determine owner display text.
    String ownerText;
    if (project.owner.trim().isEmpty) {
      ownerText = project.adminUid;
    } else {
      ownerText = project.owner;
    }

    // Determine project display name.
    String displayName;
    if (project.projectName.isEmpty) {
      displayName = project.projectCode;
    } else {
      displayName = project.projectName;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project icon, name, and owner row.
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueLight,
                ),
                child: const Icon(
                  Icons.folder_outlined,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ownerText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.slateGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Budget metrics row.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.screenBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BudgetMetric(
                    label: 'Total Budget',
                    value: '\$${format.format(project.budget)}',
                    color: AppColors.textDark,
                  ),
                ),
                Container(width: 1, height: 38, color: AppColors.borderLight),
                Expanded(
                  child: _BudgetMetric(
                    label: 'Budget Remaining',
                    value: '\$${format.format(remainingBudget)}',
                    color: remainingColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Private widget showing a single budget metric (label and value).
class _BudgetMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BudgetMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  // Builds the budget metric display.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.slateGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


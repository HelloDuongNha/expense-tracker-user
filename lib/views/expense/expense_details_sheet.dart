import 'package:expense_user/app_colors.dart';
import 'package:expense_user/models/expense_model.dart';
import 'package:expense_user/widgets/detail_info_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Shows a bottom sheet with full expense details.
void showExpenseDetailsSheet(BuildContext context, ExpenseModel expense) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      // Add extra bottom padding to clear system navigation bar.
      double bottomPadding = MediaQuery.of(sheetContext).padding.bottom + 40;

      return FractionallySizedBox(
        heightFactor: 0.88,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.screenBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle.
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title row with close button.
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Expense ${expense.expenseId}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Scrollable detail rows.
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: 8,
                      left: 0,
                      right: 0,
                      bottom: bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Expense ID',
                          value: expense.expenseId,
                        ),
                        DetailInfoRow(
                          icon: Icons.folder_outlined,
                          label: 'Project Code',
                          value: expense.projectCode,
                        ),
                        DetailInfoRow(
                          icon: Icons.category_outlined,
                          label: 'Expense Type',
                          value: expense.expenseType,
                        ),
                        DetailInfoRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Amount',
                          value:
                              '${expense.currency} ${NumberFormat('#,##0.00').format(expense.amount)}',
                        ),
                        DetailInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: expense.expenseDate,
                        ),
                        DetailInfoRow(
                          icon: Icons.payments_outlined,
                          label: 'Method',
                          value: expense.paymentMethod,
                        ),
                        DetailInfoRow(
                          icon: Icons.place_outlined,
                          label: 'Location',
                          value: expense.location,
                        ),
                        DetailInfoRow(
                          icon: Icons.person_outline,
                          label: 'Claimant',
                          value: expense.claimant,
                        ),
                        DetailInfoRow(
                          icon: Icons.flag_outlined,
                          label: 'Status',
                          value: expense.paymentStatus,
                        ),
                        DetailInfoRow(
                          icon: Icons.description_outlined,
                          label: 'Description',
                          value: expense.description,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


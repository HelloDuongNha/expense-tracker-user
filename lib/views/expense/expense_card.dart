import 'package:expense_user/app_colors.dart';
import 'package:expense_user/models/expense_model.dart';
import 'package:expense_user/widgets/icon_detail_row.dart';
import 'package:expense_user/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Single expense card for use in expense lists.
class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  // Build the expense card layout.
  @override
  Widget build(BuildContext context) {
    NumberFormat amountFormat = NumberFormat('#,##0.00');
    (Color, Color) statusColors = _paymentStatusColors(expense.paymentStatus);

    // Resolve display text with fallbacks.
    String expenseTypeText = _fallback(expense.expenseType);
    String paymentMethodText = _fallback(expense.paymentMethod);
    String dateText = _fallback(expense.expenseDate);
    String locationText = _fallback(expense.location);
    String claimantText = _fallback(expense.claimant);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: expense ID, project code, and payment status badge.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          children: [
                            TextSpan(
                              text: expense.expenseId,
                              style: const TextStyle(color: AppColors.slateGray),
                            ),
                            const TextSpan(
                              text: '  •  ',
                              style: TextStyle(color: AppColors.slateGray),
                            ),
                            TextSpan(
                              text: expense.projectCode,
                              style: const TextStyle(color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StatusBadge(
                      text: expense.paymentStatus,
                      backgroundColor: statusColors.$1,
                      textColor: statusColors.$2,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Expense type title.
                Text(
                  expenseTypeText,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // Detail rows: category, date, location, claimant.
                IconDetailRow(
                  icon: _categoryIcon(expense.expenseType),
                  text: '$expenseTypeText • $paymentMethodText',
                ),
                const SizedBox(height: 8),
                IconDetailRow(icon: Icons.calendar_today, text: dateText),
                const SizedBox(height: 8),
                IconDetailRow(icon: Icons.place, text: locationText),
                const SizedBox(height: 8),
                IconDetailRow(icon: Icons.person, text: claimantText),
                const SizedBox(height: 14),

                // Footer: divider and total amount.
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 14),
                Text(
                  '${expense.currency} ${amountFormat.format(expense.amount)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Return '-' when the value is empty, otherwise return the value itself.
  String _fallback(String value) {
    if (value.isEmpty) {
      return '-';
    }
    return value;
  }

  // Map expense type string to a category icon.
  IconData _categoryIcon(String expenseType) {
    String category = expenseType.toLowerCase();

    // Travel or flight expenses.
    if (category.contains('travel') || category.contains('flight')) {
      return Icons.flight;
    }
    // Meal or food expenses.
    if (category.contains('meal') || category.contains('food')) {
      return Icons.restaurant;
    }
    // Hotel or accommodation expenses.
    if (category.contains('hotel') || category.contains('stay')) {
      return Icons.hotel;
    }
    // Ground transportation expenses.
    if (category.contains('transport')) {
      return Icons.directions_car;
    }
    // Default fallback icon.
    return Icons.label;
  }

  // Resolve background and text colors for a payment status.
  (Color, Color) _paymentStatusColors(String status) {
    String normalized = status.toLowerCase();

    // Approved or paid → green badge.
    if (normalized == 'approved' || normalized == 'paid') {
      return (AppColors.successGreenLight, AppColors.successGreenText);
    }
    // Rejected → red badge.
    if (normalized == 'rejected') {
      return (AppColors.errorRedLight, AppColors.errorRedText);
    }
    // Pending or any other status → amber badge.
    return (AppColors.warningAmberLight, AppColors.textDark);
  }
}

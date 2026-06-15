import 'package:flutter/material.dart';
import 'package:expense_user/app_colors.dart';

// Reusable toggle button for selecting a status option (e.g. payment status, filter status).
class StatusToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const StatusToggleButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the border color based on selection state.
    Color borderColor;
    if (selected) {
      borderColor = AppColors.primaryBlue;
    } else {
      borderColor = AppColors.borderDefault;
    }

    // Determine the background color based on selection state.
    Color backgroundColor;
    if (selected) {
      backgroundColor = AppColors.blueLight;
    } else {
      backgroundColor = Colors.white;
    }

    // Determine the text color based on selection state.
    Color textColor;
    if (selected) {
      textColor = AppColors.primaryBlue;
    } else {
      textColor = AppColors.textSecondary;
    }

    return SizedBox(
      height: 42,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:expense_user/app_colors.dart';

// Reusable row with a small icon and text, used in project and expense cards.
class IconDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconDetailRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.slateGray),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.slateGray,
            ),
          ),
        ),
      ],
    );
  }
}

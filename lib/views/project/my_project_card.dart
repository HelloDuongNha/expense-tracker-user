import 'package:expense_user/app_colors.dart';
import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/widgets/icon_detail_row.dart';
import 'package:expense_user/widgets/project_helpers.dart';
import 'package:expense_user/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Card widget for displaying a project in the My Projects list with favorite support.
class MyProjectCard extends StatelessWidget {
  final ProjectModel project;
  final double remainingBudget;
  final bool isFavorited;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const MyProjectCard({
    super.key,
    required this.project,
    required this.remainingBudget,
    required this.isFavorited,
    this.onTap,
    this.onFavoriteToggle,
  });

  // Builds the project card layout.
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat('#,##0.00');
    Color statusColor = getStatusColor(project.status);

    // Determine lock icon based on project lock state.
    IconData lockIcon;
    if (project.isLocked) {
      lockIcon = Icons.lock;
    } else {
      lockIcon = Icons.lock_open;
    }

    // Determine description text with fallback.
    String descriptionText;
    if (project.description.isEmpty) {
      descriptionText = '-';
    } else {
      descriptionText = project.description;
    }

    // Determine owner text with fallback.
    String ownerText;
    if (project.owner.isEmpty) {
      ownerText = '-';
    } else {
      ownerText = project.owner;
    }

    // Determine remaining budget color.
    Color remainingColor;
    if (remainingBudget > 0) {
      remainingColor = AppColors.successGreen;
    } else {
      remainingColor = AppColors.errorRed;
    }

    // Determine favorite icon and color.
    IconData favoriteIcon;
    Color favoriteColor;
    if (isFavorited) {
      favoriteIcon = Icons.favorite;
      favoriteColor = AppColors.favoritePink;
    } else {
      favoriteIcon = Icons.favorite_border;
      favoriteColor = AppColors.slateGray;
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: project code, lock icon, and status badge.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.projectCode,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          lockIcon,
                          size: 16,
                          color: AppColors.slateGray,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    text: project.status,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    textColor: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Body: name, description, date range, and owner.
              Text(
                project.projectName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descriptionText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              IconDetailRow(
                icon: Icons.calendar_today,
                text: formatDateRange(project.startDate, project.endDate),
              ),
              const SizedBox(height: 6),
              IconDetailRow(
                icon: Icons.person,
                text: ownerText,
              ),

              // Divider and footer section.
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 12),

              // Footer: budget information and favorite toggle.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${project.budgetCurrency} ${numberFormat.format(project.budget)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Remaining: ${project.budgetCurrency} ${numberFormat.format(remainingBudget)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: remainingColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      favoriteIcon,
                      color: favoriteColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


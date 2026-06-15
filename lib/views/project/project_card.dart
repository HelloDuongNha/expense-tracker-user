import 'package:expense_user/app_colors.dart';
import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/widgets/icon_detail_row.dart';
import 'package:expense_user/widgets/project_helpers.dart';
import 'package:expense_user/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Card widget for displaying a project in the Join Projects list.
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final bool showJoinedBadge;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.showJoinedBadge = false,
  });

  // Build the project card layout.
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat('#,##0.00');
    Color statusColor = getStatusColor(project.status);

    // Determine the lock icon based on project password state.
    IconData lockIcon;
    if (project.isLocked) {
      lockIcon = Icons.lock;
    } else {
      lockIcon = Icons.lock_open;
    }

    // Determine the description text.
    String descriptionText;
    if (project.description.isEmpty) {
      descriptionText = '-';
    } else {
      descriptionText = project.description;
    }

    // Determine the owner text.
    String ownerText;
    if (project.owner.isEmpty) {
      ownerText = '-';
    } else {
      ownerText = project.owner;
    }

    // Build the header badge list.
    List<Widget> headerBadges = [];
    if (showJoinedBadge) {
      headerBadges.add(const SizedBox(width: 8));
      headerBadges.add(
        const StatusBadge(
          text: 'Joined',
          backgroundColor: AppColors.successGreenLight,
          textColor: AppColors.successGreenText,
        ),
      );
    }
    headerBadges.add(const SizedBox(width: 8));
    headerBadges.add(
      StatusBadge(
        text: project.status,
        backgroundColor: statusColor.withValues(alpha: 0.12),
        textColor: statusColor,
      ),
    );

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: project code, lock icon, and status badges.
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
                  ...headerBadges,
                ],
              ),
              const SizedBox(height: 10),
              // Project name.
              Text(
                project.projectName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // Project description.
              Text(
                descriptionText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // Date range row.
              IconDetailRow(
                icon: Icons.calendar_today,
                text: formatDateRange(project.startDate, project.endDate),
              ),
              const SizedBox(height: 6),
              // Owner row.
              IconDetailRow(
                icon: Icons.person,
                text: ownerText,
              ),
              const SizedBox(height: 6),
              // Budget row.
              IconDetailRow(
                icon: Icons.payments_outlined,
                text: '${project.budgetCurrency} ${numberFormat.format(project.budget)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

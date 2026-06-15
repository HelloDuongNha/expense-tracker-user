import 'package:flutter/material.dart';
import 'package:expense_user/app_colors.dart';
import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/views/project/widgets/project_filter_criteria.dart';
import 'package:intl/intl.dart';

// Returns the themed color for a given project status string.
Color getStatusColor(String status) {
  String normalized = status.toLowerCase();
  if (normalized == 'active') {
    return AppColors.successGreen;
  }
  if (normalized == 'on hold') {
    return AppColors.warningAmber;
  }
  if (normalized == 'closed') {
    return AppColors.errorRed;
  }
  return AppColors.textSecondary;
}

// Formats a start date and end date into a single display string.
String formatDateRange(String startDate, String endDate) {
  String start = startDate.trim();
  String end = endDate.trim();

  if (start.isEmpty && end.isEmpty) {
    return '-';
  }
  if (start.isEmpty) {
    return end;
  }
  if (end.isEmpty) {
    return start;
  }
  return '$start - $end';
}

// Filters a list of projects by keyword text and advanced filter criteria.
List<ProjectModel> filterProjects({
  required List<ProjectModel> projects,
  required String keyword,
  required ProjectFilterCriteria criteria,
}) {
  List<ProjectModel> results = [];

  for (int i = 0; i < projects.length; i++) {
    ProjectModel project = projects[i];
    bool shouldInclude = true;

    // Check keyword match against project code, name, and description.
    String trimmedKeyword = keyword.trim().toLowerCase();
    if (trimmedKeyword.isNotEmpty) {
      String id = project.projectCode.toLowerCase();
      String name = project.projectName.toLowerCase();
      String description = project.description.toLowerCase();
      bool matchesKeyword = id.contains(trimmedKeyword) ||
          name.contains(trimmedKeyword) ||
          description.contains(trimmedKeyword);
      if (!matchesKeyword) {
        shouldInclude = false;
      }
    }

    // Check date filter against start and end dates.
    if (shouldInclude) {
      String dateFilter = criteria.date.trim();
      if (dateFilter.isNotEmpty) {
        // Parse a date string using common formats. Returns null if unparsable.
        DateTime? tryParseDate(String input) {
          String s = input.trim();
          if (s.isEmpty) return null;
          // Try dd/MM/yyyy first (used by the date picker in the UI).
          try {
            return DateFormat('dd/MM/yyyy').parseStrict(s);
          } catch (_) {}
          // Try ISO-like yyyy-MM-dd
          try {
            return DateFormat('yyyy-MM-dd').parseStrict(s);
          } catch (_) {}
          // Fallback to DateTime.parse which handles many ISO variants.
          try {
            return DateTime.parse(s);
          } catch (_) {}
          return null;
        }

        DateTime? selected = tryParseDate(dateFilter);
        if (selected == null) {
          // If we can't parse the selected date, skip date filtering.
        } else {
          // Normalize to date-only for comparisons.
          DateTime selectedDate = DateTime(selected.year, selected.month, selected.day);

          DateTime? start = tryParseDate(project.startDate);
          DateTime? end = tryParseDate(project.endDate);

          bool matchesDate = false;

          if (start == null && end == null) {
            // Project has no date range -> don't match when user filters by date.
            matchesDate = false;
          } else if (start == null && end != null) {
            DateTime endDate = DateTime(end.year, end.month, end.day);
            matchesDate = !selectedDate.isAfter(endDate);
          } else if (start != null && end == null) {
            DateTime startDate = DateTime(start.year, start.month, start.day);
            matchesDate = !selectedDate.isBefore(startDate);
          } else {
            DateTime startDate = DateTime(start!.year, start.month, start.day);
            DateTime endDate = DateTime(end!.year, end.month, end.day);
            matchesDate = !(selectedDate.isBefore(startDate) || selectedDate.isAfter(endDate));
          }

          if (!matchesDate) {
            shouldInclude = false;
          }
        }
      }
    }

    // Check status filter against project status.
    if (shouldInclude) {
      String statusFilter = criteria.status.trim().toLowerCase();
      if (statusFilter.isNotEmpty) {
        String currentStatus = project.status.trim().toLowerCase();
        bool matchesStatus = currentStatus == statusFilter ||
            (statusFilter == 'completed' && currentStatus == 'closed');
        if (!matchesStatus) {
          shouldInclude = false;
        }
      }
    }

    // Check owner filter against project owner.
    if (shouldInclude) {
      String ownerFilter = criteria.owner.trim().toLowerCase();
      if (ownerFilter.isNotEmpty) {
        if (!project.owner.toLowerCase().contains(ownerFilter)) {
          shouldInclude = false;
        }
      }
    }

    // Add the project to results if all filters pass.
    if (shouldInclude) {
      results.add(project);
    }
  }

  return results;
}

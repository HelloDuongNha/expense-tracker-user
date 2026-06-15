import 'package:expense_user/app_colors.dart';
import 'package:expense_user/views/project/widgets/project_filter_criteria.dart';
import 'package:expense_user/widgets/status_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Dialog that lets the user set advanced filters for project search.
class ProjectFilterDialog extends StatefulWidget {
  final ProjectFilterCriteria initialCriteria;

  const ProjectFilterDialog({
    super.key,
    required this.initialCriteria,
  });

  @override
  State<ProjectFilterDialog> createState() {
    return _ProjectFilterDialogState();
  }
}

class _ProjectFilterDialogState extends State<ProjectFilterDialog> {
  late final TextEditingController _dateController;
  late final TextEditingController _ownerController;
  String _status = '';

  // Initialize controllers with existing criteria values.
  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing criteria values.
    _dateController = TextEditingController(text: widget.initialCriteria.date);
    _ownerController = TextEditingController(text: widget.initialCriteria.owner);
    _status = widget.initialCriteria.status;
  }

  // Release text controllers.
  @override
  void dispose() {
    _dateController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  // Opens a date picker and sets the selected date in the date field.
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }
    _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
  }

  // Builds the standard input decoration for form fields.
  InputDecoration _fieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.slateGray),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1),
      ),
    );
  }

  // Applies the filter and returns the criteria to the caller.
  void _applyFilter() {
    Navigator.of(context).pop(
      ProjectFilterCriteria(
        date: _dateController.text.trim(),
        status: _status,
        owner: _ownerController.text.trim(),
      ),
    );
  }

  // Clears the current filter inputs in the dialog.
  void _clearFilters() {
    setState(() {
      _dateController.text = '';
      _ownerController.text = '';
      _status = '';
    });
  }

  // Toggles a status filter value: selects it if not selected, clears if already selected.
  void _toggleStatus(String value) {
    setState(() {
      if (_status == value) {
        _status = '';
      } else {
        _status = value;
      }
    });
  }

  // Build the filter dialog layout.
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: AppColors.screenBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with clear action immediately to the right of the title.
            Row(
              children: [
                const Text(
                  'Advanced Search',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: _clearFilters,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date filter label.
            const Text(
              'Date',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            // Date picker field.
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: _fieldDecoration(
                'dd/MM/yyyy',
                suffixIcon: IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Status filter label.
            const Text(
              'Status',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            // Status toggle buttons row using the shared StatusToggleButton widget.
            Row(
              children: [
                Expanded(
                  child: StatusToggleButton(
                    label: 'Active',
                    selected: _status == 'Active',
                    onTap: () {
                      _toggleStatus('Active');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatusToggleButton(
                    label: 'On Hold',
                    selected: _status == 'On Hold',
                    onTap: () {
                      _toggleStatus('On Hold');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatusToggleButton(
                    label: 'Completed',
                    selected: _status == 'Completed',
                    onTap: () {
                      _toggleStatus('Completed');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Owner filter label.
            const Text(
              'Owner Name',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            // Owner text field.
            TextField(
              controller: _ownerController,
              decoration: _fieldDecoration('Owner Name'),
            ),
            const SizedBox(height: 16),
            // Apply filter button.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Search'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

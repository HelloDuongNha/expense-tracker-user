import 'package:expense_user/app_colors.dart';
import 'package:flutter/material.dart';

// Reusable search bar with a clear button and a filter icon for project screens.
class ProjectSearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const ProjectSearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  State<ProjectSearchBarWidget> createState() {
    return _ProjectSearchBarWidgetState();
  }
}

class _ProjectSearchBarWidgetState extends State<ProjectSearchBarWidget> {
  bool _hasText = false;

  // Set up text state and attach change listener.
  @override
  void initState() {
    super.initState();
    // Initialize the text state based on the controller content.
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  // Remove the text change listener.
  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  // Updates the clear icon visibility when the text changes.
  void _onTextChanged() {
    bool hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  // Clears the search field and notifies the parent widget.
  void _clearSearch() {
    widget.controller.clear();
    widget.onChanged('');
  }

  // Build the search bar layout.
  @override
  Widget build(BuildContext context) {
    // Build the list of trailing icons.
    List<Widget> trailingWidgets = [];

    // Show clear icon only when there is text in the field.
    if (_hasText) {
      trailingWidgets.add(
        IconButton(
          onPressed: _clearSearch,
          icon: const Icon(Icons.close, color: AppColors.slateGray, size: 20),
        ),
      );
    }

    // Vertical divider separator.
    trailingWidgets.add(
      Container(
        width: 1,
        height: 24,
        color: AppColors.borderLight,
      ),
    );

    // Filter icon button.
    trailingWidgets.add(
      IconButton(
        onPressed: widget.onFilterTap,
        icon: const Icon(Icons.filter_alt_outlined, color: AppColors.primaryBlue),
      ),
    );

    return Container(
      height: 56,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.slateGray),
          const SizedBox(width: 8),
          // Search text input.
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search by ID, name, description...',
                hintStyle: TextStyle(color: AppColors.slateGray),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          // Trailing action icons.
          ...trailingWidgets,
        ],
      ),
    );
  }
}

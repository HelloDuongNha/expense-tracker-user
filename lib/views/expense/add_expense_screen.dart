import 'package:expense_user/app_colors.dart';
import 'package:expense_user/view_models/expense_form_view_model.dart';
import 'package:expense_user/widgets/status_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Form screen for creating a new expense entry.
class AddExpenseScreen extends StatefulWidget {
  final String projectCode;
  final String adminUid;

  const AddExpenseScreen({
    super.key,
    required this.projectCode,
    required this.adminUid,
  });

  @override
  State<AddExpenseScreen> createState() {
    return _AddExpenseScreenState();
  }
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late ExpenseFormViewModel _viewModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _claimantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ExpenseFormViewModel(
      projectCode: widget.projectCode,
      adminUid: widget.adminUid,
    );

    // Pre-fill form fields with defaults.
    _expenseIdController.text = _viewModel.generateExpenseId();
    _claimantController.text = _viewModel.getDefaultClaimantName();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _expenseIdController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _claimantController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // Open date picker and update the date field.
  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }
    _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
  }

  // Fetch device GPS location via ViewModel.
  Future<void> _fetchCurrentLocation() async {
    try {
      String address = await _viewModel.fetchCurrentLocation();
      if (mounted) {
        _locationController.text = address;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_viewModel.errorMessage ?? 'Location error')),
        );
      }
    }
  }

  // Validate form and save the expense via ViewModel.
  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? parsedAmount = double.tryParse(_amountController.text.trim());
    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0.')),
      );
      return;
    }

    try {
      await _viewModel.saveExpense(
        expenseId: _expenseIdController.text.trim(),
        amount: parsedAmount,
        expenseDate: _dateController.text.trim(),
        claimant: _claimantController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_viewModel.errorMessage ?? 'Failed to save expense.')),
        );
      }
    }
  }

  // Build dropdown menu items from a string list.
  List<DropdownMenuItem<String>> _buildDropdownItems(List<String> items) {
    List<DropdownMenuItem<String>> menuItems = [];
    for (int i = 0; i < items.length; i++) {
      menuItems.add(DropdownMenuItem<String>(
        value: items[i],
        child: Text(items[i]),
      ));
    }
    return menuItems;
  }

  // Standard input decoration for form fields.
  InputDecoration _fieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
      ),
    );
  }

  // Styled label for a form section.
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  // Builds the main form UI.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpenseFormViewModel>.value(
      value: _viewModel,
      child: Consumer<ExpenseFormViewModel>(
        builder: (BuildContext context, ExpenseFormViewModel vm, Widget? child) {
          // Resolve location suffix icon state.
          Widget locationSuffixIcon;
          if (vm.isFetchingLocation) {
            locationSuffixIcon = const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          } else {
            locationSuffixIcon = IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _fetchCurrentLocation,
              tooltip: 'Get current location',
            );
          }

          // Resolve save button state.
          Widget saveButtonChild;
          if (vm.isSaving) {
            saveButtonChild = const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            );
          } else {
            saveButtonChild = const Text(
              'Save Expense',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.screenBackground,
            appBar: AppBar(
              title: const Text('New Expense'),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppColors.textDark,
            ),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expense ID (read-only).
                      _sectionLabel('Expense ID *'),
                      TextFormField(
                        controller: _expenseIdController,
                        readOnly: true,
                        decoration: _fieldDecoration('Auto generated expense id'),
                      ),
                      const SizedBox(height: 12),

                      // Amount and currency row.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionLabel('Amount *'),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: _fieldDecoration('Enter value'),
                                  validator: (String? value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return 'Amount is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionLabel('Currency *'),
                                DropdownButtonFormField<String>(
                                  initialValue: vm.currency,
                                  decoration: _fieldDecoration('Currency'),
                                  items: _buildDropdownItems(ExpenseFormViewModel.currencies),
                                  onChanged: (String? value) {
                                    if (value == null) {
                                      return;
                                    }
                                    vm.setCurrency(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date of expense.
                      _sectionLabel('Date of Expense *'),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: _fieldDecoration(
                          'dd/MM/yyyy',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: _pickDate,
                          ),
                        ),
                        validator: (String? value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Date is required';
                          }
                          return null;
                        },
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 12),

                      // Expense type dropdown.
                      _sectionLabel('Type of Expense *'),
                      DropdownButtonFormField<String>(
                        initialValue: vm.expenseType,
                        decoration: _fieldDecoration('Select expense type'),
                        items: _buildDropdownItems(ExpenseFormViewModel.categories),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          vm.setExpenseType(value);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Payment method dropdown.
                      _sectionLabel('Payment Method *'),
                      DropdownButtonFormField<String>(
                        initialValue: vm.paymentMethod,
                        decoration: _fieldDecoration('Select method'),
                        items: _buildDropdownItems(ExpenseFormViewModel.methods),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          vm.setPaymentMethod(value);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Claimant field.
                      _sectionLabel('Claimant *'),
                      TextFormField(
                        controller: _claimantController,
                        decoration: _fieldDecoration('Enter person making the claim'),
                        validator: (String? value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Claimant is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Payment status toggle buttons.
                      _sectionLabel('Payment Status *'),
                      Row(
                        children: [
                          Expanded(
                            child: StatusToggleButton(
                              label: 'Paid',
                              selected: vm.paymentStatus == 'Paid',
                              onTap: () {
                                vm.setPaymentStatus('Paid');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatusToggleButton(
                              label: 'Pending',
                              selected: vm.paymentStatus == 'Pending',
                              onTap: () {
                                vm.setPaymentStatus('Pending');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatusToggleButton(
                              label: 'Reimbursed',
                              selected: vm.paymentStatus == 'Reimbursed',
                              onTap: () {
                                vm.setPaymentStatus('Reimbursed');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Optional description and location fields.
                      _sectionLabel('Description (Optional)'),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: _fieldDecoration('Add details about this expense...'),
                      ),
                      const SizedBox(height: 12),

                      // Location field (optional) with GPS fetch button.
                      _sectionLabel('Location (Optional)'),
                      TextFormField(
                        controller: _locationController,
                        maxLines: null,
                        minLines: 1,
                        decoration: _fieldDecoration(
                          'Enter location',
                          suffixIcon: locationSuffixIcon,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Sticky save button at the bottom.
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: vm.isSaving ? null : _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: saveButtonChild,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


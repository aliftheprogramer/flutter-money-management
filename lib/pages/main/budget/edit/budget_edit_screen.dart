import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/request/budget/budget_request.dart';
import 'package:money_management/models/response/budget/budget_response_by_id.dart';
import 'package:money_management/services/main/budget_services.dart';
import 'package:money_management/utils/custom_toast.dart';

class BudgetEditScreen extends StatefulWidget {
  final BudgetResponse budget;

  const BudgetEditScreen({Key? key, required this.budget}) : super(key: key);

  @override
  State<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends State<BudgetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger();

  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  late String _selectedPeriod;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  late BudgetServices _budgetServices;

  final List<String> _periods = ['daily', 'weekly', 'monthly'];

  final Map<String, String> _periodDisplayNames = {
    'daily': 'Harian',
    'weekly': 'Mingguan',
    'monthly': 'Bulanan',
  };

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing budget data
    _amountController = TextEditingController(
      text: widget.budget.amount.toString(),
    );
    _categoryController = TextEditingController(text: widget.budget.category);

    _startDate = widget.budget.startDate;
    _startDateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(widget.budget.startDate),
    );

    if (widget.budget.endDate != null) {
      _endDate = widget.budget.endDate;
      _endDateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(widget.budget.endDate!),
      );
    } else {
      _endDateController = TextEditingController();
    }

    _selectedPeriod = widget.budget.period;

    _initializeServices();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      _budgetServices = await BudgetServices.create();
    } catch (e) {
      _logger.e("Error initializing services", error: e);
      showToast('Failed to initialize services');
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now.subtract(
        const Duration(days: 365),
      ), // Allow backdating up to a year
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentColor,
              onPrimary: Colors.white,
              surface: AppColors.cardColor,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd-MM-yyyy').format(picked);

        // Reset end date if it's earlier than the new start date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
          _endDateController.clear();
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      showToast('Please select a start date first');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 30)),
      firstDate: _startDate!,
      lastDate: DateTime(_startDate!.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentColor,
              onPrimary: Colors.white,
              surface: AppColors.cardColor,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _updateBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      showToast('Please select a start date');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final budgetRequest = BudgetRequest(
        amount: _amountController.text,
        period: _selectedPeriod,
        category: _categoryController.text,
        startDate: DateFormat('dd-MM-yyyy').format(_startDate!),
        endDate: _endDate != null
            ? DateFormat('dd-MM-yyyy').format(_endDate!)
            : '',
      );

      final response = await _budgetServices.updateBudget(
        widget.budget.id,
        budgetRequest,
      );

      if (response.isSuccessful) {
        showToast('Budget updated successfully');
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        throw Exception('Failed to update budget: ${response.error}');
      }
    } catch (e) {
      _logger.e("Error updating budget", error: e);
      showToast('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          'Edit Budget',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textColor),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category field
                _buildInputLabel('Category'),
                _buildTextFormField(
                  controller: _categoryController,
                  hintText: 'e.g., Food, Transportation',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category cannot be empty';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Amount field
                _buildInputLabel('Budget Amount (IDR)'),
                _buildTextFormField(
                  controller: _amountController,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount cannot be empty';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Amount must be a number';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Period dropdown
                _buildInputLabel('Period'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: AppColors.cardColor,
                      value: _selectedPeriod,
                      items: _periods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(
                            _periodDisplayNames[period] ?? period.capitalize(),
                            style: TextStyle(color: AppColors.textColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPeriod = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Start Date field
                _buildInputLabel('Start Date'),
                GestureDetector(
                  onTap: () => _selectStartDate(context),
                  child: AbsorbPointer(
                    child: _buildTextFormField(
                      controller: _startDateController,
                      hintText: 'DD-MM-YYYY',
                      suffixIcon: const Icon(Icons.calendar_today),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Start date cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // End Date field (optional)
                _buildInputLabel('End Date (Optional)'),
                GestureDetector(
                  onTap: () => _selectEndDate(context),
                  child: AbsorbPointer(
                    child: _buildTextFormField(
                      controller: _endDateController,
                      hintText: 'DD-MM-YYYY',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: AppColors.textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dangerColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// String extension for capitalization
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  }
}

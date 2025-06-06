import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/request/budget/budget_request.dart';
import 'package:money_management/services/main/budget_services.dart';
import 'package:money_management/utils/custom_toast.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    return this.isEmpty ? '' : '${this[0].toUpperCase()}${this.substring(1)}';
  }
}

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  String _selectedPeriod = 'daily';
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  late BudgetServices _budgetServices;

  final List<String> _periods = ['daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
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
      showToast('Failed to initialize services');
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
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

  Future<void> _saveBudget() async {
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

      final response = await _budgetServices.createBudget(budgetRequest);

      if (response.isSuccessful) {
        showToast('Budget added successfully');
        Navigator.pop(context);
      } else {
        throw Exception('Failed to add budget: ${response.error}');
      }
    } catch (e) {
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
          'Add Budget',
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
                            period.isEmpty
                                ? ''
                                : '${period[0].toUpperCase()}${period.substring(1)}',
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

                // End Date field
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

                Center(
                  child: ElevatedButton(
                    onPressed: _saveBudget,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : Text('Save Budget'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.accentColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
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

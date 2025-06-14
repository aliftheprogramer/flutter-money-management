import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/request/budget/budget_request.dart';
import 'package:money_management/services/main/budget_services.dart';
import 'package:money_management/utils/custom_toast.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
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
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  String _selectedPeriod = 'daily';
  String? _selectedCategory; // Changed to nullable for dropdown
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  late BudgetServices _budgetServices;

  final List<String> _periods = ['daily', 'weekly', 'monthly'];

  // Added predefined categories
  final List<String> _categories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Tagihan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _amountController.dispose();
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

    if (_selectedCategory == null) {
      showToast('Please select a category');
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
        category: _selectedCategory!, // Use selected category
        startDate: DateFormat('dd-MM-yyyy').format(_startDate!),
        endDate: _endDate != null
            ? DateFormat('dd-MM-yyyy').format(_endDate!)
            : '',
      );

      final response = await _budgetServices.createBudget(budgetRequest);

      if (response.isSuccessful) {
        showToast('Budget added successfully');
        Navigator.pop(context, true); // Return true to indicate success
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
          'Tambah Budget',
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
                // Category dropdown - Updated
                _buildInputLabel('Kategori'),
                const SizedBox(height: 8),
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
                      value: _selectedCategory,
                      hint: Text(
                        'Pilih kategori',
                        style: TextStyle(
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Row(
                            children: [
                              _getCategoryIcon(category),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: TextStyle(color: AppColors.textColor),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Amount field
                _buildInputLabel('Jumlah Budget (IDR)'),
                const SizedBox(height: 8),
                _buildTextFormField(
                  controller: _amountController,
                  hintText: 'Masukkan jumlah budget',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixText: 'Rp ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah budget tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Jumlah budget harus berupa angka';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Jumlah budget harus lebih dari 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Period dropdown
                _buildInputLabel('Periode'),
                const SizedBox(height: 8),
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
                          child: Row(
                            children: [
                              _getPeriodIcon(period),
                              const SizedBox(width: 8),
                              Text(
                                _getPeriodLabel(period),
                                style: TextStyle(color: AppColors.textColor),
                              ),
                            ],
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
                _buildInputLabel('Tanggal Mulai'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectStartDate(context),
                  child: AbsorbPointer(
                    child: _buildTextFormField(
                      controller: _startDateController,
                      hintText: 'DD-MM-YYYY',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: AppColors.accentColor,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal mulai tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // End Date field
                _buildInputLabel('Tanggal Berakhir (Opsional)'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectEndDate(context),
                  child: AbsorbPointer(
                    child: _buildTextFormField(
                      controller: _endDateController,
                      hintText: 'DD-MM-YYYY',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveBudget,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Simpan Budget'),
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
    String? prefixText,
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
        prefixText: prefixText,
        prefixStyle: TextStyle(color: AppColors.textColor),
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

  // Helper method to get category icons
  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color iconColor;

    switch (category.toLowerCase()) {
      case 'makanan':
        iconData = Icons.restaurant;
        iconColor = Colors.orange;
        break;
      case 'transportasi':
        iconData = Icons.directions_car;
        iconColor = Colors.blue;
        break;
      case 'belanja':
        iconData = Icons.shopping_bag;
        iconColor = Colors.purple;
        break;
      case 'hiburan':
        iconData = Icons.movie;
        iconColor = Colors.red;
        break;
      case 'kesehatan':
        iconData = Icons.medical_services;
        iconColor = Colors.green;
        break;
      case 'pendidikan':
        iconData = Icons.school;
        iconColor = Colors.indigo;
        break;
      case 'tagihan':
        iconData = Icons.receipt;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.more_horiz;
        iconColor = AppColors.textColor;
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  // Helper method to get period icons
  Widget _getPeriodIcon(String period) {
    IconData iconData;
    switch (period) {
      case 'daily':
        iconData = Icons.today;
        break;
      case 'weekly':
        iconData = Icons.view_week;
        break;
      case 'monthly':
        iconData = Icons.calendar_month;
        break;
      default:
        iconData = Icons.schedule;
    }

    return Icon(iconData, color: AppColors.accentColor, size: 20);
  }

  // Helper method to get period labels in Indonesian
  String _getPeriodLabel(String period) {
    switch (period) {
      case 'daily':
        return 'Harian';
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
        return 'Bulanan';
      default:
        return period.capitalize();
    }
  }
}

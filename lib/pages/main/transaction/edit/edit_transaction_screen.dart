import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/request/transaction/transaction_request.dart';
import 'package:money_management/models/response/transaction/transaction_response.dart';
import 'package:money_management/services/main/transaction_services.dart';
import 'package:money_management/utils/custom_toast.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionResponse transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TransactionServices _transactionServices;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  String _selectedCategory = '';
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    _isIncome = widget.transaction.type == 'pemasukan';
    _nameController = TextEditingController(
      text: widget.transaction.transactionName,
    );
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _selectedCategory = widget.transaction.category;
    _initializeServices();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      _transactionServices = await TransactionServices.create();
      // Set categories based on transaction type
      _categories = _isIncome
          ? ['Gaji', 'Bonus', 'Investasi', 'Hadiah', 'Lainnya']
          : ['Makanan', 'Transportasi', 'Belanja', 'Hiburan', 'Lainnya'];

      // If the current category is not in the list, add it
      if (!_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory);
      }

      setState(() {});
    } catch (e) {
      showToast('Failed to initialize: $e');
    }
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = TransactionRequest(
        transactionName: _nameController.text,
        amount: _amountController.text,
        category: _selectedCategory,
      );

      final response = await _transactionServices.updateTransaction(
        widget.transaction.id,
        request,
      );

      if (response.isSuccessful) {
        showToast('Transaksi berhasil diperbarui');
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        throw Exception('Gagal memperbarui transaksi: ${response.error}');
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
        backgroundColor: _isIncome
            ? AppColors.successColor
            : AppColors.dangerColor,
        elevation: 0,
        title: Text(
          _isIncome ? 'Edit Pemasukan' : 'Edit Pengeluaran',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction name field
                _buildInputLabel('Nama Transaksi'),
                _buildTextFormField(
                  controller: _nameController,
                  hintText: 'Contoh: Gaji Bulanan',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama transaksi tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Amount field
                _buildInputLabel('Jumlah (Rp)'),
                _buildTextFormField(
                  controller: _amountController,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Jumlah harus berupa angka';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Jumlah harus lebih dari 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Category dropdown
                _buildInputLabel('Kategori'),
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
                      value: _selectedCategory.isEmpty
                          ? null
                          : _selectedCategory,
                      hint: Text(
                        'Pilih Kategori',
                        style: TextStyle(color: AppColors.secondaryTextColor),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(color: AppColors.textColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Note field (optional)
                _buildInputLabel('Catatan (Opsional)'),
                _buildTextFormField(
                  controller: _noteController,
                  hintText: 'Tambahkan catatan...',
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isIncome
                          ? AppColors.successColor
                          : AppColors.dangerColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Perubahan',
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.secondaryTextColor),
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
      ),
      validator: validator,
    );
  }
}

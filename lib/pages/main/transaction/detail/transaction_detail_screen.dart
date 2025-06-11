import 'package:flutter/material.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/response/transaction/transaction_response.dart';
import 'package:money_management/pages/main/transaction/edit/edit_transaction_screen.dart';
import 'package:money_management/services/main/transaction_services.dart';
import 'package:money_management/utils/custom_toast.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionResponse transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _isDeleting = false;
  late TransactionServices _transactionServices;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _transactionServices = await TransactionServices.create();
  }

  Future<void> _deleteTransaction() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: Text(
          'Hapus Transaksi',
          style: TextStyle(color: AppColors.textColor),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: AppColors.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: TextStyle(color: AppColors.dangerColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await _transactionServices.deleteTransaction(
        widget.transaction.id,
      );

      if (response.isSuccessful) {
        showToast('Transaksi berhasil dihapus');
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        throw Exception('Failed to delete transaction: ${response.error}');
      }
    } catch (e) {
      showToast('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.type == 'pemasukan';
    final primaryColor = isIncome
        ? AppColors.successColor
        : AppColors.dangerColor;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Detail Transaksi',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with transaction type and amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Transaction type icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Transaction type
                  Text(
                    isIncome ? 'Pemasukan' : 'Pengeluaran',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Transaction amount
                  Text(
                    _formatCurrency(widget.transaction.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Transaction date
                  Text(
                    DateFormat(
                      'dd MMMM yyyy, HH:mm',
                    ).format(widget.transaction.date),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Transaction details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: AppColors.cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDetailItem(
                        'Nama Transaksi',
                        widget.transaction.transactionName,
                      ),
                      _buildDivider(),
                      _buildDetailItem('Kategori', widget.transaction.category),
                      _buildDivider(),
                      _buildDetailItem(
                        'Jumlah',
                        _formatCurrency(widget.transaction.amount),
                      ),
                      if (widget.transaction.note.isNotEmpty) ...[
                        _buildDivider(),
                        _buildDetailItem('Catatan', widget.transaction.note),
                      ],
                      _buildDivider(),
                      _buildDetailItem(
                        'ID Transaksi',
                        widget.transaction.id.substring(0, 8) + '...',
                        isSecondary: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  // Edit button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToEditTransaction(),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Delete button - direct action
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isDeleting ? null : _deleteTransaction,
                      icon: _isDeleting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.delete, color: Colors.white),
                      label: Text(
                        _isDeleting ? 'Menghapus...' : 'Hapus',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    bool isSecondary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: isSecondary
                    ? AppColors.secondaryTextColor
                    : AppColors.textColor,
                fontSize: 14,
                fontWeight: isSecondary ? FontWeight.normal : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.borderColor, height: 16);
  }

  void _navigateToEditTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditTransactionScreen(transaction: widget.transaction),
      ),
    ).then((refreshNeeded) {
      if (refreshNeeded == true) {
        Navigator.pop(context, true); // Pop and indicate refresh needed
      }
    });
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

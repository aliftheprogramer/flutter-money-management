import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/response/auth/summary_response.dart';
import 'package:money_management/models/response/transaction/transaction_response.dart';
import 'package:money_management/pages/main/transaction/add/add_transaction_screen.dart';
import 'package:money_management/services/auth/token_services.dart';
import 'package:money_management/services/main/summary_services.dart';
import 'package:money_management/services/main/transaction_services.dart';
import 'package:money_management/services/main/user_services.dart'; // Add this import
import 'package:money_management/utils/custom_toast.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionResponse> _transactionList = [];
  SummaryResponse? _summaryData;
  Map<String, dynamic>? _userData; // Add this for user profile data
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  late TransactionServices _transactionServices;
  late SummaryServices _summaryServices;
  late UserServices _userServices; // Add this
  final TokenService tokenService = TokenService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _transactionServices = await TransactionServices.create();
      _summaryServices = await SummaryServices.create();
      _userServices = await UserServices.create(); // Add this
      await _fetchData();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize services: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Use the same method as profile screen to get user data with wallet info
      final userResponse = await _userServices.getUserProfile(widget.userId);

      if (userResponse.isSuccessful && userResponse.body != null) {
        _userData = userResponse.body;

        // Fetch recent transactions
        final transactionsResponse = await _transactionServices
            .getAllTransactionsByDate();

        List<TransactionResponse> transactionsList = [];
        if (transactionsResponse.isSuccessful &&
            transactionsResponse.body != null &&
            transactionsResponse.body is Map<String, dynamic> &&
            transactionsResponse.body['transactions'] != null) {
          final transactions =
              transactionsResponse.body['transactions'] as List;
          transactionsList = transactions
              .map((item) => TransactionResponse.fromJson(item))
              .toList();
        }

        setState(() {
          _transactionList = transactionsList;
          _isLoading = false;
        });
      } else {
        // Set empty data instead of throwing error
        setState(() {
          _userData = null;
          _transactionList = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger().e("Error in _fetchData: $e");
      setState(() {
        _hasError = false; // Don't show error state, just empty data
        _isLoading = false;
        _userData = null;
        _transactionList = [];
      });
    }
  }

  void _navigateToAddTransaction(bool isIncome) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(isIncome: isIncome),
      ),
    ).then((_) => _fetchData()); // Refresh data when coming back
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Oops! Something went wrong.',
              style: TextStyle(color: AppColors.textColor, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
          ],
        ),
      );
    }

    // Get data from user profile response (same as profile screen)
    final stats = _userData != null ? _userData!['stats'] : null;
    final wallet = _userData != null ? _userData!['wallet'] : null;

    // Calculate balance from wallet data (same as profile screen)
    final income = stats != null ? stats['pemasukan']['total'] ?? 0 : 0;
    final expense = stats != null ? stats['pengeluaran']['total'] ?? 0 : 0;
    final balance = wallet != null ? wallet['totalBalance'] ?? 0 : 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance card - now using wallet balance
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Saldo',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp ${_formatCurrency(balance)}',
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.content_copy,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showToast('Copied to clipboard');
                            },
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                // Income and Expense summary - using stats data
                Row(
                  children: [
                    // Income summary
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors.successColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                Icons.arrow_upward,
                                color: AppColors.successColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: AppColors.secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(income)}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16.0),

                    // Expense summary
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors.dangerColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                Icons.arrow_downward,
                                color: AppColors.dangerColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: AppColors.secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(expense)}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),

                // Add Income/Expense buttons
                Row(
                  children: [
                    // Add Income button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToAddTransaction(true),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.successColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 24),
                              SizedBox(height: 4),
                              Text(
                                'Tambah\nPemasukan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16.0),

                    // Add Expense button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToAddTransaction(false),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.dangerColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove, color: Colors.white, size: 24),
                              SizedBox(height: 4),
                              Text(
                                'Tambah\nPengeluaran',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24.0),

                // Recent Transactions
                Text(
                  'Transaksi Terbaru',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),

                const SizedBox(height: 12.0),

                // Transaction list with empty state
                Expanded(
                  child: _transactionList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: AppColors.secondaryTextColor.withOpacity(
                                  0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada transaksi',
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mulai kelola keuangan Anda dengan\nmenambahkan pemasukan atau pengeluaran',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _navigateToAddTransaction(true),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Pemasukan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.successColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _navigateToAddTransaction(false),
                                    icon: const Icon(Icons.remove, size: 16),
                                    label: const Text('Pengeluaran'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.dangerColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _transactionList.length > 5
                              ? 5 // Show only 5 most recent transactions
                              : _transactionList.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactionList[index];
                            final isIncome = transaction.type == 'pemasukan';

                            return buildTransactionItem(
                              icon: isIncome
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              iconColor: isIncome
                                  ? AppColors.successColor
                                  : AppColors.dangerColor,
                              iconBgColor: isIncome
                                  ? AppColors.successColor.withOpacity(0.2)
                                  : AppColors.dangerColor.withOpacity(0.2),
                              title: transaction.transactionName,
                              subtitle: transaction.category,
                              amount:
                                  '${isIncome ? '+' : '-'}Rp ${_formatCurrency(transaction.amount)}',
                              amountColor: isIncome
                                  ? AppColors.successColor
                                  : AppColors.dangerColor,
                              date:
                                  '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add the same currency formatting method as profile screen
  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    final number = value is num ? value : num.tryParse(value.toString()) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),

          const SizedBox(width: 12.0),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Amount and date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

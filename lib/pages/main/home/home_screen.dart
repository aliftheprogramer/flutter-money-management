import 'package:flutter/material.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/response/auth/summary_response.dart';
import 'package:money_management/models/response/transaction/transaction_response.dart';
import 'package:money_management/pages/main/transaction/add/add_transaction_screen.dart';
import 'package:money_management/services/main/summary_services.dart';
import 'package:money_management/services/main/transaction_services.dart';
import 'package:money_management/utils/custom_toast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionResponse> _transactionList = [];
  SummaryResponse? _summaryData;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  late TransactionServices _transactionServices;
  late SummaryServices _summaryServices;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _transactionServices = await TransactionServices.create();
      _summaryServices = await SummaryServices.create();

      // For demo, we'll use a hardcoded user ID - in production this would come from auth
      _userId = "683b6a385f5a412f3de62a08";

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
      // Fetch summary data using the user ID
      final summaryResponse = await _summaryServices.getSummary(_userId!);
      if (summaryResponse.isSuccessful && summaryResponse.body != null) {
        final summaryData = SummaryResponse.fromJson(summaryResponse.body);

        // Fetch recent transactions
        final transactionsResponse = await _transactionServices
            .getAllTransactionsByDate();
        if (transactionsResponse.isSuccessful &&
            transactionsResponse.body != null) {
          final transactions =
              transactionsResponse.body['transactions'] as List;
          List<TransactionResponse> transactionsList = transactions
              .map((item) => TransactionResponse.fromJson(item))
              .toList();

          setState(() {
            _summaryData = summaryData;
            _transactionList = transactionsList;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch transactions');
        }
      } else {
        throw Exception('Failed to fetch summary data');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error fetching data: $e';
        _isLoading = false;
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

    // Calculate balance
    final income = _summaryData?.summary.pemasukan.total ?? 0;
    final expense = _summaryData?.summary.pengeluaran.total ?? 0;
    final balance = income - expense;

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
                // Balance card
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
                            'Rp ${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
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
                              // Copy to clipboard logic
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

                // Income and Expense summary
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
                            Column(
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
                                  'Rp ${income.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
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
                            Column(
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
                                  'Rp ${expense.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
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

                // Transaction list
                Expanded(
                  child: _transactionList.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada transaksi',
                            style: TextStyle(
                              color: AppColors.secondaryTextColor,
                            ),
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
                                  '${isIncome ? '+' : '-'}Rp ${transaction.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
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

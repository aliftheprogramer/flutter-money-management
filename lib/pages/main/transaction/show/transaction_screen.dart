import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/response/auth/summary_response.dart';
import 'package:money_management/models/response/transaction/transaction_response.dart';
import 'package:money_management/services/main/summary_services.dart';
import 'package:money_management/services/main/transaction_services.dart';
import 'package:money_management/services/main/user_services.dart'; // Add this import
import 'package:money_management/pages/main/transaction/add/add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final String userId;

  const TransactionsScreen({super.key, required this.userId});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final Logger _logger = Logger();
  String _selectedPeriod = 'Mingguan';
  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan'];
  String _selectedTransactionType = 'Pemasukan';

  late TransactionServices _transactionServices;
  late SummaryServices _summaryServices;
  late UserServices _userServices; // Add this

  bool _isLoading = true;
  bool _hasError = false;
  List<TransactionResponse> _transactionList = [];
  SummaryResponse? _summaryData;
  List<MonthlySummary>? _monthlySummary;
  Map<String, dynamic>? _userData; // Add this for user profile data

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _logger.i(
        "Initializing transaction services with userId: ${widget.userId}",
      );
      _transactionServices = await TransactionServices.create();
      _summaryServices = await SummaryServices.create();
      _userServices = await UserServices.create(); // Add this
      await _fetchData();
    } catch (e) {
      _logger.e("Error initializing services: $e");
      setState(() {
        _hasError = true;
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
      // Use the same method as home and profile screens
      final userResponse = await _userServices.getUserProfile(widget.userId);

      if (userResponse.isSuccessful && userResponse.body != null) {
        _userData = userResponse.body;

        // Extract summary data from user profile response
        final stats = _userData!['stats'];
        if (stats != null) {
          // Create a mock SummaryResponse from the stats data
          final summaryData = SummaryResponse(
            summary: Summary(
              pemasukan: TransactionTypeSummary(
                total: stats['pemasukan']['total'] ?? 0,
                count: stats['pemasukan']['count'] ?? 0,
              ),
              pengeluaran: TransactionTypeSummary(
                total: stats['pengeluaran']['total'] ?? 0,
                count: stats['pengeluaran']['count'] ?? 0,
              ),
            ),
            monthlySummary:
                [], // Will be populated from monthly data if available
            debug: DebugInfo(
              requestedUserId: widget.userId,
              tokenUserId: widget.userId,
              transactionsExist: TransactionExist(id: widget.userId),
            ),
          );

          // Try to get monthly summary data if available
          List<MonthlySummary> monthlySummaryList = [];
          if (_userData!['monthlySummary'] != null) {
            final monthlyData = _userData!['monthlySummary'] as List;
            monthlySummaryList = monthlyData
                .map((item) => MonthlySummary.fromJson(item))
                .toList();
          }

          // Update the summary data with monthly summary
          _summaryData = SummaryResponse(
            summary: summaryData.summary,
            monthlySummary: monthlySummaryList,
            debug: summaryData.debug,
          );
        }

        // Fetch transactions
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
        } else {
          _logger.w(
            "Transaction response doesn't contain expected data structure",
          );
        }

        setState(() {
          _monthlySummary = _summaryData?.monthlySummary ?? [];
          _transactionList = transactionsList;
          _isLoading = false;
        });
      } else {
        // Set empty data instead of throwing error
        setState(() {
          _summaryData = null;
          _monthlySummary = [];
          _transactionList = [];
          _userData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e("Error in _fetchData: $e");
      setState(() {
        _hasError = false; // Don't show error state, just empty data
        _isLoading = false;
        _summaryData = null;
        _monthlySummary = [];
        _transactionList = [];
        _userData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load data',
                style: TextStyle(color: AppColors.textColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    // Check if we have any data at all
    final hasData = _summaryData != null || _transactionList.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SafeArea(
          child: hasData ? _buildMainContent() : _buildEmptyState(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: AppColors.secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data transaksi',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai kelola keuangan Anda dengan\nmenambahkan transaksi pertama',
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
                  onPressed: () => _navigateToAddTransaction(true),
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
                  onPressed: () => _navigateToAddTransaction(false),
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
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Periode: ',
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textColor,
                  ),
                  elevation: 16,
                  style: TextStyle(color: AppColors.textColor),
                  underline: Container(height: 0),
                  dropdownColor: AppColors.cardColor,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPeriod = newValue!;
                    });
                  },
                  items: _periods.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Chart title
          Text(
            'Statistik Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),

          const SizedBox(height: 16),

          // Chart card - using the actual data
          Container(
            height: 250,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(AppColors.successColor, 'Pemasukan'),
                    const SizedBox(width: 24),
                    _buildLegendItem(AppColors.dangerColor, 'Pengeluaran'),
                  ],
                ),

                const SizedBox(height: 16),

                // Chart with real data
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _calculateMaxY(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem:
                              (
                                BarChartGroupData group,
                                int groupIndex,
                                BarChartRodData rod,
                                int rodIndex,
                              ) {
                                String label = rodIndex == 0
                                    ? 'Pemasukan: '
                                    : 'Pengeluaran: ';
                                return BarTooltipItem(
                                  '$label\nRp ${_formatCurrency(rod.toY)}',
                                  TextStyle(
                                    color: rodIndex == 0
                                        ? AppColors.successColor
                                        : AppColors.dangerColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _getBottomTitle(value.toInt()),
                                style: TextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _formatCurrency(value),
                                style: TextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      barGroups: _getBarGroups(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Transaction type tabs
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTransactionTypeTab(
                    'Pemasukan',
                    AppColors.successColor,
                  ),
                ),
                Expanded(
                  child: _buildTransactionTypeTab(
                    'Pengeluaran',
                    AppColors.dangerColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transaction list title (dynamically shows selected type)
          Text(
            _selectedTransactionType,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),

          const SizedBox(height: 12),

          // Transactions list (filtered by type)
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  // Helper method to format currency
  String _formatCurrency(double value) {
    if (value == 0) {
      return '0';
    } else if (value < 1000) {
      return value.toInt().toString();
    } else if (value < 1000000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
  }

  // Helper method to get bottom titles based on period
  String _getBottomTitle(int index) {
    switch (_selectedPeriod) {
      case 'Mingguan':
        final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        return index < days.length ? days[index] : '';
      case 'Bulanan':
        return 'Mg ${index + 1}';
      case 'Tahunan':
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        return index < months.length ? months[index] : '';
      default:
        return '';
    }
  }

  // Calculate max Y value for chart
  double _calculateMaxY() {
    if (_summaryData == null) {
      return 5000000.0;
    }

    double maxValue = 0;
    final income = _summaryData!.summary.pemasukan.total.toDouble();
    final expense = _summaryData!.summary.pengeluaran.total.toDouble();

    maxValue = income > expense ? income : expense;

    if (maxValue == 0) {
      return 5000000.0;
    }

    // Round up to nearest significant figure for clean chart
    return ((maxValue / 1000000).ceil() * 1000000).toDouble();
  }

  // Method to build transaction type tab button
  Widget _buildTransactionTypeTab(String title, Color activeColor) {
    final isSelected = _selectedTransactionType == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTransactionType = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.secondaryTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textColor)),
      ],
    );
  }

  // Helper method to get bar chart data
  List<BarChartGroupData> _getBarGroups() {
    if (_summaryData == null) {
      // Return single bar with zero values if no data
      return [_makeBarGroup(0, 0, 0)];
    }

    // For now, show a simple comparison of total income vs expense
    // You can enhance this to show actual monthly/weekly breakdown
    final income = _summaryData!.summary.pemasukan.total.toDouble();
    final expense = _summaryData!.summary.pengeluaran.total.toDouble();

    return [_makeBarGroup(0, income, expense)];
  }

  // Helper method to create a bar group
  BarChartGroupData _makeBarGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: AppColors.successColor,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: expense,
          color: AppColors.dangerColor,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // Helper method to build the transaction list (filtered by type)
  Widget _buildTransactionList() {
    // Filter transactions based on selected type
    final String apiType = _selectedTransactionType == 'Pemasukan'
        ? 'pemasukan'
        : 'pengeluaran';
    final filteredTransactions = _transactionList
        .where((transaction) => transaction.type == apiType)
        .toList();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tidak ada transaksi $_selectedTransactionType',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to add transaction screen
                _navigateToAddTransaction();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTransactionType == 'Pemasukan'
                    ? AppColors.successColor
                    : AppColors.dangerColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Tambah $_selectedTransactionType',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        final isIncome = transaction.type == 'pemasukan';

        return _buildTransactionItem(
          icon: isIncome ? Icons.arrow_upward : Icons.arrow_downward,
          iconColor: isIncome ? AppColors.successColor : AppColors.dangerColor,
          iconBgColor: isIncome
              ? AppColors.successColor.withOpacity(0.2)
              : AppColors.dangerColor.withOpacity(0.2),
          title: transaction.transactionName,
          subtitle: transaction.category,
          amount:
              '${isIncome ? '+' : '-'}Rp ${_formatNumberCurrency(transaction.amount)}',
          amountColor: isIncome
              ? AppColors.successColor
              : AppColors.dangerColor,
          date:
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
        );
      },
    );
  }

  // Helper method to format number as currency
  String _formatNumberCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Add this new method to handle navigation
  void _navigateToAddTransaction([bool? isIncome]) {
    final bool shouldAddIncome =
        isIncome ?? (_selectedTransactionType == 'Pemasukan');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(isIncome: shouldAddIncome),
      ),
    ).then((result) {
      // Refresh data when returning from add transaction screen
      if (result != null) {
        _fetchData();
      }
    });
  }

  // Helper method to build a transaction item
  Widget _buildTransactionItem({
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

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/response/auth/summary_response.dart';
import 'package:money_management/models/response/transaction/transaction_response.dart';
import 'package:money_management/services/main/summary_services.dart';
import 'package:money_management/services/main/transaction_services.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedPeriod = 'Mingguan';
  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan'];
  String _selectedTransactionType = 'Pemasukan';

  late TransactionServices _transactionServices;
  late SummaryServices _summaryServices;
  String? _userId;

  bool _isLoading = true;
  bool _hasError = false;
  List<TransactionResponse> _transactionList = [];
  SummaryResponse? _summaryData;
  List<MonthlySummary>? _monthlySummary;

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
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch summary data
      final summaryResponse = await _summaryServices.getSummary(_userId!);
      if (summaryResponse.isSuccessful && summaryResponse.body != null) {
        final summaryData = SummaryResponse.fromJson(summaryResponse.body);

        // Fetch transactions
        final transactionsResponse = await _transactionServices
            .getAllTransactionsByDate();
        if (transactionsResponse.isSuccessful &&
            transactionsResponse.body != null) {
          final transactions =
              transactionsResponse.body['transactions'] as List;
          final transactionsList = transactions
              .map((item) => TransactionResponse.fromJson(item))
              .toList();

          setState(() {
            _summaryData = summaryData;
            _monthlySummary = summaryData.monthlySummary;
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
        _isLoading = false;
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
                // Period selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                        items: _periods.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
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
                          _buildLegendItem(
                            AppColors.dangerColor,
                            'Pengeluaran',
                          ),
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
                                        '$label\nRp ${(rod.toY / 1000).round()}K',
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
          ),
        ),
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
    if (_monthlySummary == null || _monthlySummary!.isEmpty) {
      return 5000000.0;
    }

    double maxValue = 0;
    for (var summary in _monthlySummary!) {
      if (summary.total > maxValue) {
        maxValue = summary.total.toDouble();
      }
    }

    // Round up to nearest million for clean chart
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
    if (_monthlySummary == null || _monthlySummary!.isEmpty) {
      // Return dummy data if no real data available
      return [_makeBarGroup(0, 0, 0)];
    }

    // Process and group the data based on selected period
    Map<int, Map<String, int>> groupedData = {};

    for (var summary in _monthlySummary!) {
      int key;
      switch (_selectedPeriod) {
        case 'Mingguan':
          // For weekly, group by day of week
          final date = DateTime(summary.year, summary.month);
          key = date.weekday - 1; // 0-6 for Mon-Sun
          break;
        case 'Bulanan':
          // For monthly, group by week of month (simplified)
          key = ((summary.month - 1) % 4);
          break;
        case 'Tahunan':
        default:
          // For yearly, group by month
          key = summary.month - 1; // 0-11 for Jan-Dec
          break;
      }

      // Initialize if not exists
      groupedData[key] ??= {'pemasukan': 0, 'pengeluaran': 0};

      // Add values
      if (summary.type == 'pemasukan') {
        groupedData[key]!['pemasukan'] =
            (groupedData[key]!['pemasukan'] ?? 0) + summary.total;
      } else {
        groupedData[key]!['pengeluaran'] =
            (groupedData[key]!['pengeluaran'] ?? 0) + summary.total;
      }
    }

    // Convert to bar groups
    List<BarChartGroupData> barGroups = [];
    for (
      int i = 0;
      i <
          (_selectedPeriod == 'Mingguan'
              ? 7
              : (_selectedPeriod == 'Bulanan' ? 4 : 12));
      i++
    ) {
      final data = groupedData[i] ?? {'pemasukan': 0, 'pengeluaran': 0};
      barGroups.add(
        _makeBarGroup(
          i,
          data['pemasukan']!.toDouble(),
          data['pengeluaran']!.toDouble(),
        ),
      );
    }

    return barGroups;
  }

  // Helper method to create a bar group
  BarChartGroupData _makeBarGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: AppColors.successColor,
          width: 12,
          borderRadius: BorderRadius.circular(2),
        ),
        BarChartRodData(
          toY: expense,
          color: AppColors.dangerColor,
          width: 12,
          borderRadius: BorderRadius.circular(2),
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
        child: Text(
          'Tidak ada transaksi $_selectedTransactionType',
          style: TextStyle(color: AppColors.secondaryTextColor),
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
              '${isIncome ? '+' : '-'}Rp ${transaction.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
          amountColor: isIncome
              ? AppColors.successColor
              : AppColors.dangerColor,
          date:
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
        );
      },
    );
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

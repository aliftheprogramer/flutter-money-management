import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/response/budget/budget_response_by_id.dart';
import 'package:money_management/pages/main/budget/add_budget_screen.dart';
import 'package:money_management/services/main/budget_services.dart';

class BudgetScreen extends StatefulWidget {
  final String userId;

  const BudgetScreen({super.key, required this.userId});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final Logger _logger = Logger();
  String _selectedPeriod = 'monthly';
  final List<String> _periods = ['daily', 'weekly', 'monthly'];

  final Map<String, String> _periodDisplayNames = {
    'daily': 'Harian',
    'weekly': 'Mingguan',
    'monthly': 'Bulanan',
  };

  List<BudgetResponse> _budgets = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  late BudgetServices _budgetServices;

  @override
  void initState() {
    super.initState();
    _logger.i("BudgetScreen initialized with userId: ${widget.userId}");
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _logger.d("Initializing budget services");
    try {
      _budgetServices = await BudgetServices.create();
      _logger.i("Budget services successfully created");
      await _fetchBudgets();
    } catch (e) {
      _logger.e(
        "Error initializing services",
        error: e,
        stackTrace: StackTrace.current,
      );
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize services: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBudgets() async {
    _logger.d("Fetching budgets for user: ${widget.userId}");
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Pass the userId to get user-specific budgets if your API supports it
      final response = await _budgetServices.getAllBudgets();
      _logger.d("Budget API response received: ${response.statusCode}");

      if (response.isSuccessful && response.body != null) {
        final List<dynamic> budgetsJson = response.body;
        _logger.i("Received ${budgetsJson.length} budgets from API");

        final budgets = budgetsJson
            .map((json) => BudgetResponse.fromJson(json))
            .toList();

        setState(() {
          _budgets = budgets;
          _isLoading = false;
        });

        _logger.i("Budgets successfully processed and set to state");
      } else {
        _logger.e(
          "API returned unsuccessful response: ${response.statusCode}, body: ${response.error}",
        );
        throw Exception('Failed to fetch budgets: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e(
        "Error fetching budgets",
        error: e,
        stackTrace: StackTrace.current,
      );
      setState(() {
        _hasError = true;
        _errorMessage = 'Error fetching budgets: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBudget(String id) async {
    _logger.d("Attempting to delete budget with ID: $id");
    try {
      final response = await _budgetServices.deleteBudget(id);
      if (response.isSuccessful) {
        _logger.i("Successfully deleted budget with ID: $id");
        // Remove the deleted budget from the list
        setState(() {
          _budgets.removeWhere((budget) => budget.id == id);
        });
      } else {
        _logger.e(
          "Failed to delete budget: ${response.statusCode}, error: ${response.error}",
        );
        throw Exception('Failed to delete budget: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e(
        "Error in delete budget operation",
        error: e,
        stackTrace: StackTrace.current,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting budget: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period filter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.textColor),
                  elevation: 16,
                  style: TextStyle(color: AppColors.textColor),
                  underline: Container(),
                  dropdownColor: AppColors.cardColor,
                  onChanged: (String? newValue) {
                    _logger.d("Period filter changed to: $newValue");
                    setState(() {
                      _selectedPeriod = newValue!;
                    });
                  },
                  items: _periods.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      // Display localized names instead of just capitalized English
                      child: Text(
                        _periodDisplayNames[value] ?? value.capitalize(),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Budget list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading budgets',
                              style: TextStyle(color: AppColors.textColor),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _fetchBudgets,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _budgets.isEmpty
                    ? Center(
                        child: Text(
                          'No budgets found',
                          style: TextStyle(color: AppColors.textColor),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchBudgets,
                        child: ListView.builder(
                          itemCount: _budgets.length,
                          itemBuilder: (context, index) {
                            final budget = _budgets[index];
                            // Filter by selected period directly (no mapping needed)
                            if (_selectedPeriod.toLowerCase() !=
                                budget.period.toLowerCase()) {
                              _logger.d(
                                "Budget filtered out - selected: $_selectedPeriod, budget: ${budget.period}",
                              );
                              return const SizedBox.shrink();
                            }
                            _logger.d(
                              "Showing budget: ${budget.id}, Category: ${budget.category}",
                            );
                            return _buildBudgetCard(budget);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentColor,
        child: const Icon(Icons.add),
        onPressed: () {
          _logger.i("Add budget button pressed");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          ).then((_) => _fetchBudgets());
        },
      ),
    );
  }

  Widget _buildBudgetCard(BudgetResponse budget) {
    // Calculate percentage
    final percentage = budget.percentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  budget.category,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              // Delete button
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.dangerColor),
                onPressed: () => _deleteBudget(budget.id),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Budget amount
          Text(
            'Rp ${budget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),

          const SizedBox(height: 16),

          // Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColors.borderColor,
                    color: _getProgressColor(percentage),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: _getProgressColor(percentage),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Spent and remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: Rp ${budget.spent.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
              Text(
                'Remaining: Rp ${budget.remaining.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Period
          Text(
            'Period: ${budget.period}',
            style: TextStyle(color: AppColors.secondaryTextColor),
          ),

          // Dates
          Text(
            'Start: ${_formatDate(budget.startDate)} - End: ${budget.endDate != null ? _formatDate(budget.endDate!) : 'Not set'}',
            style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage < 50) {
      return AppColors.successColor;
    } else if (percentage < 80) {
      return Colors.orange;
    } else {
      return AppColors.dangerColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

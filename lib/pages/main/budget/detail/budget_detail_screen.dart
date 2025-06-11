import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/models/response/budget/budget_response_by_id.dart';
import 'package:money_management/pages/main/budget/edit/budget_edit_screen.dart';
import 'package:money_management/services/main/budget_services.dart';
import 'package:money_management/utils/custom_toast.dart';

class BudgetDetailScreen extends StatefulWidget {
  final String budgetId;

  const BudgetDetailScreen({super.key, required this.budgetId});

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final Logger _logger = Logger();

  late BudgetServices _budgetServices;
  BudgetResponse? _budget;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _budgetServices = await BudgetServices.create();
      await _fetchBudgetDetails();
    } catch (e) {
      _logger.e("Error initializing services", error: e);
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize services: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBudgetDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _budgetServices.getBudgetById(widget.budgetId);

      if (response.isSuccessful && response.body != null) {
        _logger.d("Budget details fetched successfully");
        final budgetJson = response.body;

        setState(() {
          _budget = BudgetResponse.fromJson(budgetJson);
          _isLoading = false;
        });
      } else {
        _logger.e("Failed to fetch budget details: ${response.error}");
        throw Exception('Failed to fetch budget details: ${response.error}');
      }
    } catch (e) {
      _logger.e("Error fetching budget details", error: e);
      setState(() {
        _hasError = true;
        _errorMessage = 'Error fetching budget details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBudget() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: Text(
          'Delete Budget',
          style: TextStyle(color: AppColors.textColor),
        ),
        content: Text(
          'Are you sure you want to delete this budget? This action cannot be undone.',
          style: TextStyle(color: AppColors.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
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
      final response = await _budgetServices.deleteBudget(widget.budgetId);

      if (response.isSuccessful) {
        showToast('Budget deleted successfully');
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        throw Exception('Failed to delete budget: ${response.error}');
      }
    } catch (e) {
      showToast('Error: $e');
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  void _navigateToBudgetEdit() {
    if (_budget == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetEditScreen(budget: _budget!),
      ),
    ).then((refreshNeeded) {
      if (refreshNeeded == true) {
        _fetchBudgetDetails();
      }
    });
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String _getPeriodText(String period) {
    final Map<String, String> periodMap = {
      'daily': 'Harian',
      'weekly': 'Mingguan',
      'monthly': 'Bulanan',
    };

    return periodMap[period.toLowerCase()] ?? period;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          'Budget Detail',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? _buildErrorState()
          : _buildBudgetDetail(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load budget details',
            style: TextStyle(color: AppColors.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(color: AppColors.secondaryTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchBudgetDetails,
            child: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDetail() {
    if (_budget == null) {
      return Center(
        child: Text(
          'No budget data found',
          style: TextStyle(color: AppColors.textColor),
        ),
      );
    }

    final budget = _budget!;
    final percentage = budget.percentage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget summary card
          Card(
            color: AppColors.cardColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and period
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.category,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getPeriodText(budget.period),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatCurrency(budget.amount),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Progress bar
                  Text(
                    'Budget Usage',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.borderColor,
                      color: _getProgressColor(percentage),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${percentage}% used',
                        style: TextStyle(
                          color: _getProgressColor(percentage),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatCurrency(budget.spent),
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Budget details
          Text(
            'Budget Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),

          const SizedBox(height: 16),

          // Details card
          Card(
            color: AppColors.cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailItem(
                    'Total Amount',
                    _formatCurrency(budget.amount),
                  ),
                  const Divider(height: 24),
                  _buildDetailItem('Spent', _formatCurrency(budget.spent)),
                  const Divider(height: 24),
                  _buildDetailItem(
                    'Remaining',
                    _formatCurrency(budget.remaining),
                  ),
                  const Divider(height: 24),
                  _buildDetailItem('Period', _getPeriodText(budget.period)),
                  const Divider(height: 24),
                  _buildDetailItem('Start Date', _formatDate(budget.startDate)),
                  if (budget.endDate != null) ...[
                    const Divider(height: 24),
                    _buildDetailItem('End Date', _formatDate(budget.endDate!)),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Edit button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _navigateToBudgetEdit,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Edit Budget',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Delete button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isDeleting ? null : _deleteBudget,
                  icon: _isDeleting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.delete, color: Colors.white),
                  label: Text(
                    _isDeleting ? 'Deleting...' : 'Delete Budget',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

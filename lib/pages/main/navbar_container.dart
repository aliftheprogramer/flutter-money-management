import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_management/pages/main/budget/budget_screen.dart';
import 'package:money_management/pages/main/home/home_screen.dart';
import 'package:money_management/pages/main/profile/profile_screen.dart';
import 'package:money_management/pages/main/transaction/show/transaction_screen.dart';
import 'package:money_management/services/auth/token_services.dart';
import 'package:money_management/widgets/bottom_navigation/custom_bottom_navbar.dart'
    show CustomBottomNavbar;

class NavbarContainer extends StatefulWidget {
  const NavbarContainer({super.key});

  @override
  State<NavbarContainer> createState() => _NavbarContainerState();
}

class _NavbarContainerState extends State<NavbarContainer> {
  int _currentIndex = 0;
  String? _userId;
  bool _isLoading = true;
  late List<Widget> _screens;
  final TokenService _tokenService = TokenService();
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final Map<String, dynamic> decodedToken = await _tokenService
          .getDecodedToken();
      final userId =
          decodedToken['userId'] ??
          decodedToken['id'] ??
          decodedToken['sub'] ??
          decodedToken['_id'];

      if (userId != null && userId.isNotEmpty) {
        setState(() {
          _userId = userId;
          _isLoading = false;
          _initScreens();
        });
        _logger.i("NavbarContainer retrieved user ID: $_userId");
      } else {
        _logger.w("User ID not found in token, using fallback");
        setState(() {
          _isLoading = false;
          _initScreens();
        });
      }
    } catch (e) {
      _logger.e("Error getting user ID from token: $e");
      setState(() {
        _initScreens();
      });
    }
  }

  void _initScreens() {
    _screens = [
      HomeScreen(userId: _userId!),
      TransactionsScreen(userId: _userId!),
      BudgetScreen(userId: _userId!),
      ProfileScreen(userId: _userId!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _logger.i("Building NavbarContainer with current index: $_currentIndex");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _logger.i("Settings button tapped");
              // Navigate to settings screen or perform an action
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _logger.i("Bottom navigation tapped: $index");
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

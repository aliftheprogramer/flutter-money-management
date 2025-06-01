import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:money_management/pages/main/budget/budget_screen.dart';
import 'package:money_management/pages/main/home/home_screen.dart';
import 'package:money_management/pages/main/profile/profile_screen.dart';
import 'package:money_management/pages/main/transaction/show/transaction_screen.dart';
import 'package:money_management/widgets/bottom_navigation/custom_bottom_navbar.dart'
    show CustomBottomNavbar;

class NavbarContainer extends StatefulWidget {
  const NavbarContainer({super.key});

  @override
  State<NavbarContainer> createState() => _NavbarContainerState();
}

class _NavbarContainerState extends State<NavbarContainer> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Logger().i(
      "NavbarContainer initialized with current index: $_currentIndex",
    );
  }

  @override
  Widget build(BuildContext context) {
    Logger().i("Building NavbarContainer with current index: $_currentIndex");
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          Logger().i("Bottom navigation tapped: $index");
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

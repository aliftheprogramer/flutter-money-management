import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_management/pages/auth/login/login_screen.dart';
import 'package:money_management/pages/auth/register/register_screen.dart';
import 'package:money_management/pages/main/budget/budget_screen.dart';
import 'package:money_management/pages/main/home/home_screen.dart';
import 'package:money_management/pages/main/navbar_container.dart';
import 'package:money_management/pages/main/profile/profile_screen.dart';
import 'package:money_management/pages/main/transaction/add/add_transaction_screen.dart';
import 'package:money_management/pages/main/transaction/show/transaction_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Management',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A202C),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) {
          Logger().i("make navbar container for /main page");
          return NavbarContainer();
        },
        '/main/home': (context) => HomeScreen(),
        '/main/transactions': (context) => TransactionsScreen(),
        '/main/transactions/add': (context) => AddTransactionScreen(),
        '/main/budgets': (context) => BudgetScreen(),
        '/main/profile': (context) => ProfileScreen(),
      },
    );
  }
}

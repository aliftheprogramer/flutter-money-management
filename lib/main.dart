import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_management/pages/auth/login/login_screen.dart';
import 'package:money_management/pages/auth/register/register_screen.dart';
import 'package:money_management/pages/main/budget/budget_screen.dart';
import 'package:money_management/pages/main/home/home_screen.dart';
import 'package:money_management/pages/main/navbar_container.dart';
import 'package:money_management/pages/main/profile/edit_proile_screen.dart';
import 'package:money_management/pages/main/profile/profile_screen.dart';
import 'package:money_management/pages/main/transaction/add/add_transaction_screen.dart';
import 'package:money_management/pages/main/transaction/show/transaction_screen.dart';
import 'package:money_management/services/auth/token_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenService = TokenService();
  final token = await tokenService.getToken();

  String initialRoute = token != null && token.isNotEmpty ? '/main' : '/login';
  Logger().i(token);
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Management',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A202C),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) {
          Logger().i("make navbar container for /main page");
          return NavbarContainer();
        },
        '/main/home': (context) => HomeScreen(userId: ''),
        '/main/transactions/add': (context) =>
            AddTransactionScreen(isIncome: false),
        '/main/profile/edit': (context) => EditProfileScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_management/models/request/auth/login_request.dart';
import 'package:money_management/models/response/auth/auth_response.dart';
import 'package:money_management/services/auth/auth_services.dart';
import 'package:money_management/services/auth/token_services.dart';
import 'package:money_management/utils/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthServices? _authServices;
  late TokenService _tokenService;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tokenService = TokenService();
    _initializeAuthServices();
  }

  Future<void> _initializeAuthServices() async {
    _authServices = await AuthServices.create();
    setState(() {}); // Update the UI once the service is ready
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  Future<void> _submitLoginForm() async {
    Logger().i("logibn button pressed");
    if (_formKey.currentState!.validate()) {
      Logger().i('login form is valid');
      setState(() {
        _isLoading = true;
      });

      try {
        final loginRequest = LoginRequest(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Logger().i('Login request: ${loginRequest.toJson()}');
        final response = await _authServices!.login(loginRequest);

        if (response.isSuccessful) {
          final responseBody = response.body as Map<String, dynamic>;
          final authResponse = AuthResponse.fromJson(responseBody);

          final token = authResponse.token;
          Logger().i('Login successful, token: $token');
          await _tokenService.saveToken(token);

          showToast("login sukses");
          Logger().i('login aman');

          if (!mounted) return;

          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil("/main", (route) => false);
        } else {
          final errorResponse = response.error.toString();
          showToast('gagal brok ');
          Logger().e('Login failed: $errorResponse');
        }
      } catch (e) {
        Logger().e('Error during login: $e');
        showToast('Terjadi kesalahan saat login. Silakan coba lagi.');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        } else {
          Logger().w('Login form validation failed');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128), // Deep navy blue background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo atau Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A90E2), // Electric blue
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE2E8F0), // Light bluish white
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan masuk ke akun Anda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ), // Medium gray
                ),
                const SizedBox(height: 40),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                        ), // Light text
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            color: Color(0xFF718096),
                          ), // Medium gray
                          hintText: 'Masukkan email Anda',
                          hintStyle: const TextStyle(
                            color: Color(0xFF718096),
                          ), // Medium gray
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF718096), // Medium gray
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2D3748),
                            ), // Dark gray
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF3F5E7B),
                            ), // Dark blue gray
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF64B6EE),
                            ), // Light blue
                          ),
                          filled: true,
                          fillColor: const Color(
                            0xFF1A202C,
                          ), // Slightly lighter than background
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field - with similar styling
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: _validatePassword,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                        ), // Light text
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Color(0xFF718096),
                          ), // Medium gray
                          hintText: 'Masukkan password Anda',
                          hintStyle: const TextStyle(
                            color: Color(0xFF718096),
                          ), // Medium gray
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF718096), // Medium gray
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF718096), // Medium gray
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2D3748),
                            ), // Dark gray
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF3F5E7B),
                            ), // Dark blue gray
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF64B6EE),
                            ), // Light blue
                          ),
                          filled: true,
                          fillColor: const Color(
                            0xFF1A202C,
                          ), // Slightly lighter than background
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitLoginForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF4A90E2,
                            ), // Electric blue
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            disabledBackgroundColor: const Color(
                              0xFF4A90E2,
                            ).withOpacity(0.6), // Electric blue with opacity
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: Color(0xFF718096)), // Medium gray
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigasi ke halaman register
                        Logger().i('Navigasi ke halaman register');
                        Navigator.pushNamed(context, '/register');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64B6EE), // Light blue
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_management/models/request/auth/register_request.dart';
import 'package:money_management/models/response/auth/auth_response.dart';
import 'package:money_management/services/auth/auth_services.dart';
import 'package:money_management/services/auth/token_services.dart';
import 'package:money_management/utils/custom_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthServices? _authServices; // Use nullable type initially
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
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

  Future<void> _submitRegisterForm() async {
    if (_formKey.currentState!.validate()) {
      Logger().i('Form valid, melakukan registrasi');
      setState(() {
        _isLoading = true;
      });
      try {
        final registerRequest = RegisterRequest(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
        Logger().i(registerRequest);

        final response = await _authServices!.register(registerRequest);
        if (response.isSuccessful) {
          final responseBody = response.body as Map<String, dynamic>;
          final authResponse = AuthResponse.fromJson(responseBody);
          final token = authResponse.token;
          Logger().i(token);
          showToast("registrasi aman, sekarang waktunya login gais");
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil("/login", (route) => false);
        } else {
          final errorResponse = response.error.toString();
          Logger().e('Error: $errorResponse');
          showToast("Registrasi gagal");
        }
      } catch (e) {
        Logger().e('Exception during registration: $e');
        showToast("Terjadi kesalahan saat registrasi");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Logger().w('Form tidak valid, tidak melakukan registrasi');
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
                  'Buat akun baru Anda',
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

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        validator: _validateName,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                        ), // Light text
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          labelStyle: const TextStyle(
                            color: Color(0xFF718096),
                          ), // Medium gray
                          hintText: 'Masukkan nama Anda',
                          hintStyle: const TextStyle(
                            color: Color(0xFF718096),
                          ), // Medium gray
                          prefixIcon: const Icon(
                            Icons.person_outline,
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

                      // Password Field
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
                            ),
                            color: const Color(0xFF718096), // Medium gray
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

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitRegisterForm,
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
                                  'Daftar', // Fixed button text from "Masuk" to "Daftar"
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
                      'Sudah punya akun? ',
                      style: TextStyle(color: Color(0xFF718096)), // Medium gray
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigasi ke halaman login
                        Logger().i('Navigasi ke halaman login');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64B6EE), // Light blue
                      ),
                      child: const Text(
                        'Masuk',
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

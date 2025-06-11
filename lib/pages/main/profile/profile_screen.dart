import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_management/core/color.dart';
import 'package:money_management/pages/main/profile/edit_proile_screen.dart';
import 'package:money_management/services/auth/token_services.dart';
import 'package:money_management/services/main/user_services.dart';
import 'package:money_management/utils/custom_toast.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Logger _logger = Logger();
  final TokenService _tokenService = TokenService();
  late UserServices _userServices;

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _logger.i("ProfileScreen initialized with userId: ${widget.userId}");
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _userServices = await UserServices.create();
      await _fetchUserProfile();
    } catch (e) {
      _logger.e("Error initializing services: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      _logger.d("Fetching profile for user ID: ${widget.userId}");
      final response = await _userServices.getUserProfile(widget.userId);
      _logger.d("Profile API response code: ${response.statusCode}");

      if (response.isSuccessful && response.body != null) {
        setState(() {
          _userData = response.body;
          _isLoading = false;
        });
        _logger.i("Profile fetched successfully");
      } else {
        _logger.e("Failed to fetch profile: ${response.error}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e("Error fetching profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Implement logout functionality
  void _handleLogout() async {
    _logger.i("Handling logout");
    await _tokenService.deleteToken();

    if (!mounted) return; // Check if the widget is still mounted
    _logger.i("Token deleted, navigating to login screen");
    showToast("Sukses logout");
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header with user info from API
                    _buildProfileHeader(context),

                    const SizedBox(height: 24),
                    // Account section
                    _buildSectionTitle('Akun'),
                    _buildMenuCard([
                      _buildMenuItem(
                        title: 'Informasi Pribadi',
                        icon: Icons.person_outline,
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        title: 'Keamanan',
                        icon: Icons.lock_outline,
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        title: 'Notifikasi',
                        icon: Icons.notifications_outlined,
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 24),
                    // Preferences section
                    _buildSectionTitle('Preferensi'),
                    _buildMenuCard([
                      _buildMenuItem(
                        title: 'Mata Uang',
                        icon: Icons.attach_money,
                        trailing: 'IDR (Rp)',
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        title: 'Bahasa',
                        icon: Icons.language,
                        trailing: 'Indonesia',
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        title: 'Tema',
                        icon: Icons.dark_mode_outlined,
                        trailing: 'Gelap',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 24),
                    // Data & Privacy section
                    _buildSectionTitle('Data & Privasi'),
                    _buildMenuCard([
                      _buildMenuItem(
                        title: 'Ekspor Data',
                        icon: Icons.upload_outlined,
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        title: 'Cadangan & Pulihkan',
                        icon: Icons.restore,
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        title: 'Hapus Data',
                        icon: Icons.delete_outline,
                        textColor: AppColors.dangerColor,
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 24),
                    // Help & Support section
                    _buildSectionTitle('Bantuan & Dukungan'),
                    _buildMenuCard([
                      _buildMenuItem(
                        title: 'Pusat Bantuan',
                        icon: Icons.help_outline,
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        title: 'Hubungi Kami',
                        icon: Icons.support_agent,
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        title: 'Tentang Aplikasi',
                        icon: Icons.info_outline,
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 24),
                    // Logout button - now connected to logout handler
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dangerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // Add the text widget as child
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'created by : alif | ali | jeki',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),

                    // App version
                    Center(
                      child: Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  // Profile header with user info
  Widget _buildProfileHeader(BuildContext context) {
    // The API response has a nested structure with 'user' object containing the basic info
    final user = _userData != null ? _userData!['user'] : null;
    final stats = _userData != null ? _userData!['stats'] : null;
    final wallet = _userData != null ? _userData!['wallet'] : null;

    // Extract user info with safe fallbacks
    final name = user != null ? user['name'] ?? 'User' : 'User';
    final email = user != null
        ? user['email'] ?? 'user@example.com'
        : 'user@example.com';
    final joinedSince = _userData != null
        ? _userData!['joinedSince']?.toString() ?? '0'
        : '0';

    // Get financial stats
    final income = stats != null ? stats['pemasukan']['total'] ?? 0 : 0;
    final expense = stats != null ? stats['pengeluaran']['total'] ?? 0 : 0;
    final balance = wallet != null ? wallet['totalBalance'] ?? 0 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User basic info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Profile picture
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),

              // User info from API
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bergabung sejak $joinedSince hari',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit profile button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(userData: user),
                    ),
                  ).then((_) => _fetchUserProfile());
                },
                icon: Icon(Icons.edit, color: AppColors.accentColor),
              ),
            ],
          ),
        ),

        // Stats Summary
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Balance Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo Saat Ini',
                    style: TextStyle(fontSize: 14, color: AppColors.textColor),
                  ),
                  Text(
                    'Rp ${_formatCurrency(balance)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Income/Expense Row
              Row(
                children: [
                  // Income indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pemasukan',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatCurrency(income)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expense indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatCurrency(expense)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
      ),
    );
  }

  // Card for menu items
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  // Individual menu item
  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    String? trailing,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: textColor ?? AppColors.accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor ?? AppColors.textColor,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryTextColor,
                ),
              )
            else
              Icon(Icons.chevron_right, color: AppColors.secondaryTextColor),
          ],
        ),
      ),
    );
  }

  // Divider between menu items
  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderColor,
      indent: 56,
    );
  }

  // Helper method to format currency
  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    // Change the variable name from 'num' to 'number'
    final number = value is num ? value : num.tryParse(value.toString()) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

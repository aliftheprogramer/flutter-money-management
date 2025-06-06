import 'package:flutter/material.dart';
import 'package:money_management/core/color.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, Map<String, dynamic>? userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController(
    text: 'John Doe',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'johndoe@example.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+62 812 3456 7890',
  );
  final TextEditingController _addressController = TextEditingController(
    text: 'Jakarta, Indonesia',
  );

  // State for profile image
  String? _profileImageUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          'Edit Profil',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Simpan',
              style: TextStyle(
                color: AppColors.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile picture section
            Center(
              child: Stack(
                children: [
                  // Profile image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accentColor,
                        width: 2,
                      ),
                    ),
                    child: _isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : _profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              _profileImageUrl!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              errorBuilder: (context, _, __) =>
                                  _buildProfileInitials(),
                            ),
                          )
                        : _buildProfileInitials(),
                  ),

                  // Edit icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Form fields
            _buildFormField(
              label: 'Nama Lengkap',
              controller: _nameController,
              icon: Icons.person_outline,
            ),

            _buildFormField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            _buildFormField(
              label: 'Nomor Telepon',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            _buildFormField(
              label: 'Alamat',
              controller: _addressController,
              icon: Icons.home_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 40),

            // Save button (large)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile initials
  Widget _buildProfileInitials() {
    return Center(child: Icon(Icons.person, size: 40, color: Colors.white));
  }

  // Helper method to build form fields
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: AppColors.textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.secondaryTextColor),
          prefixIcon: Icon(icon, color: AppColors.accentColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // Method to handle image picking
  void _pickImage() {
    // Set uploading state
    setState(() {
      _isUploading = true;
    });

    // Simulate delay for image selection/upload
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isUploading = false;
        // In a real app, you would update this with the actual image URL
        // _profileImageUrl = 'https://example.com/profile-image.jpg';
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Foto profil telah diperbarui'),
          backgroundColor: AppColors.successColor,
        ),
      );
    });
  }

  // Method to save profile changes
  void _saveProfile() {
    // In a real app, you would validate and save the data to your backend

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.accentColor),
      ),
    );

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      // Close loading dialog
      Navigator.pop(context);

      // Return to previous screen
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: AppColors.successColor,
        ),
      );
    });
  }
}

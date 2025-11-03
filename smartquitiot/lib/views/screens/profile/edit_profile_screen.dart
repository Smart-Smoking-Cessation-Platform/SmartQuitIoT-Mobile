import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SmartQuitIoT/viewmodels/user_view_model.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Editable fields controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // Avatar
  File? avatarImageFile;
  String? avatarUrl; // Current avatar URL from API
  final picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    // Load user profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userViewModelProvider.notifier).loadUserProfile();
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        avatarImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final dob = dobController.text.trim();

    // Validation
    if (firstName.isEmpty || lastName.isEmpty || dob.isEmpty) {
      _showFlushbar('Please fill all required fields', Colors.orange);
      return;
    }

    String finalAvatarUrl = avatarUrl ?? '';

    // Upload new avatar if selected
    if (avatarImageFile != null) {
      setState(() => _isUploadingAvatar = true);
      try {
        print('📸 [EditProfile] Uploading avatar...');
        finalAvatarUrl = await _cloudinaryService.uploadImage(avatarImageFile!);
        print('✅ [EditProfile] Avatar uploaded: $finalAvatarUrl');
      } catch (e) {
        setState(() => _isUploadingAvatar = false);
        _showFlushbar('Failed to upload avatar: $e', Colors.red);
        return;
      }
      setState(() => _isUploadingAvatar = false);
    }

    // Update profile
    await ref
        .read(userViewModelProvider.notifier)
        .updateUserProfile(
          firstName: firstName,
          lastName: lastName,
          dob: dob,
          avatarUrl: finalAvatarUrl,
        );

    if (mounted) {
      final error = ref.read(userViewModelProvider).error;
      if (error != null) {
        _showFlushbar('Error: $error', Colors.red);
      } else {
        _showFlushbar('Profile updated successfully!', const Color(0xFF00D09E));
        // Navigate to profile screen để user thấy thay đổi
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/profile');
          }
        });
      }
    }
  }

  void _showFlushbar(String message, Color backgroundColor) {
    Flushbar(
      message: message,
      icon: Icon(
        backgroundColor == Colors.red
            ? Icons.error_outline
            : Icons.check_circle,
        color: Colors.white,
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final user = userState.user;
    final isLoading = userState.isLoading;
    final isUpdating = userState.isUpdating;

    // Populate controllers when user data is loaded
    if (user != null && firstNameController.text.isEmpty) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      dobController.text = user.dob;
      avatarUrl = user.avatarUrl;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF1DD1A1), Color(0xFF00D09E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go('/profile'),
                    ),
                    const Expanded(
                      child: Text(
                        'Edit Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Avatar
              if (isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else
                GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: avatarImageFile != null
                              ? FileImage(avatarImageFile!) as ImageProvider
                              : (avatarUrl != null && avatarUrl!.isNotEmpty)
                              ? NetworkImage(avatarUrl!)
                              : const AssetImage(
                                      "lib/assets/images/profile.png",
                                    )
                                    as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Color(0xFF00D09E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00D09E),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Read-only section
                              const Text(
                                'Account Information (Read-only)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D09E),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Username (read-only)
                              _buildReadOnlyField(
                                'Username',
                                user?.account.username ?? '-',
                              ),
                              const SizedBox(height: 12),

                              // Email (read-only)
                              _buildReadOnlyField(
                                'Email',
                                user?.account.email ?? '-',
                              ),
                              const SizedBox(height: 12),

                              // Role (read-only)
                              _buildReadOnlyField(
                                'Role',
                                user?.account.role ?? '-',
                              ),
                              const SizedBox(height: 12),

                              // Gender (read-only)
                              _buildReadOnlyField(
                                'Gender',
                                user?.gender ?? '-',
                              ),
                              const SizedBox(height: 12),

                              // Age (read-only)
                              _buildReadOnlyField(
                                'Age',
                                user?.age.toString() ?? '-',
                              ),
                              const SizedBox(height: 25),

                              // Editable section
                              const Text(
                                'Personal Information (Editable)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D09E),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // First Name
                              TextFormField(
                                controller: firstNameController,
                                decoration: InputDecoration(
                                  labelText: "First Name *",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Last Name
                              TextFormField(
                                controller: lastNameController,
                                decoration: InputDecoration(
                                  labelText: "Last Name *",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Date of Birth
                              TextFormField(
                                controller: dobController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: InputDecoration(
                                  labelText: "Date of Birth *",
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Update Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (isUpdating || _isUploadingAvatar)
                                      ? null
                                      : _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00D09E),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    disabledBackgroundColor: Colors.grey[400],
                                  ),
                                  child: (isUpdating || _isUploadingAvatar)
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              "Updating...",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          "Update Profile",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

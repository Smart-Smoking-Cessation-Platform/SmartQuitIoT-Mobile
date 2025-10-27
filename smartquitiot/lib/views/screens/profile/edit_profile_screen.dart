import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/viewmodels/user_view_model.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final roleController = TextEditingController();
  final accountTypeController = TextEditingController();
  final createdAtController = TextEditingController();
  final activeController = TextEditingController();
  final firstLoginController = TextEditingController();
  final bannedController = TextEditingController();
  final usedFreeTrialController = TextEditingController();

  DateTime? _selectedDob; // <-- THÊM BIẾN LƯU NGÀY

  final CloudinaryService _cloudinary = CloudinaryService();
  File? avatarImage;
  String avatarUrl = '';
  bool isUploadingImage = false;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _loadUserData() {
    final userState = ref.read(userViewModelProvider);
    final user = userState.user;
    if (user == null) return;

    setState(() {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      genderController.text = user.gender;
      ageController.text = user.age.toString();
      dobController.text = _formatDateForDisplay(user.dob);
      avatarUrl = user.avatarUrl;

      // <-- THÊM LOGIC PARSE NGÀY GỐC
      try {
        _selectedDob = DateTime.parse(user.dob);
      } catch (_) {
        _selectedDob = null;
      }
      // -->

      emailController.text = user.account.email;
      roleController.text = user.account.role;
      accountTypeController.text = user.account.accountType;
      createdAtController.text = user.account.createdAt;
      activeController.text = user.account.active ? "Yes" : "No";
      firstLoginController.text = user.account.firstLogin ? "Yes" : "No";
      bannedController.text = user.account.banned ? "Yes" : "No";
      usedFreeTrialController.text = user.usedFreeTrial ? "Yes" : "No";
    });
  }

  String _formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString; // Trả về ngày gốc nếu không parse được
    }
  }

  bool get isFormValid =>
      firstNameController.text.isNotEmpty &&
      lastNameController.text.isNotEmpty &&
      dobController.text.isNotEmpty;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      avatarImage = File(pickedFile.path);
      isUploadingImage = true;
    });

    try {
      final uploadedUrl = await _cloudinary.uploadImage(avatarImage!);
      setState(() => avatarUrl = uploadedUrl);
      _showSnackBar("Image uploaded successfully!");
    } catch (e) {
      _showSnackBar("Upload failed: $e", isError: true);
    } finally {
      setState(() => isUploadingImage = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!isFormValid) {
      _showSnackBar("Please fill required fields", isError: true);
      return;
    }

    // <-- THÊM LOGIC CHUYỂN ĐỔI NGÀY
    String dobForApi;
    if (_selectedDob != null) {
      // Chuyển sang "YYYY-MM-DD"
      dobForApi = _selectedDob!.toIso8601String().split('T')[0];
    } else {
      _showSnackBar("Date of birth is invalid", isError: true);
      return;
    }
    // -->

    await ref
        .read(userViewModelProvider.notifier)
        .updateUserProfile(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          dob: dobForApi, // <-- GỬI NGÀY ĐÃ CHUẨN HÓA
          avatarUrl: avatarUrl,
        );

    if (mounted) {
      _showSnackBar("Profile updated successfully!");
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1DD1A1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      "Edit Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: avatarImage != null
                                  ? FileImage(avatarImage!)
                                  : avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage(
                                          "lib/assets/images/profile.png",
                                        )
                                        as ImageProvider,
                            ),
                            if (isUploadingImage)
                              const CircularProgressIndicator(
                                color: Colors.green,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      _buildTextField(firstNameController, "First Name"),
                      const SizedBox(height: 15),
                      _buildTextField(lastNameController, "Last Name"),
                      const SizedBox(height: 15),
                      // <-- YÊU CẦU CỦA BẠN: KHÓA TRƯỜNG GENDER
                      _buildTextField(
                        genderController,
                        "Gender",
                        enabled: false,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(ageController, "Age", enabled: false),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: dobController,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            // <-- SỬA LOGIC CHỌN NGÀY
                            initialDate: _selectedDob ?? DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            // <-- CẬP NHẬT BIẾN STATE
                            setState(() {
                              _selectedDob = picked;
                              dobController.text =
                                  "${picked.day}/${picked.month}/${picked.year}";
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Date of Birth",
                          filled: true,
                          fillColor: Colors.grey[100],
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ACCOUNT INFO
                      _buildTextField(emailController, "Email", enabled: false),
                      _buildTextField(roleController, "Role", enabled: false),
                      // _buildTextField(
                      //   accountTypeController,
                      //   "Account Type",
                      //   enabled: false,
                      // ),
                      // _buildTextField(
                      //   createdAtController,
                      //   "Created At",
                      //   enabled: false,
                      // ),
                      // _buildTextField(
                      //   activeController,
                      //   "Active",
                      //   enabled: false,
                      // ),
                      // _buildTextField(
                      //   firstLoginController,
                      //   "First Login",
                      //   enabled: false,
                      // ),
                      // _buildTextField(
                      //   bannedController,
                      //   "Banned",
                      //   enabled: false,
                      // ),
                      _buildTextField(
                        usedFreeTrialController,
                        "Used Free Trial",
                        enabled: false,
                      ),

                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: userState.isUpdating ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: userState.isUpdating
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Update Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController c,
    String label, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? Colors.grey[100] : const Color(0xFFF4F6FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

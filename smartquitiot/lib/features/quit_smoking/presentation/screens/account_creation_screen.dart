import 'package:flutter/material.dart';
import '../widgets/cloud_background.dart';
import '../widgets/grass_landscape.dart';
import '../widgets/albert_character.dart';
import '../widgets/jean_character.dart';
import '../widgets/speech_bubble.dart';

class AccountCreationScreen extends StatelessWidget {
  const AccountCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CloudBackground(
        child: Column(
          children: [
            // Top section with back button
            _buildTopSection(context),

            // Main content area with conversation
            Expanded(child: _buildMainContent(context)),

            // Bottom section with characters and button
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Back',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Butterfly icon
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange[400],
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.flutter_dash,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Albert's message
          Align(
            alignment: Alignment.centerRight,
            child: SpeechBubble(
              characterName: 'Albert',
              characterNameColor: Colors.green[400],
              text:
                  'Ready to start your journey with Kwit? Let\'s create your account first.',
              maxWidth: MediaQuery.of(context).size.width * 0.75,
              padding: const EdgeInsets.all(16),
              tailPointsLeft: false,
            ),
          ),

          const SizedBox(height: 20),

          // Jean's message
          Align(
            alignment: Alignment.centerLeft,
            child: SpeechBubble(
              characterName: 'Jean',
              characterNameColor: Colors.pink[400],
              text: 'I\'ll help you with that!',
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              padding: const EdgeInsets.all(16),
              tailPointsLeft: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return GrassLandscape(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Characters section
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Jean character (left)
                Positioned(
                  bottom: 80,
                  left: 60,
                  child: JeanCharacter(size: 100),
                ),

                // Albert character (right)
                Positioned(
                  bottom: 80,
                  right: 60,
                  child: AlbertCharacter(size: 120),
                ),
              ],
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to next screen or show account creation form
                  _showAccountCreationForm(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountCreationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField('Full Name', Icons.person),
                      const SizedBox(height: 16),
                      _buildTextField('Email', Icons.email),
                      const SizedBox(height: 16),
                      _buildTextField('Password', Icons.lock, isPassword: true),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Confirm Password',
                        Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),

                      // Create Account button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle account creation
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account created successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Navigate to dashboard
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/quit-smoking/dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[600]!),
        ),
      ),
    );
  }
}

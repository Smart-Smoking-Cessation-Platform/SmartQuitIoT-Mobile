import 'package:flutter/material.dart';
import '../widgets/cloud_background.dart';
import '../widgets/grass_landscape.dart';
import '../widgets/albert_character.dart';
import '../widgets/jean_character.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CloudBackground(
        child: Column(
          children: [
            // Top section with logo and back button
            _buildTopSection(context),

            // Main content area
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
            // Back button
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
            const Spacer(),
            // App logo and name
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smoke_free,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Kwit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main congratulatory message
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              children: [
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Quitting smoking is the best decision you have made in your life!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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

          // Action button
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Column(
              children: [
                // Main action button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to WHO validation screen
                      Navigator.of(context).pushNamed('/quit-smoking/who');
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
                      "Let's go!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sign in link
                TextButton(
                  onPressed: () {
                    // Navigate to sign in
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

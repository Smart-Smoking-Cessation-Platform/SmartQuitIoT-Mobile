import 'package:flutter/material.dart';
import '../widgets/cloud_background.dart';
import '../widgets/grass_landscape.dart';
import '../widgets/albert_character.dart';
import '../widgets/speech_bubble.dart';

class WhoValidationScreen extends StatelessWidget {
  const WhoValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CloudBackground(
        child: Column(
          children: [
            // Top section with back button
            _buildTopSection(context),

            // Main content area with speech bubble
            Expanded(child: _buildMainContent(context)),

            // Bottom section with character and button
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

          // Speech bubble with WHO information
          SpeechBubble(
            characterName: 'Albert',
            characterNameColor: Colors.green[400],
            text:
                'Kwit is the first mobile application validated and recommended by the World Health Organization!!',
            maxWidth: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
          ),

          const SizedBox(height: 20),

          // WHO logo and additional text
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // WHO logo placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Our program is based on years of behavioral science research. After 3 months, 84% of Kwitters are still non-smokers.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
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
          // Albert character with ruler
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Albert character
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(child: AlbertCharacter(size: 120)),
                ),

                // Ruler
                Positioned(
                  bottom: 140,
                  right: 80,
                  child: Container(
                    width: 8,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.yellow[600],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange[600]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Ruler markings
                        for (int i = 0; i < 8; i++) ...[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.orange[600]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: Colors.orange[600],
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
                  // Navigate to next screen
                  Navigator.of(context).pushNamed('/quit-smoking/account');
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
}

// screens/health_improvement_screen.dart
import 'package:flutter/material.dart';
import 'improvement_card.dart';

class HealthImprovementScreen extends StatelessWidget {
  const HealthImprovementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00E676),
              Color(0xFF00C853),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Health Improvements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.notifications, color: Colors.white, size: 24),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F8F0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ImprovementCard(
                          score: 100,
                          title: 'Heart Rate',
                          description: 'Your heart rate try to have heart rate from 60-100bpm',
                          isGood: true,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 100,
                          title: 'Oxygen Level',
                          description: 'Your oxygen levels should remain between 95% and 100%',
                          isGood: true,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 100,
                          title: 'Carbon monoxide',
                          description: 'Your carbon monoxide levels should be 0 or at safe concentration',
                          isGood: true,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 100,
                          title: 'Nicotine expelled from body',
                          description: 'All nicotine should have been expelled from your body',
                          isGood: true,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 100,
                          title: 'Taste and Smell',
                          description: 'Your ability to taste and smell should be much improved',
                          isGood: true,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 80,
                          title: 'Breathing',
                          description: 'It is those your lung capacity should have returned to normal',
                          isGood: false,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 65,
                          title: 'Energy level',
                          description: 'Your heart rate in a decline because low resistance to normal',
                          isGood: false,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 100,
                          title: 'Heart Rate',
                          description: 'It is likely your energy should have returned to normal',
                          isGood: true,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 17,
                          title: 'Addiction',
                          description: 'It is about the blood nicotine in your entire and brain should be zero',
                          isGood: false,
                        ),
                        SizedBox(height: 12),
                        ImprovementCard(
                          score: 2,
                          title: 'Circulation',
                          description: 'Your heart rate should have returned to normal',
                          isGood: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, false),
          _buildNavItem(Icons.favorite, false),
          _buildNavItem(Icons.directions_run, false),
          _buildNavItem(Icons.water_drop, true),
          _buildNavItem(Icons.person, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF00C853).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? Color(0xFF00C853) : Colors.grey,
        size: 24,
      ),
    );
  }
}
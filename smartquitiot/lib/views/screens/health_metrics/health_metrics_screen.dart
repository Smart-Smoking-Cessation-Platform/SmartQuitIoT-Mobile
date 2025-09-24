// screens/health_metrics_screen.dart
import 'package:flutter/material.dart';

import '../../widgets/cards/progress_card.dart';
import 'connect_button.dart';
import 'diary_metric_screen.dart';
import 'health_chart.dart';
import 'health_improvement_screen.dart';


class HealthMetricsScreen extends StatefulWidget {
  @override
  _HealthMetricsScreenState createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen>
    with TickerProviderStateMixin {
  bool isConnected = false;
  bool isConnecting = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _connectDevice() async {
    setState(() {
      isConnecting = true;
    });
    _animationController.repeat();

    // Simulate connection delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isConnecting = false;
      isConnected = true;
    });
    _animationController.stop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Kết nối thiết bị IoT thành công!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
                    Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    SizedBox(width: 16),
                    Text(
                      'Health Metrics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                        // Progress and Money Cards
                        ProgressCard(
                          title: '',
                          subtitle: '',
                          progress: 2.3,
                          progressText: '',
                          icon: Text("lib/assets/money.json"),
                        ),

                        SizedBox(height: 20),

                        // Connect Button
                        ConnectButton(
                          isConnected: isConnected,
                          isConnecting: isConnecting,
                          animationController: _animationController,
                          onPressed: _connectDevice,
                        ),
                        SizedBox(height: 20),

                        // Charts (only show when connected)
                        if (isConnected) ...[
                          HealthChart(
                            title: 'Sleep Hours',
                            onTap: () => _navigateToChart(context, 'Sleep'),
                          ),
                          SizedBox(height: 16),
                          HealthChart(
                            title: 'Heart Rate',
                            onTap: () => _navigateToChart(context, 'Heart Rate'),
                          ),
                          SizedBox(height: 16),
                          HealthChart(
                            title: 'Steps',
                            onTap: () => _navigateToChart(context, 'Steps'),
                          ),
                          SizedBox(height: 16),
                          HealthChart(
                            title: 'Confidence',
                            onTap: () => _navigateToChart(context, 'Confidence'),
                          ),
                        ],

                        // Health Improvement Button
                        SizedBox(height: 20),
                        _buildHealthImprovementButton(),
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

  Widget _buildHealthImprovementButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthImprovementScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00C853),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
        child: Text(
          'Xem đề xuất cải thiện sức khỏe',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
          _buildNavItem(Icons.home, true),
          _buildNavItem(Icons.favorite, false),
          _buildNavItem(Icons.directions_run, false),
          _buildNavItem(Icons.water_drop, false),
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

  void _navigateToChart(BuildContext context, String type) {
    if (type == 'Heart Rate') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryMetricsScreen(),
        ),
      );
    } else {
      // For other charts, you can create different screens or show different content
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang xem biểu đồ $type'),
          backgroundColor: Color(0xFF00C853),
        ),
      );
    }
  }
}
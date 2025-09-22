import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'info_card.dart'; // vẫn dùng InfoCard cũ của bạn

// Ba card mới thay cho ProfileHealthCard
class HeartRateCard extends StatelessWidget {
  const HeartRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.favorite, color: Colors.red, size: 32),
        SizedBox(height: 8),
        Text('HEART RATE', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text('72 bpm', style: TextStyle(color: Color(0xFF00D09E))),
      ],
    );
  }
}

class StepsCard extends StatelessWidget {
  const StepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.directions_walk, color: Colors.blue, size: 32),
        SizedBox(height: 8),
        Text('STEPS', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text('5,432 steps', style: TextStyle(color: Color(0xFF00D09E))),
      ],
    );
  }
}

class SleepCard extends StatelessWidget {
  const SleepCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.bedtime, color: Colors.purple, size: 32),
        SizedBox(height: 8),
        Text('SLEEP', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text('7h 30m', style: TextStyle(color: Color(0xFF00D09E))),
      ],
    );
  }
}

class StatsTableCard extends StatefulWidget {
  const StatsTableCard({super.key});

  @override
  State<StatsTableCard> createState() => _StatsTableCardState();
}

class _StatsTableCardState extends State<StatsTableCard> {
  final PageController _pageController = PageController(viewportFraction: 0.75);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách card riêng lẻ
    final List<Widget> cards = [
      _buildCard(
        child: InfoCard(
          icon: 'lib/assets/images/calendar.png',
          title: 'QUIT DAY',
          value: '1 Day',
        ),
      ),
      _buildCard(
        child: InfoCard(
          icon: 'lib/assets/images/salary.png',
          title: 'MONEY SAVED',
          value: '45,000 VND',
        ),
      ),
      _buildCard(
        child: InfoCard(
          icon: 'lib/assets/images/salary.png',
          title: 'ANNUAL SAVED',
          value: '500,000 VND',
        ),
      ),
      _buildCard(child: const HeartRateCard()),
      _buildCard(child: const StepsCard()),
      _buildCard(child: const SleepCard()),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15.0), // thụt vào 8px
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.zero, // loại bỏ padding mặc định nếu muốn
                      minimumSize: const Size(50, 30), // tuỳ chỉnh size nếu cần
                    ),
                    child: const Text(
                      'View More',
                      style: TextStyle(
                        color: Color(0xFF00D09E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // PageView swipe ngang
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: cards.length,
              itemBuilder: (context, index) => cards[index],
            ),
          ),
          const SizedBox(height: 12),

          // SmoothPageIndicator
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: cards.length,
              effect: ExpandingDotsEffect(
                activeDotColor: const Color(0xFF00D09E),
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm bọc Card style
  Widget _buildCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 180,
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    );
  }
}

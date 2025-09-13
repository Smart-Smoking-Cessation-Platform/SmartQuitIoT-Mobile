import 'package:flutter/material.dart';

class StatsTableCard extends StatelessWidget {
  const StatsTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View More',
                  style: TextStyle(
                    color: Color(0xFF00D09E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Grid using Column + Row + Expanded
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _card(
                      'lib/assets/calendar.png',
                      'QUIT DAY',
                      '1 Day',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _card(
                      'lib/assets/salary.png',
                      'MONEY SAVED',
                      '45,000 VND',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _card(
                      'lib/assets/salary.png',
                      'ANNUAL SAVED',
                      '500,000 VND',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _profileHealthCard()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(String? icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Image.asset(icon, width: 32, height: 32),
          if (icon != null) const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D09E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHealthCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset('lib/assets/user.png', width: 40, height: 40),
          const SizedBox(height: 10),
          _iconLabelValue('lib/assets/heart.png', '98 bpm'),
          const SizedBox(height: 6),
          _iconLabelValue('lib/assets/sleep.png', '1 Hour'),
          const SizedBox(height: 6),
          _iconLabelValue('lib/assets/shoe.png', '2,500 Steps'),
        ],
      ),
    );
  }

  Widget _iconLabelValue(String icon, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(icon, width: 18, height: 18),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00D09E),
          ),
        ),
      ],
    );
  }
}

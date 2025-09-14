import 'package:flutter/material.dart';
import 'payment_options_screen.dart';

class PremiumMembershipScreen extends StatelessWidget {
  const PremiumMembershipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Premium Membership',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Register membership for more features.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Membership Illustration
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Image.asset(
                  'lib/assets/membership.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Plans
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Annual Plan (đổi sang trắng chữ đen)
                  GestureDetector(
                    onTap: () => _navigateToPayment(context, 'annual'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Annual',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '900,000 VND/Year',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF333333,
                                  ).withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Best Value',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Monthly Plan (giữ nguyên trắng chữ đen)
                  GestureDetector(
                    onTap: () => _navigateToPayment(context, 'monthly'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '99,000 VND/Month',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF333333,
                                  ).withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Free Trial (đổi sang trắng chữ đen)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Free trial 7 days',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Terms
                  Text(
                    'By placing this order, you agree to the Terms of Service and Privacy Policy. Subscription automatically renews unless auto-renewal is turned off at least 24-hours before the end of the current period.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Home Indicator
            Center(
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment(BuildContext context, String plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentOptionsScreen(selectedPlan: plan),
      ),
    );
  }
}

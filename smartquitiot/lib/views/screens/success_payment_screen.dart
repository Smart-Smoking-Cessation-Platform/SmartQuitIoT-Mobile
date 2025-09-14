import 'package:flutter/material.dart';
import 'premium_membership_screen.dart';
import '../widgets/receipt_bottom_sheet.dart';

class SuccessScreen extends StatefulWidget {
  final String selectedPlan;
  final String paymentMethod;

  const SuccessScreen({
    Key? key,
    required this.selectedPlan,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planPrice = widget.selectedPlan == 'annual'
        ? '900,000 VND'
        : '99,000 VND';
    final paymentTitle = _getPaymentTitle(widget.paymentMethod);

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 18,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Success Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Animation
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: AnimatedBuilder(
                              animation: _checkAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _checkAnimation.value,
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Color(0xFF4CAF50),
                                    size: 60,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Success Message
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            children: [
                              const Text(
                                'Payment Successful!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your premium membership has been activated successfully.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Payment Details Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  children: [
                                    _buildRow(
                                      'Plan:',
                                      widget.selectedPlan == 'annual'
                                          ? 'Annual'
                                          : 'Monthly',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildRow('Amount:', planPrice),
                                    const SizedBox(height: 12),
                                    _buildRow('Method:', paymentTitle),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Continue Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _navigateToHome(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // View Receipt Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _showReceipt(context),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Receipt',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Home Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getPaymentTitle(String method) {
    switch (method) {
      case 'momo':
        return 'MoMo';
      case 'banking':
        return 'Internet Banking';
      case 'zalopay':
        return 'ZaloPay';
      default:
        return 'Payment';
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PremiumMembershipScreen()),
    );
  }

  void _showReceipt(BuildContext context) {
    final plan = widget.selectedPlan == 'annual' ? 'Annual' : 'Monthly';
    final amount = widget.selectedPlan == 'annual'
        ? '900,000 VND'
        : '99,000 VND';
    final method = _getPaymentTitle(widget.paymentMethod);
    final transactionId = 'PAY${DateTime.now().millisecondsSinceEpoch}';
    final date = DateTime.now().toString().substring(0, 19);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ReceiptBottomSheet(
          plan: plan,
          amount: amount,
          method: method,
          transactionId: transactionId,
          date: date,
        );
      },
    );
  }
}

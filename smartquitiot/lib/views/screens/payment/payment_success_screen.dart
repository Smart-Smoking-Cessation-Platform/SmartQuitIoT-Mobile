import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String? code;
  final String? id;
  final String? status;
  final String? cancel;
  final String? orderCode;
  final String? packageName;
  final String? amount;
  final String? startDate;
  final String? endDate;

  const PaymentSuccessScreen({
    super.key,
    this.code,
    this.id,
    this.status,
    this.cancel,
    this.orderCode,
    this.packageName,
    this.amount,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    // Get data from constructor or ModalRoute
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final displayOrderCode = orderCode ?? args?['orderCode'] ?? '';
    final displayPackageName = packageName ?? args?['packageName'] ?? 'Premium Package';
    final displayAmount = amount ?? args?['amount'] ?? '0';
    final displayStartDate = startDate ?? args?['startDate'] ?? '';
    final displayEndDate = endDate ?? args?['endDate'] ?? '';

    // Format amount
    String formattedAmount = '0';
    try {
      final amountInt = int.tryParse(displayAmount) ?? 0;
      formattedAmount = NumberFormat('#,###', 'vi_VN').format(amountInt);
    } catch (e) {
      formattedAmount = displayAmount;
    }

    // Format dates
    String formattedStartDate = '';
    String formattedEndDate = '';
    try {
      if (displayStartDate.isNotEmpty) {
        final startDateTime = DateTime.parse(displayStartDate);
        formattedStartDate = DateFormat('dd/MM/yyyy').format(startDateTime);
      }
      if (displayEndDate.isNotEmpty) {
        final endDateTime = DateTime.parse(displayEndDate);
        formattedEndDate = DateFormat('dd/MM/yyyy').format(endDateTime);
      }
    } catch (e) {
      formattedStartDate = displayStartDate;
      formattedEndDate = displayEndDate;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Icon
                      Container(
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
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF4CAF50),
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Title
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
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              icon: Icons.workspace_premium,
                              title: 'Package',
                              value: displayPackageName,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              icon: Icons.attach_money,
                              title: 'Amount',
                              value: '$formattedAmount VND',
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              icon: Icons.receipt_long,
                              title: 'Order Code',
                              value: displayOrderCode,
                            ),
                            if (formattedStartDate.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.calendar_today,
                                title: 'Start Date',
                                value: formattedStartDate,
                              ),
                            ],
                            if (formattedEndDate.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.event_available,
                                title: 'End Date',
                                value: formattedEndDate,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/main');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00D09E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00D09E), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

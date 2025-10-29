import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String? code;
  final String? id;
  final String? status;
  final String? cancel;

  const PaymentSuccessScreen({
    super.key,
    this.code,
    this.id,
    this.status,
    this.cancel,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu không truyền từ constructor thì nhận qua ModalRoute
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final displayCode = code ?? args?['code'] ?? '';
    final displayId = id ?? args?['id'] ?? '';
    final displayStatus = status ?? args?['status'] ?? '';
    final displayCancel = cancel ?? args?['cancel'] ?? '';
    final orderCode = args?['orderCode'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00D09E), size: 100),
              const SizedBox(height: 20),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Code: $displayCode\nStatus: $displayStatus\nOrder ID: $displayId\nOrder Code: $orderCode\n Cancel: $displayCancel',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/main');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

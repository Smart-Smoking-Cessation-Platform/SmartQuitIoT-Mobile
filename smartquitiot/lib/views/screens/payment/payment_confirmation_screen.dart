import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/payment_link_data.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final PaymentLinkData paymentData;

  const PaymentConfirmationScreen({super.key, required this.paymentData});

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $url')),
      );
    }
  }


  String _formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'), // Translated
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Scan VietQR Code to Pay', // Translated
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: paymentData.qrCode,
                version: QrVersions.auto,
                size: 240.0,
                gapless: false,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Description', paymentData.description), // Translated
                  const Divider(height: 24),
                  _buildInfoRow('Amount', _formatCurrency(paymentData.amount)), // Translated
                  const Divider(height: 24),
                  _buildInfoRow('Order Code', paymentData.orderCode.toString()), // Translated
                  const Divider(height: 24),
                  _buildInfoRow('Account Name', paymentData.accountName, isHighlight: false), // Translated
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'or', // Translated
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('Open with Web/Banking App'), // Translated
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _launchURL(context, paymentData.checkoutUrl);
                },
              ),
            ),
            const SizedBox(height: 32),
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton.icon(
            //     icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
            //     label: const Text(
            //       'Cancel Payment',
            //       style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            //     ),
            //     style: OutlinedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       side: const BorderSide(color: Colors.redAccent),
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            //     ),
            //     onPressed: () {
            //       // // ✅ Nếu bạn muốn chỉ quay về
            //       // Navigator.pop(context);
            //       // ✅ Nếu bạn muốn gọi API BE để cancel thật:
            //
            //       ref.read(paymentViewModelProvider.notifier).cancelPayment(paymentData.orderCode);
            //     },
            //   ),
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.red.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please keep this screen open until you receive a successful payment confirmation.', // Translated
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/membership_provider.dart';
import '../../../models/membership_subscription.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
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
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  MembershipSubscription? _subscription;
  bool _isProcessingApi = true;
  bool _isNavigating = false;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is ready and avoid crash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _processPaymentApi();
      }
    });
  }

  Future<void> _processPaymentApi() async {
    try {
      print('🔄 [PaymentSuccess] Payment already processed by backend webhook');
      print(
        '🔄 [PaymentSuccess] Fetching current membership to unlock features...',
      );

      // Backend webhook already processed payment and updated database
      // We just need to fetch current subscription to get full details and unlock features
      await Future.delayed(const Duration(seconds: 1)); // Small delay for UX

      // Trigger fetch (returns void, updates provider state)
      await ref
          .read(currentSubscriptionProvider.notifier)
          .fetchCurrentSubscription();

      // Read subscription from provider state
      final subscriptionAsync = ref.read(currentSubscriptionProvider);
      final subscription = subscriptionAsync.value;

      print('✅ [PaymentSuccess] Membership fetched successfully');
      print(
        '📊 [PaymentSuccess] Package: ${subscription?.membershipPackage?.name}',
      );

      if (mounted) {
        setState(() {
          _subscription = subscription;
          _isProcessingApi = false;
        });
        print('✅ [PaymentSuccess] UI updated with success state');
      }
    } catch (e, stackTrace) {
      print('❌ [PaymentSuccess] Error fetching membership: $e');
      print('🧩 [PaymentSuccess] Stack trace: $stackTrace');

      // Even if fetch fails, payment was successful (shown in UI)
      // User can manually refresh or restart app
      if (mounted) {
        setState(() {
          _apiError =
              'Could not fetch membership details. Please restart the app to see your premium features.';
          _isProcessingApi = false;
        });
      }
    }
  }

  Future<void> _refreshMembershipWithTimeout() async {
    try {
      await ref
          .read(currentSubscriptionProvider.notifier)
          .fetchCurrentSubscription()
          .timeout(const Duration(seconds: 5));
      print('✅ [PaymentSuccess] Membership refreshed before navigation');
    } on TimeoutException catch (e) {
      print('⚠️ [PaymentSuccess] Membership refresh timeout: $e');
    } catch (e) {
      print('⚠️ [PaymentSuccess] Membership refresh skipped: $e');
    }
  }

  Future<void> _handleNavigateHome() async {
    if (_isNavigating || !mounted) return;

    setState(() {
      _isNavigating = true;
    });

    await _refreshMembershipWithTimeout();
    if (!mounted) return;

    var navigated = false;
    try {
      context.go('/main');
      navigated = true;
    } catch (e, stack) {
      print('❌ [PaymentSuccess] Navigation error: $e');
      print('🧩 [PaymentSuccess] Stack trace: $stack');
    } finally {
      if (!navigated && mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get data from constructor or ModalRoute
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Get PayOS params
    final displayCode = widget.code ?? args?['code']?.toString() ?? '';
    final displayId = widget.id ?? args?['id']?.toString() ?? '';
    final displayStatus = widget.status ?? args?['status']?.toString() ?? '';
    final displayOrderCode =
        widget.orderCode ?? args?['orderCode']?.toString() ?? '';

    // Optional fields - prefer API data from subscription, fallback to params
    final displayPackageName =
        _subscription?.membershipPackage?.name ??
        widget.packageName ??
        args?['packageName']?.toString() ??
        'Premium Membership';
    final displayAmount =
        _subscription?.totalAmount?.toString() ??
        widget.amount ??
        args?['amount']?.toString() ??
        '';
    final displayStartDate =
        _subscription?.startDate?.toString() ??
        widget.startDate ??
        args?['startDate']?.toString() ??
        '';
    final displayEndDate =
        _subscription?.endDate?.toString() ??
        widget.endDate ??
        args?['endDate']?.toString() ??
        '';

    // Format amount if available
    String formattedAmount = '';
    if (displayAmount.isNotEmpty) {
      try {
        final amountInt = int.tryParse(displayAmount) ?? 0;
        formattedAmount = NumberFormat('#,###', 'vi_VN').format(amountInt);
      } catch (e) {
        formattedAmount = displayAmount;
      }
    }

    // Format dates if available
    String formattedStartDate = '';
    String formattedEndDate = '';
    if (displayStartDate.isNotEmpty) {
      try {
        final startDateTime = DateTime.parse(displayStartDate);
        formattedStartDate = DateFormat('dd/MM/yyyy').format(startDateTime);
      } catch (e) {
        formattedStartDate = displayStartDate;
      }
    }
    if (displayEndDate.isNotEmpty) {
      try {
        final endDateTime = DateTime.parse(displayEndDate);
        formattedEndDate = DateFormat('dd/MM/yyyy').format(endDateTime);
      } catch (e) {
        formattedEndDate = displayEndDate;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon or Loading
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
                    child: _isProcessingApi
                        ? const Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF00D09E),
                              ),
                            ),
                          )
                        : Icon(
                            _apiError != null
                                ? Icons.warning_rounded
                                : Icons.check_rounded,
                            color: _apiError != null
                                ? Colors.orange
                                : const Color(0xFF4CAF50),
                            size: 60,
                          ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    _isProcessingApi
                        ? 'Processing Payment...'
                        : _apiError != null
                        ? 'Payment Received'
                        : 'Payment Successful!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isProcessingApi
                        ? 'Please wait while we confirm your payment with the server...'
                        : _apiError != null
                        ? 'Payment received. Your membership will be activated shortly.'
                        : 'Your premium membership has been activated successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  if (_apiError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '⚠️ API Connection Issue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your payment was successful, but we couldn\'t update your membership status. Please contact support or try refreshing.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Error: ${_apiError?.split(':').first ?? 'Unknown error'}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          icon: Icons.check_circle,
                          title: 'Status',
                          value: displayStatus.toUpperCase(),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.receipt_long,
                          title: 'Order Code',
                          value: displayOrderCode,
                        ),
                        if (displayCode.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.qr_code,
                            title: 'Payment Code',
                            value: displayCode,
                          ),
                        ],
                        if (displayId.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.fingerprint,
                            title: 'Transaction ID',
                            value: displayId,
                          ),
                        ],
                        if (formattedAmount.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.attach_money,
                            title: 'Amount',
                            value: '$formattedAmount VND',
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.workspace_premium,
                          title: 'Package',
                          value: displayPackageName,
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
                      onPressed: (_isProcessingApi || _isNavigating)
                          ? null
                          : _handleNavigateHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        disabledBackgroundColor: Colors.white.withOpacity(0.5),
                      ),
                      child: (_isProcessingApi || _isNavigating)
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black54,
                                ),
                              ),
                            )
                          : const Text(
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

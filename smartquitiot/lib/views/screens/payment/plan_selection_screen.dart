// lib/views/membership/plan_selection_screen.dart
import 'package:SmartQuitIoT/views/screens/payment/payment_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/plan_option.dart';
import '../../../providers/membership_provider.dart';

class PlanSelectionScreen extends ConsumerStatefulWidget {
  final int packageId;
  final String packageName;

  const PlanSelectionScreen({
    super.key,
    required this.packageId,
    required this.packageName,
  });

  @override
  ConsumerState<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends ConsumerState<PlanSelectionScreen> {
  int _selectedPlanIndex = 0;
  bool _isProcessingPayment = false;

  String _formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  Future<void> _proceedToPayment(List<PlanOption> plans) async {
    if (_isProcessingPayment) return;

    setState(() {
      _isProcessingPayment = true;
    });

    final selectedPlan = plans[_selectedPlanIndex];

    try {
      final paymentData = await ref.read(membershipViewModelProvider.notifier).createPaymentLink(
        packageId: widget.packageId,
        duration: selectedPlan.planDuration,
      );

      if (mounted && paymentData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentConfirmationScreen(paymentData: paymentData),
          ),
        );
      } else {
        // Xử lý lỗi
      }
    } catch (e) {
      // Xử lý lỗi
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsyncValue = ref.watch(planOptionsProvider(widget.packageId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn kỳ hạn cho gói ${widget.packageName}'),
        backgroundColor: const Color(0xFF00D09E),
      ),
      body: plansAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (plans) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final isSelected = index == _selectedPlanIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlanIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.teal.shade100 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF00D09E) : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: const Color(0xFF00D09E),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${plan.planDuration} ${plan.planDurationUnit.toLowerCase()}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCurrency(plan.planPrice),
                                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D09E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isProcessingPayment ? null : () => _proceedToPayment(plans),
                    child: _isProcessingPayment
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                        : const Text('Tiếp tục thanh toán', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
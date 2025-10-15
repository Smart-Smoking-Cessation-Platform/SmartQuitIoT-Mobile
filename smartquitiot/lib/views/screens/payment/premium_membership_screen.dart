import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/state/membership_state.dart';
import '../../../providers/membership_provider.dart';
// SỬA Ở ĐÂY: Import màn hình chọn kỳ hạn
import 'plan_selection_screen.dart';
// import 'payment_options_screen.dart'; // Dòng này có thể không cần nữa

class PremiumMembershipScreen extends ConsumerWidget {
  const PremiumMembershipScreen({super.key});

  String _formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(membershipViewModelProvider);
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(membershipViewModelProvider.notifier).fetchMembershipPackages();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Premium Membership', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Register membership for more features.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
              ),

              // Membership Illustration
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Image.asset('lib/assets/images/membership.png', width: 300, height: 300, fit: BoxFit.contain)),
              ),

              // Plans section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Builder(
                  builder: (_) {
                    if (state == ViewState.loading) {
                      return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(color: Colors.white)));
                    } else if (state == ViewState.error) {
                      return Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Text(viewModel.errorMessage, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)));
                    } else if (state == ViewState.success && viewModel.packages.isNotEmpty) {
                      return Column(
                        children: viewModel.packages.map((pkg) {
                          final isFree = pkg.price == 0;
                          final isPremium = pkg.type.toUpperCase() == 'PREMIUM';

                          final mainTextColor = isPremium ? Colors.white : const Color(0xFF333333);
                          final subTextColor = isPremium ? Colors.white.withOpacity(0.8) : const Color(0xFF333333).withOpacity(0.7);
                          final dividerColor = isPremium ? Colors.white.withOpacity(0.3) : Colors.black12;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  gradient: isPremium
                                      ? const LinearGradient(
                                    colors: [Color(0xFFBF953F), Color(0xFFFCF6BA), Color(0xFFB38728), Color(0xFFFBF5B7), Color(0xFFAA771C)],
                                    begin: Alignment(-1.5, -1.5),
                                    end: Alignment(1.5, 1.5),
                                  )
                                      : null,
                                  image: isPremium
                                      ? const DecorationImage(
                                    image: AssetImage('lib/assets/images/card_pattern.png'),
                                    fit: BoxFit.cover,
                                    opacity: 0.05,
                                  )
                                      : null,
                                  color: isPremium ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    // SỬA Ở ĐÂY: Gọi hàm điều hướng mới
                                    onTap: isFree ? null : () => _navigateToPlanSelection(context, pkg.id, pkg.name),
                                    child: Stack(
                                      children: [
                                        if (isPremium) _buildGlossySheen(),
                                        Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(pkg.name, style: TextStyle(color: mainTextColor, fontSize: 22, fontWeight: FontWeight.bold, shadows: isPremium ? [const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1,1))] : [])),
                                                        const SizedBox(height: 4),
                                                        Text(pkg.description, style: TextStyle(color: subTextColor, fontSize: 16, fontStyle: FontStyle.italic)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                isFree ? 'Free trial for ${pkg.duration} days' : '${_formatCurrency(pkg.price)} / ${pkg.durationUnit.toLowerCase()}',
                                                style: TextStyle(color: mainTextColor, fontSize: isFree ? 16 : 24, fontWeight: FontWeight.w900, shadows: isPremium ? [const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1,1))] : []),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                child: Divider(height: 1, color: dividerColor),
                                              ),
                                              _buildFeatureList(pkg.features, isPremium: isPremium),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    } else {
                      return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('No membership packages available.', style: TextStyle(color: Colors.white))));
                    }
                  },
                ),
              ),

              // Terms
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Text(
                  'By placing this order, you agree to the Terms of Service and Privacy Policy. Subscription automatically renews unless auto-renewal is turned off at least 24-hours before the end of the current period.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.4),
                ),
              ),

              // Home Indicator
              Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList(List<String> features, {required bool isPremium}) {
    final featureColor = isPremium ? Colors.white : const Color(0xFF4A4A4A);
    final iconColor = isPremium ? Colors.white : const Color(0xFF00D09E);
    final textShadow = isPremium ? [const Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(1,1))] : <Shadow>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: iconColor, size: 20, shadows: textShadow),
              const SizedBox(width: 12),
              Expanded(child: Text(feature, style: TextStyle(color: featureColor, fontSize: 15, height: 1.4, shadows: textShadow))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGlossySheen() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Transform.translate(
          offset: const Offset(-80, -120),
          child: Transform.rotate(
            angle: -pi / 6,
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // SỬA Ở ĐÂY: Thay thế hàm cũ bằng hàm điều hướng mới
  void _navigateToPlanSelection(BuildContext context, int packageId, String packageName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanSelectionScreen(
          packageId: packageId,
          packageName: packageName,
        ),
      ),
    );
  }
}
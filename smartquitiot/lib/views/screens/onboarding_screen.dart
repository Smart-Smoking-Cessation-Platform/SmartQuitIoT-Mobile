import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      title: 'Welcome To SmartQuit',
      subtitle: 'Are You Ready To Save Your Life?',
    ),
    _OnboardPage(
      title: 'Let’s talk…',
      subtitle: 'Tell us about your smoking habits',
      overlayAsset: 'lib/assets/Group.png',
      secondaryAsset:
          'lib/assets/bank-card-mobile-phone-online-payment-removebg-preview 1.png',
    ),
    _OnboardPage(
      title: 'Stay Motivated',
      subtitle: 'Tips, achievements and progress every day',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // After 2-C, show 1-A Launch (1).png briefly, then go to Home
      Navigator.of(context).pushReplacementNamed('/relaunch');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFDADCE0),
      body: SafeArea(
        child: Column(
          children: [
            // Header with title on brand color
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _pages[_index].title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_index == 0)
                    Image.asset('lib/assets/Group.png', width: 56, height: 56),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (p.overlayAsset != null)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Image.asset(
                                        p.overlayAsset!,
                                        width: 72,
                                        height: 72,
                                      ),
                                    ),
                                  ),
                                if (p.secondaryAsset != null)
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      child: Image.asset(
                                        p.secondaryAsset!,
                                        width: 200,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                if (p.secondaryAsset == null)
                                  Icon(
                                    Icons.smoke_free,
                                    size: 120,
                                    color: scheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (dot) {
                          final bool active = dot == _index;
                          return Container(
                            width: active ? 10 : 8,
                            height: active ? 10 : 8,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active ? Colors.white : Colors.white70,
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          child: Text(
                            _index == _pages.length - 1 ? 'Start' : 'Next',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String title;
  final String subtitle;
  final String? overlayAsset;
  final String? secondaryAsset;
  const _OnboardPage({
    required this.title,
    required this.subtitle,
    this.overlayAsset,
    this.secondaryAsset,
  });
}

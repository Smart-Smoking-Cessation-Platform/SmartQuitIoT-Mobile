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
      icon: Icons.smoke_free,
    ),
    _OnboardPage(
      title: 'Tell Us About You',
      subtitle: 'Answer questions to help us understand you clearly',
      icon: Icons.health_and_safety_outlined,
    ),
    _OnboardPage(
      title: 'Stay Motivated',
      subtitle: 'Tips, achievements and progress every day',
      icon: Icons.emoji_events_outlined,
    ),
    _OnboardPage(
      title: 'Let’s Get Started',
      subtitle: 'Create your plan to quit smoking now',
      icon: Icons.flag_circle_outlined,
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
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _pages[_index].title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: scheme.onPrimary),
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
                      const SizedBox(height: 32),
                      // Use provided assets when available; fallback to icon
                      Icon(p.icon, size: 120, color: scheme.primary),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Spacer(),
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
                              color: active
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: ElevatedButton(
                          onPressed: _next,
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
  final IconData icon;
  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

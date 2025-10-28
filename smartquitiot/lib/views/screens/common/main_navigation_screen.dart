import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievements_card.dart';
import 'package:SmartQuitIoT/views/screens/appointments/coach_appointment_card.dart';
import 'package:SmartQuitIoT/views/screens/common/membership_shortcut_card.dart';
import 'package:SmartQuitIoT/views/widgets/headers/home_header.dart';
import 'package:SmartQuitIoT/views/widgets/cards/smoke_free_timer_card.dart';
import 'package:SmartQuitIoT/views/screens/stats_table/stats_table_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/health_improvement_card.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_card.dart';
import 'package:SmartQuitIoT/views/screens/missions/today_mission_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/community_trending_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/recent_news_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/diary_record_card.dart';

import 'package:SmartQuitIoT/views/screens/coach_chat/chat_screen.dart';
import 'package:SmartQuitIoT/views/screens/diary/diary_screen.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_screen.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievement_screen.dart';
import 'package:SmartQuitIoT/views/screens/leaderboard/leaderboard_screen.dart';
import '../../../providers/membership_provider.dart';
import '../../../models/membership_subscription.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  /// Danh sách các màn hình con
  List<Widget> _buildScreens(MembershipSubscription? subscription) {
    return [
      _buildHomeContent(subscription), // 👈 trang home chính
      const ChatScreen(),
      _buildProtectedScreen(
        subscription,
        const DiaryScreen(),
        'Metrics Tracking',
      ),
      _buildProtectedScreen(
        subscription,
        const QuitPlanScreen(),
        'Smart Quit Plan',
      ),
      const AchievementScreen(),
      const LeaderboardScreen(),
    ];
  }

  final List<String> lottiePaths = [
    'lib/assets/animations/home.json',
    'lib/assets/animations/chat.json',
    'lib/assets/animations/diary.json',
    'lib/assets/animations/craving.json',
    'lib/assets/animations/trophy.json',
    'lib/assets/animations/leaderboard.json',
  ];

  final List<String> lottieLabels = [
    'home',
    'chat',
    'diary',
    'craving',
    'achievements',
    'leaderboard',
  ];

  /// Helper method to check if user has specific feature
  bool _hasFeature(MembershipSubscription? subscription, String featureName) {
    if (subscription?.membershipPackage?.features == null) return false;
    return subscription!.membershipPackage!.features.any(
      (feature) => feature.toLowerCase().contains(featureName.toLowerCase()),
    );
  }

  /// Build protected screen - navigate to premium if no access
  Widget _buildProtectedScreen(
    MembershipSubscription? subscription,
    Widget screen,
    String requiredFeature,
  ) {
    if (_hasFeature(subscription, requiredFeature)) {
      return screen;
    }

    // Show premium upgrade screen if no access
    return _buildUpgradePrompt(requiredFeature);
  }

  /// Build upgrade prompt screen
  Widget _buildUpgradePrompt(String featureName) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Color(0xFF00D09E),
                ),
                const SizedBox(height: 24),
                Text(
                  'Premium Feature',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You need "$featureName" feature to access this section.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.push('/membership');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Upgrade to Premium',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hàm build riêng cho trang Home
  Widget _buildHomeContent(MembershipSubscription? subscription) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              const HomeHeader(),
              const SmokeFreeTimerCard(),
              const MembershipShortcutCard(),

              // Metrics Tracking features
              if (_hasFeature(subscription, 'Metrics Tracking')) ...[
                const DiaryRecordCard(),
                const StatsTableCard(),
                const HealthImprovementCard(),
              ],

              // Guides by Coach feature
              if (_hasFeature(subscription, 'Guides by Coach'))
                const CoachAppointmentCard(),

              const AchievementsCard(),

              // Smart Quit Plan feature
              if (_hasFeature(subscription, 'Smart Quit Plan'))
                const QuitPlanCard(),

              // Missions feature
              if (_hasFeature(subscription, 'Missions'))
                const TodayMissionCard(),

              // Always show these
              const CommunityTrendingCard(),
              const RecentNewsCard(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Check AI Personalize Chat feature
          if (_hasFeature(subscription, 'AI Personalize Chat')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiChatWelcomeScreen()),
            );
          } else {
            // Navigate to premium screen
            context.push('/membership');
          }
        },
        backgroundColor: const Color(0xFF00D09E),
        elevation: 8,
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(currentSubscriptionProvider);

    return subscriptionAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading membership: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentSubscriptionProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (subscription) {
        final screens = _buildScreens(subscription);
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF00D09E),
            unselectedItemColor: Colors.grey,
            currentIndex: _currentIndex,
            onTap: (index) {
              // Special handling for protected tabs
              if (index == 2) {
                // Diary tab - requires Metrics Tracking
                if (!_hasFeature(subscription, 'Metrics Tracking')) {
                  context.push('/membership');
                  return;
                }
              } else if (index == 3) {
                // Quit Plan tab - requires Smart Quit Plan or Missions
                if (!_hasFeature(subscription, 'Smart Quit Plan') &&
                    !_hasFeature(subscription, 'Missions')) {
                  context.push('/membership');
                  return;
                }
              }
              setState(() => _currentIndex = index);
            },
            items: List.generate(lottiePaths.length, (index) {
              return BottomNavigationBarItem(
                icon: SizedBox(
                  height: 30,
                  width: 30,
                  child: Lottie.asset(
                    lottiePaths[index],
                    animate: _currentIndex == index,
                  ),
                ),
                label: lottieLabels[index].tr(),
              );
            }),
          ),
        );
      },
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/quit_smoking.dart';
import '../../domain/models/onboarding_step.dart';

final quitSmokingControllerProvider =
    StateNotifierProvider<QuitSmokingController, QuitSmokingState>((ref) {
      return QuitSmokingController();
    });

class QuitSmokingController extends StateNotifier<QuitSmokingState> {
  QuitSmokingController() : super(QuitSmokingState.initial());

  void startQuitJourney() {
    state = state.copyWith(
      quitSmoking: QuitSmoking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startDate: DateTime.now(),
        isActive: true,
        daysSmokeFree: 0,
      ),
    );
  }

  void completeOnboardingStep(OnboardingStepType stepType) {
    final updatedSteps = state.onboardingSteps.map((step) {
      if (step.type == stepType) {
        return step.copyWith(isCompleted: true);
      }
      return step;
    }).toList();

    state = state.copyWith(onboardingSteps: updatedSteps);
  }

  void resetJourney() {
    state = QuitSmokingState.initial();
  }
}

class QuitSmokingState {
  final QuitSmoking? quitSmoking;
  final List<OnboardingStep> onboardingSteps;
  final bool isLoading;

  const QuitSmokingState({
    this.quitSmoking,
    required this.onboardingSteps,
    this.isLoading = false,
  });

  factory QuitSmokingState.initial() {
    return QuitSmokingState(
      onboardingSteps: [
        const OnboardingStep(
          type: OnboardingStepType.welcome,
          title: 'Welcome',
          message:
              'Congratulations! Quitting smoking is the best decision you have made in your life!',
          characterName: null,
        ),
        const OnboardingStep(
          type: OnboardingStepType.whoValidation,
          title: 'WHO Validation',
          message:
              'Kwit is the first mobile application validated and recommended by the World Health Organization!',
          characterName: 'Albert',
        ),
        const OnboardingStep(
          type: OnboardingStepType.accountCreation,
          title: 'Account Creation',
          message:
              'Ready to start your journey with Kwit? Let\'s create your account first.',
          characterName: 'Albert',
        ),
      ],
    );
  }

  QuitSmokingState copyWith({
    QuitSmoking? quitSmoking,
    List<OnboardingStep>? onboardingSteps,
    bool? isLoading,
  }) {
    return QuitSmokingState(
      quitSmoking: quitSmoking ?? this.quitSmoking,
      onboardingSteps: onboardingSteps ?? this.onboardingSteps,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

enum OnboardingStepType {
  welcome,
  congratulations,
  whoValidation,
  accountCreation,
}

class OnboardingStep {
  final OnboardingStepType type;
  final String title;
  final String message;
  final String? characterName;
  final bool isCompleted;

  const OnboardingStep({
    required this.type,
    required this.title,
    required this.message,
    this.characterName,
    this.isCompleted = false,
  });

  OnboardingStep copyWith({
    OnboardingStepType? type,
    String? title,
    String? message,
    String? characterName,
    bool? isCompleted,
  }) {
    return OnboardingStep(
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      characterName: characterName ?? this.characterName,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

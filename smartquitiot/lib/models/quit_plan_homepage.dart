class QuitPlanHomePage {
  final int id;
  final String name;
  final String startDateOfQuitPlan;
  final String startDate;
  final String endDate;
  final int durationDay;
  final String reason;
  final int totalMissions;
  final int completedMissions;
  final double progress;
  final QuitPlanCondition condition;
  final CurrentPhaseDetail currentPhaseDetail;

  QuitPlanHomePage({
    required this.id,
    required this.name,
    required this.startDateOfQuitPlan,
    required this.startDate,
    required this.endDate,
    required this.durationDay,
    required this.reason,
    required this.totalMissions,
    required this.completedMissions,
    required this.progress,
    required this.condition,
    required this.currentPhaseDetail,
  });

  factory QuitPlanHomePage.fromJson(Map<String, dynamic> json) {
    return QuitPlanHomePage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startDateOfQuitPlan: json['startDateOfQuitPlan'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      durationDay: json['durationDay'] ?? 0,
      reason: json['reason'] ?? '',
      totalMissions: json['totalMissions'] ?? 0,
      completedMissions: json['completedMissions'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      condition: QuitPlanCondition.fromJson(json['condition'] ?? {}),
      currentPhaseDetail: CurrentPhaseDetail.fromJson(json['currentPhaseDetail'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDateOfQuitPlan': startDateOfQuitPlan,
      'startDate': startDate,
      'endDate': endDate,
      'durationDay': durationDay,
      'reason': reason,
      'totalMissions': totalMissions,
      'completedMissions': completedMissions,
      'progress': progress,
      'condition': condition.toJson(),
      'currentPhaseDetail': currentPhaseDetail.toJson(),
    };
  }

  // Helper getters
  double get progressPercentage => progress / 100.0;
  int get progressPercent => progress.round();
  bool get isCompleted => progress >= 100.0;
  String get missionProgress => '$completedMissions/$totalMissions';
}

class QuitPlanCondition {
  final String logic;
  final List<QuitPlanRule> rules;

  QuitPlanCondition({
    required this.logic,
    required this.rules,
  });

  factory QuitPlanCondition.fromJson(Map<String, dynamic> json) {
    return QuitPlanCondition(
      logic: json['logic'] ?? 'AND',
      rules: (json['rules'] as List<dynamic>?)
          ?.map((rule) => QuitPlanRule.fromJson(rule as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logic': logic,
      'rules': rules.map((rule) => rule.toJson()).toList(),
    };
  }
}

class QuitPlanRule {
  final String field;
  final dynamic value;
  final String operator;

  QuitPlanRule({
    required this.field,
    required this.value,
    required this.operator,
  });

  factory QuitPlanRule.fromJson(Map<String, dynamic> json) {
    return QuitPlanRule(
      field: json['field'] ?? '',
      value: json['value'],
      operator: json['operator'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'value': value,
      'operator': operator,
    };
  }
}

class CurrentPhaseDetail {
  final int id;
  final String name;
  final String date;
  final int dayIndex;
  final int missionCompleted;
  final int totalMission;

  CurrentPhaseDetail({
    required this.id,
    required this.name,
    required this.date,
    required this.dayIndex,
    required this.missionCompleted,
    required this.totalMission,
  });

  factory CurrentPhaseDetail.fromJson(Map<String, dynamic> json) {
    return CurrentPhaseDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      dayIndex: json['dayIndex'] ?? 0,
      missionCompleted: json['missionCompleted'] ?? 0,
      totalMission: json['totalMission'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'dayIndex': dayIndex,
      'missionCompleted': missionCompleted,
      'totalMission': totalMission,
    };
  }

  // Helper getters
  String get missionProgress => '$missionCompleted/$totalMission';
  double get dayProgress => totalMission > 0 ? missionCompleted / totalMission : 0.0;
}

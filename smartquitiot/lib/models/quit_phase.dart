class QuitPhase {
  final int? id;
  final String? name; // plan name
  final String? status;
  final String? startDate;
  final String? endDate;
  final bool? useNRT;
  final int? ftndScore;
  final List<QuitPhaseDetail>? phases; // phase list
  final double? progress; // optional overall progress if provided later

  QuitPhase({
    this.id,
    this.name,
    this.status,
    this.startDate,
    this.endDate,
    this.useNRT,
    this.ftndScore,
    this.phases,
    this.progress,
  });

  factory QuitPhase.fromJson(Map<String, dynamic> json) {
    return QuitPhase(
      id: json['id'] as int?,
      name: json['name'] as String?,
      status: json['status'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      useNRT: json['useNRT'] as bool?,
      ftndScore: json['ftndScore'] as int?,
      progress: (json['progress'] as num?)?.toDouble(),
      phases: (json['phases'] as List<dynamic>?)
          ?.map((e) => QuitPhaseDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuitPhaseDetail {
  final int? id;
  final String? name;
  final String? reason;
  final String? status;
  final String? createdAt;
  final bool? keepPhase;
  final bool? redo;
  final List<QuitDay>? details; // days in this phase
  final double? progress;
  final int? totalMissions;
  final int? completedMissions;
  final String? startDate;
  final String? endDate;
  final int? durationDay;
  final double? avgCravingLevel;
  final double? avgCigarettes;
  final double? fmCigarettesTotal;
  final PhaseCondition? condition;

  QuitPhaseDetail({
    this.id,
    this.name,
    this.reason,
    this.status,
    this.createdAt,
    this.keepPhase,
    this.redo,
    this.details,
    this.progress,
    this.totalMissions,
    this.completedMissions,
    this.startDate,
    this.endDate,
    this.durationDay,
    this.avgCravingLevel,
    this.avgCigarettes,
    this.fmCigarettesTotal,
    this.condition,
  });

  factory QuitPhaseDetail.fromJson(Map<String, dynamic> json) {
    return QuitPhaseDetail(
      id: json['id'] as int?,
      name: json['name'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String?,
      createdAt: json['createAt'] as String?,
      keepPhase: json['keepPhase'] as bool?,
      redo: json['redo'] as bool?,
      progress: (json['progress'] as num?)?.toDouble(),
      totalMissions: json['totalMissions'] as int?,
      completedMissions: json['completedMissions'] as int?,
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => QuitDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      durationDay: json['durationDay'] as int?,
      avgCravingLevel: (json['avg_craving_level'] as num?)?.toDouble(),
      avgCigarettes: (json['avg_cigarettes'] as num?)?.toDouble(),
      fmCigarettesTotal: (json['fm_cigarettes_total'] as num?)?.toDouble(),
      condition: json['condition'] != null
          ? PhaseCondition.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
    );
  }
}

class QuitDay {
  final int? id;
  final String? name; // e.g., Day 1
  final String? date; // yyyy-MM-dd
  final int? dayIndex;
  final List<QuitMissionItem>? missions;

  QuitDay({this.id, this.name, this.date, this.dayIndex, this.missions});

  factory QuitDay.fromJson(Map<String, dynamic> json) {
    return QuitDay(
      id: json['id'] as int?,
      name: json['name'] as String?,
      date: json['date'] as String?,
      dayIndex: json['dayIndex'] as int?,
      missions: (json['missions'] as List<dynamic>?)
          ?.map((e) => QuitMissionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuitMissionItem {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final String? status; // COMPLETED / INCOMPLETED

  QuitMissionItem({
    this.id,
    this.code,
    this.name,
    this.description,
    this.status,
  });

  factory QuitMissionItem.fromJson(Map<String, dynamic> json) {
    return QuitMissionItem(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }
}

class PhaseCondition {
  final String? logic;
  final List<PhaseRule>? rules;

  PhaseCondition({this.logic, this.rules});

  factory PhaseCondition.fromJson(Map<String, dynamic> json) {
    return PhaseCondition(
      logic: json['logic'] as String?,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((rule) => PhaseRule.fromJson(rule as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logic': logic,
      'rules': rules?.map((rule) => rule.toJson()).toList(),
    };
  }
}

class PhaseRule {
  final String? field;
  final dynamic value;
  final String? operator;
  final String? logic; // for nested rules
  final List<PhaseRule>? rules; // for nested rules
  final Map<String, dynamic>? formula; // for formula-based rules

  PhaseRule({
    this.field,
    this.value,
    this.operator,
    this.logic,
    this.rules,
    this.formula,
  });

  factory PhaseRule.fromJson(Map<String, dynamic> json) {
    return PhaseRule(
      field: json['field'] as String?,
      value: json['value'],
      operator: json['operator'] as String?,
      logic: json['logic'] as String?,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((rule) => PhaseRule.fromJson(rule as Map<String, dynamic>))
          .toList(),
      formula: json['formula'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (field != null) 'field': field,
      if (value != null) 'value': value,
      if (operator != null) 'operator': operator,
      if (logic != null) 'logic': logic,
      if (rules != null) 'rules': rules?.map((rule) => rule.toJson()).toList(),
      if (formula != null) 'formula': formula,
    };
  }
}

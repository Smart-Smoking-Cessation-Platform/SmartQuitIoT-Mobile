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
  final List<QuitDay>? details; // days in this phase
  final double? progress;
  final int? totalMissions;
  final int? completedMissions;
  final String? startDate;
  final String? endDate;
  final int? durationDay;

  QuitPhaseDetail({
    this.id,
    this.name,
    this.reason,
    this.details,
    this.progress,
    this.totalMissions,
    this.completedMissions,
    this.startDate,
    this.endDate,
    this.durationDay,
  });

  factory QuitPhaseDetail.fromJson(Map<String, dynamic> json) {
    return QuitPhaseDetail(
      id: json['id'] as int?,
      name: json['name'] as String?,
      reason: json['reason'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
      totalMissions: json['totalMissions'] as int?,
      completedMissions: json['completedMissions'] as int?,
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => QuitDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      durationDay: json['durationDay'] as int?,
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

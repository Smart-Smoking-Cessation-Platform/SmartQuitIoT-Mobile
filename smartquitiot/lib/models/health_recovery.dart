class HealthRecoveryResponse {
  final List<HealthRecovery> healthRecoveries;
  final DetailedMetrics metrics;

  HealthRecoveryResponse({
    required this.healthRecoveries,
    required this.metrics,
  });

  factory HealthRecoveryResponse.fromJson(Map<String, dynamic> json) {
    return HealthRecoveryResponse(
      healthRecoveries: (json['healthRecoveries'] as List<dynamic>? ?? [])
          .map((item) => HealthRecovery.fromJson(item))
          .toList(),
      metrics: DetailedMetrics.fromJson(json['metrics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthRecoveries': healthRecoveries.map((item) => item.toJson()).toList(),
      'metrics': metrics.toJson(),
    };
  }
}

class HealthRecovery {
  final int id;
  final String name;
  final double? value;
  final String description;
  final String timeTriggered;
  final double recoveryTime;
  final String targetTime;

  HealthRecovery({
    required this.id,
    required this.name,
    this.value,
    required this.description,
    required this.timeTriggered,
    required this.recoveryTime,
    required this.targetTime,
  });

  factory HealthRecovery.fromJson(Map<String, dynamic> json) {
    return HealthRecovery(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      description: json['description'] ?? '',
      timeTriggered: json['timeTriggered'] ?? '',
      recoveryTime: (json['recoveryTime'] ?? 0.0).toDouble(),
      targetTime: json['targetTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'description': description,
      'timeTriggered': timeTriggered,
      'recoveryTime': recoveryTime,
      'targetTime': targetTime,
    };
  }

  // Helper method to get formatted recovery time
  String get formattedRecoveryTime {
    if (recoveryTime < 60) {
      return '${recoveryTime.toInt()} minutes';
    } else if (recoveryTime < 1440) {
      return '${(recoveryTime / 60).toStringAsFixed(1)} hours';
    } else {
      return '${(recoveryTime / 1440).toStringAsFixed(1)} days';
    }
  }

  // Helper method to get recovery status
  RecoveryStatus get status {
    if (value == null) return RecoveryStatus.upcoming;
    if (value! >= 95) return RecoveryStatus.completed;
    if (value! >= 50) return RecoveryStatus.inProgress;
    return RecoveryStatus.started;
  }
}

class DetailedMetrics {
  final int id;
  final int streaks;
  final int relapseCountInPhase;
  final double avgCravingLevel;
  final double avgMood;
  final double avgAnxiety;
  final double avgConfidentLevel;
  final int avgCigarettesPerDay;
  final int currentCravingLevel;
  final int currentMoodLevel;
  final int currentConfidenceLevel;
  final int currentAnxietyLevel;
  final int steps;
  final int heartRate;
  final int spo2;
  final int activityMinutes;
  final int respiratoryRate;
  final double sleepDuration;
  final int sleepQuality;
  final double annualSaved;
  final double moneySaved;
  final double reductionPercentage;
  final double smokeFreeDayPercentage;
  final String createdAt;
  final String updatedAt;

  DetailedMetrics({
    required this.id,
    required this.streaks,
    required this.relapseCountInPhase,
    required this.avgCravingLevel,
    required this.avgMood,
    required this.avgAnxiety,
    required this.avgConfidentLevel,
    required this.avgCigarettesPerDay,
    required this.currentCravingLevel,
    required this.currentMoodLevel,
    required this.currentConfidenceLevel,
    required this.currentAnxietyLevel,
    required this.steps,
    required this.heartRate,
    required this.spo2,
    required this.activityMinutes,
    required this.respiratoryRate,
    required this.sleepDuration,
    required this.sleepQuality,
    required this.annualSaved,
    required this.moneySaved,
    required this.reductionPercentage,
    required this.smokeFreeDayPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DetailedMetrics.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert num to int
    int toInt(dynamic value) => (value ?? 0) is int ? value : (value ?? 0).toInt();
    
    return DetailedMetrics(
      id: toInt(json['id']),
      streaks: toInt(json['streaks']),
      relapseCountInPhase: toInt(json['relapseCountInPhase']),
      avgCravingLevel: (json['avgCravingLevel'] ?? 0.0).toDouble(),
      avgMood: (json['avgMood'] ?? 0.0).toDouble(),
      avgAnxiety: (json['avgAnxiety'] ?? 0.0).toDouble(),
      avgConfidentLevel: (json['avgConfidentLevel'] ?? 0.0).toDouble(),
      avgCigarettesPerDay: toInt(json['avgCigarettesPerDay']),
      currentCravingLevel: toInt(json['currentCravingLevel']),
      currentMoodLevel: toInt(json['currentMoodLevel']),
      currentConfidenceLevel: toInt(json['currentConfidenceLevel']),
      currentAnxietyLevel: toInt(json['currentAnxietyLevel']),
      steps: toInt(json['steps']),
      heartRate: toInt(json['heartRate']),
      spo2: toInt(json['spo2']),
      activityMinutes: toInt(json['activityMinutes']),
      respiratoryRate: toInt(json['respiratoryRate']),
      sleepDuration: (json['sleepDuration'] ?? 0.0).toDouble(),
      sleepQuality: toInt(json['sleepQuality']),
      annualSaved: (json['annualSaved'] ?? 0.0).toDouble(),
      moneySaved: (json['moneySaved'] ?? 0.0).toDouble(),
      reductionPercentage: (json['reductionPercentage'] ?? 0.0).toDouble(),
      smokeFreeDayPercentage: (json['smokeFreeDayPercentage'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streaks': streaks,
      'relapseCountInPhase': relapseCountInPhase,
      'avgCravingLevel': avgCravingLevel,
      'avgMood': avgMood,
      'avgAnxiety': avgAnxiety,
      'avgConfidentLevel': avgConfidentLevel,
      'avgCigarettesPerDay': avgCigarettesPerDay,
      'currentCravingLevel': currentCravingLevel,
      'currentMoodLevel': currentMoodLevel,
      'currentConfidenceLevel': currentConfidenceLevel,
      'currentAnxietyLevel': currentAnxietyLevel,
      'steps': steps,
      'heartRate': heartRate,
      'spo2': spo2,
      'activityMinutes': activityMinutes,
      'respiratoryRate': respiratoryRate,
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
      'annualSaved': annualSaved,
      'moneySaved': moneySaved,
      'reductionPercentage': reductionPercentage,
      'smokeFreeDayPercentage': smokeFreeDayPercentage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

enum RecoveryStatus {
  upcoming,
  started,
  inProgress,
  completed,
}

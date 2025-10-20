class DiaryRecord {
  final String? id;
  final String date;
  final bool haveSmoked;
  final int cigarettesSmoked;
  final List<String> triggers;
  final bool isUseNrt;
  final double moneySpentOnNrt;
  final int cravingLevel;
  final int moodLevel;
  final int confidenceLevel;
  final int anxietyLevel;
  final String note;
  final bool isConnectIoTDevice;
  final int steps;
  final int heartRate;
  final int spo2;
  final int activityMinutes;
  final int respiratoryRate;
  final double sleepDuration;
  final int sleepQuality;

  DiaryRecord({
    this.id,
    required this.date,
    required this.haveSmoked,
    required this.cigarettesSmoked,
    required this.triggers,
    required this.isUseNrt,
    required this.moneySpentOnNrt,
    required this.cravingLevel,
    required this.moodLevel,
    required this.confidenceLevel,
    required this.anxietyLevel,
    required this.note,
    required this.isConnectIoTDevice,
    required this.steps,
    required this.heartRate,
    required this.spo2,
    required this.activityMinutes,
    required this.respiratoryRate,
    required this.sleepDuration,
    required this.sleepQuality,
  });

  factory DiaryRecord.fromJson(Map<String, dynamic> json) {
    return DiaryRecord(
      id: json['id'],
      date: json['date'] ?? '',
      haveSmoked: json['haveSmoked'] ?? false,
      cigarettesSmoked: json['cigarettesSmoked'] ?? 0,
      triggers: List<String>.from(json['triggers'] ?? []),
      isUseNrt: json['isUseNrt'] ?? false,
      moneySpentOnNrt: (json['moneySpentOnNrt'] ?? 0.0).toDouble(),
      cravingLevel: json['cravingLevel'] ?? 5,
      moodLevel: json['moodLevel'] ?? 5,
      confidenceLevel: json['confidenceLevel'] ?? 5,
      anxietyLevel: json['anxietyLevel'] ?? 5,
      note: json['note'] ?? '',
      isConnectIoTDevice: json['isConnectIoTDevice'] ?? false,
      steps: json['steps'] ?? 0,
      heartRate: json['heartRate'] ?? 0,
      spo2: json['spo2'] ?? 0,
      activityMinutes: json['activityMinutes'] ?? 0,
      respiratoryRate: json['respiratoryRate'] ?? 0,
      sleepDuration: (json['sleepDuration'] ?? 0.0).toDouble(),
      sleepQuality: json['sleepQuality'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'haveSmoked': haveSmoked,
      'cigarettesSmoked': cigarettesSmoked,
      'triggers': triggers,
      'isUseNrt': isUseNrt,
      'moneySpentOnNrt': moneySpentOnNrt,
      'cravingLevel': cravingLevel,
      'moodLevel': moodLevel,
      'confidenceLevel': confidenceLevel,
      'anxietyLevel': anxietyLevel,
      'note': note,
      'isConnectIoTDevice': isConnectIoTDevice,
      'steps': steps,
      'heartRate': heartRate,
      'spo2': spo2,
      'activityMinutes': activityMinutes,
      'respiratoryRate': respiratoryRate,
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
    };
  }

  DiaryRecord copyWith({
    String? id,
    String? date,
    bool? haveSmoked,
    int? cigarettesSmoked,
    List<String>? triggers,
    bool? isUseNrt,
    double? moneySpentOnNrt,
    int? cravingLevel,
    int? moodLevel,
    int? confidenceLevel,
    int? anxietyLevel,
    String? note,
    bool? isConnectIoTDevice,
    int? steps,
    int? heartRate,
    int? spo2,
    int? activityMinutes,
    int? respiratoryRate,
    double? sleepDuration,
    int? sleepQuality,
  }) {
    return DiaryRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      haveSmoked: haveSmoked ?? this.haveSmoked,
      cigarettesSmoked: cigarettesSmoked ?? this.cigarettesSmoked,
      triggers: triggers ?? this.triggers,
      isUseNrt: isUseNrt ?? this.isUseNrt,
      moneySpentOnNrt: moneySpentOnNrt ?? this.moneySpentOnNrt,
      cravingLevel: cravingLevel ?? this.cravingLevel,
      moodLevel: moodLevel ?? this.moodLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      note: note ?? this.note,
      isConnectIoTDevice: isConnectIoTDevice ?? this.isConnectIoTDevice,
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      activityMinutes: activityMinutes ?? this.activityMinutes,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepQuality: sleepQuality ?? this.sleepQuality,
    );
  }
}

class DiaryRecordRequest {
  final String date;
  final bool haveSmoked;
  final int cigarettesSmoked;
  final List<String> triggers;
  final bool isUseNrt;
  final double moneySpentOnNrt;
  final int cravingLevel;
  final int moodLevel;
  final int confidenceLevel;
  final int anxietyLevel;
  final String note;
  final bool isConnectIoTDevice;
  final int steps;
  final int heartRate;
  final int spo2;
  final int activityMinutes;
  final int respiratoryRate;
  final double sleepDuration;
  final int sleepQuality;

  DiaryRecordRequest({
    required this.date,
    required this.haveSmoked,
    required this.cigarettesSmoked,
    required this.triggers,
    required this.isUseNrt,
    required this.moneySpentOnNrt,
    required this.cravingLevel,
    required this.moodLevel,
    required this.confidenceLevel,
    required this.anxietyLevel,
    required this.note,
    required this.isConnectIoTDevice,
    required this.steps,
    required this.heartRate,
    required this.spo2,
    required this.activityMinutes,
    required this.respiratoryRate,
    required this.sleepDuration,
    required this.sleepQuality,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'haveSmoked': haveSmoked,
      'cigarettesSmoked': cigarettesSmoked,
      'triggers': triggers,
      'isUseNrt': isUseNrt,
      'moneySpentOnNrt': moneySpentOnNrt,
      'cravingLevel': cravingLevel,
      'moodLevel': moodLevel,
      'confidenceLevel': confidenceLevel,
      'anxietyLevel': anxietyLevel,
      'note': note,
      'isConnectIoTDevice': isConnectIoTDevice,
      'steps': steps,
      'heartRate': heartRate,
      'spo2': spo2,
      'activityMinutes': activityMinutes,
      'respiratoryRate': respiratoryRate,
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
    };
  }
}

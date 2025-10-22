class DiaryCharts {
  final List<MoodData> moodLevel;
  final List<ConfidenceData> confidenceLevel;
  final List<CravingData> cravingLevel;
  final List<AnxietyData> anxietyLevel;

  DiaryCharts({
    required this.moodLevel,
    required this.confidenceLevel,
    required this.cravingLevel,
    required this.anxietyLevel,
  });

  factory DiaryCharts.fromJson(Map<String, dynamic> json) {
    return DiaryCharts(
      moodLevel: (json['moodLevel'] as List<dynamic>?)
          ?.map((e) => MoodData.fromJson(e))
          .toList() ?? [],
      confidenceLevel: (json['confidenceLevel'] as List<dynamic>?)
          ?.map((e) => ConfidenceData.fromJson(e))
          .toList() ?? [],
      cravingLevel: (json['cravingLevel'] as List<dynamic>?)
          ?.map((e) => CravingData.fromJson(e))
          .toList() ?? [],
      anxietyLevel: (json['anxietyLevel'] as List<dynamic>?)
          ?.map((e) => AnxietyData.fromJson(e))
          .toList() ?? [],
    );
  }
}

class MoodData {
  final int moodLevel;
  final String date;

  MoodData({required this.moodLevel, required this.date});

  factory MoodData.fromJson(Map<String, dynamic> json) {
    return MoodData(
      moodLevel: json['moodLevel'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}

class ConfidenceData {
  final int confidenceLevel;
  final String date;

  ConfidenceData({required this.confidenceLevel, required this.date});

  factory ConfidenceData.fromJson(Map<String, dynamic> json) {
    return ConfidenceData(
      confidenceLevel: json['confidenceLevel'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}

class CravingData {
  final int cravingLevel;
  final String date;

  CravingData({required this.cravingLevel, required this.date});

  factory CravingData.fromJson(Map<String, dynamic> json) {
    return CravingData(
      cravingLevel: json['cravingLevel'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}

class AnxietyData {
  final int anxietyLevel;
  final String date;

  AnxietyData({required this.anxietyLevel, required this.date});

  factory AnxietyData.fromJson(Map<String, dynamic> json) {
    return AnxietyData(
      anxietyLevel: json['anxietyLevel'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}

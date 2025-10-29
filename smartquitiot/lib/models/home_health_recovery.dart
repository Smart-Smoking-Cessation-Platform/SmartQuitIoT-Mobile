class HomeHealthRecovery {
  final double? oxygenLevel;
  final double? pulseRate;
  final double? carbonMonoxideLevel;

  HomeHealthRecovery({
    this.oxygenLevel,
    this.pulseRate,
    this.carbonMonoxideLevel,
  });

  factory HomeHealthRecovery.fromJson(Map<String, dynamic> json) {
    return HomeHealthRecovery(
      oxygenLevel: json['oxygenLevel'] != null 
          ? (json['oxygenLevel'] as num).toDouble() 
          : null,
      pulseRate: json['pulseRate'] != null 
          ? (json['pulseRate'] as num).toDouble() 
          : null,
      carbonMonoxideLevel: json['carbonMonoxideLevel'] != null 
          ? (json['carbonMonoxideLevel'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oxygenLevel': oxygenLevel,
      'pulseRate': pulseRate,
      'carbonMonoxideLevel': carbonMonoxideLevel,
    };
  }

  bool get hasData {
    return oxygenLevel != null || pulseRate != null || carbonMonoxideLevel != null;
  }
}

class Coach {
  final int id;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final double ratingAvg;

  Coach({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.ratingAvg,
  });

  String get fullName => '$firstName $lastName';

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      ratingAvg: (json['ratingAvg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'ratingAvg': ratingAvg,
    };
  }

  @override
  String toString() {
    return 'Coach(id: $id, name: $fullName, rating: $ratingAvg)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Coach && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CoachListResponse {
  final bool success;
  final String message;
  final List<Coach> data;
  final int code;
  final int timestamp;

  CoachListResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory CoachListResponse.fromJson(Map<String, dynamic> json) {
    return CoachListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((coachJson) => Coach.fromJson(coachJson as Map<String, dynamic>))
          .toList(),
      code: json['code'] as int,
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((coach) => coach.toJson()).toList(),
      'code': code,
      'timestamp': timestamp,
    };
  }
}

// lib/models/request/appointment_request.dart
class AppointmentRequest {
  final int coachId;
  final int slotId;
  final String date; // yyyy-MM-dd
  final bool? forceConfirm; // Nếu true, cho phép đặt lịch ngay cả khi trùng thời gian

  AppointmentRequest({
    required this.coachId,
    required this.slotId,
    required this.date,
    this.forceConfirm,
  });

  Map<String, dynamic> toJson() => {
    'coachId': coachId,
    'slotId': slotId,
    'date': date,
    if (forceConfirm != null) 'forceConfirm': forceConfirm,
  };

  factory AppointmentRequest.fromJson(Map<String, dynamic> j) => AppointmentRequest(
    coachId: j['coachId'] as int,
    slotId: j['slotId'] as int,
    date: j['date'] as String,
    forceConfirm: j['forceConfirm'] as bool?,
  );
}

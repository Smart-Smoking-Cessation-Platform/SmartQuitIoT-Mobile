// lib/models/appointment.dart
class Appointment {
  final int appointmentId;
  final int coachId;
  final String coachName;
  final int slotId;
  final String date; // yyyy-MM-dd
  final String startTime; // "07:00:00"
  final String endTime;   // "07:30:00"
  String runtimeStatus;

  // new fields
  final String? channelName;
  final String? meetingUrl;
  final DateTime? joinWindowStart;
  final DateTime? joinWindowEnd;

  Appointment({
    required this.appointmentId,
    required this.coachId,
    required this.coachName,
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.runtimeStatus,
    this.channelName,
    this.meetingUrl,
    this.joinWindowStart,
    this.joinWindowEnd,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) {
    DateTime? parseInstant(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString()).toUtc();
      } catch (_) { return null; }
    }

    String normalizeStatus(dynamic v) {
      if (v == null) return '';
      return v.toString().trim().toUpperCase();
    }

    return Appointment(
      appointmentId: j['appointmentId'] as int,
      coachId: j['coachId'] as int,
      coachName: j['coachName'] as String? ?? '',
      slotId: j['slotId'] as int,
      date: j['date'] as String? ?? '',
      startTime: j['startTime'] as String? ?? '',
      endTime: j['endTime'] as String? ?? '',
      runtimeStatus: normalizeStatus(j['runtimeStatus']),
      channelName: j['channelName'] as String?,
      meetingUrl: j['meetingUrl'] as String?,
      joinWindowStart: parseInstant(j['joinWindowStart']),
      joinWindowEnd: parseInstant(j['joinWindowEnd']),
    );
  }

}

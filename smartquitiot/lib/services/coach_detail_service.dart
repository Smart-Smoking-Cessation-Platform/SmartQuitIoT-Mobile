import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CoachDetailService {
  final Dio _dio;

  CoachDetailService({Dio? dio}) : _dio = dio ?? Dio();

  String _replacePlaceholder(String template, Map<String, String> values) {
    var out = template;
    values.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }

  /// 🔹 Gọi API lấy chi tiết coach, trả JSON raw
  Future<Map<String, dynamic>> fetchCoachDetail(String token, int coachId) async {
    final detailTemplate = dotenv.env['API_COACH_DETAIL_URL'];
    final baseCoach = dotenv.env['API_COACH_URL'];
    final url = detailTemplate != null && detailTemplate.isNotEmpty
        ? _replacePlaceholder(detailTemplate, {'id': coachId.toString()})
        : '${baseCoach ?? ''}/$coachId';

    final response = await _dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data is Map && response.data.containsKey('data')) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    return Map<String, dynamic>.from(response.data);
  }

  /// 🔹 Gọi API lấy slot khả dụng, trả JSON raw list
  Future<List<dynamic>> fetchAvailableSlots(
      String token,
      int coachId,
      String date,
      ) async {
    final slotsTemplate = dotenv.env['API_COACH_SLOTS_URL'];
    final baseCoach = dotenv.env['API_COACH_URL'];

    final url = slotsTemplate != null && slotsTemplate.isNotEmpty
        ? _replacePlaceholder(slotsTemplate, {
      'id': coachId.toString(),
      'date': Uri.encodeComponent(date),
    })
        : '${baseCoach ?? ''}/$coachId/slots/available?date=${Uri.encodeComponent(date)}';

    final response = await _dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data is Map && response.data.containsKey('data')) {
      return List<dynamic>.from(response.data['data']);
    }
    if (response.data is List) {
      return List<dynamic>.from(response.data);
    }
    throw Exception("Unexpected response format: ${response.data}");
  }
}

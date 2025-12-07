// lib/services/appointment_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/remaining_booking.dart';
import '../exceptions/appointment_conflict_exception.dart';
import 'token_storage_service.dart'; // ensure this file exists in same folder

class AppointmentService {
  // Lưu ý: set API_BASE_URL trong .env, ví dụ: http://10.0.2.2:8080
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

  AppointmentService();

  /// book appointment: reqBody must be encodable (Map) and returns decoded JSON map on success
  Future<Map<String, dynamic>> bookAppointment(
    Map<String, dynamic> reqBody,
    String accessToken,
  ) async {
    final url = '$_baseUrl/appointments';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    http.Response resp;
    try {
      resp = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(reqBody))
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Network error: $e');
    }

    dynamic body;
    try {
      body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    } catch (_) {
      body = null;
    }

    debugPrint(
      '[AppointmentService] POST $url -> status=${resp.statusCode} body=$body',
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        final success = body['success'];
        if (success == true || body.containsKey('data')) {
          return Map<String, dynamic>.from(body);
        } else {
          final msg =
              (body['message'] ??
                      'Booking failed (server returned success=false)')
                  .toString();
          throw Exception(msg);
        }
      } else {
        throw Exception('Unexpected response format from server.');
      }
    }

    // Xử lý trường hợp 409 Conflict (trùng thời gian)
    if (resp.statusCode == 409) {
      final msg = (body is Map && body.containsKey('message'))
          ? body['message'].toString()
          : 'You already have an appointment scheduled at this time with another coach.';
      throw AppointmentConflictException(msg, statusCode: 409);
    }

    final msg = (body is Map && body.containsKey('message'))
        ? body['message'].toString()
        : 'Booking failed: HTTP ${resp.statusCode}';
    throw Exception(msg);
  }

  /// GET my appointments
  Future<List<dynamic>> getMyAppointments(String accessToken) async {
    final url = '$_baseUrl/appointments';
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    http.Response resp;
    try {
      resp = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      throw Exception('Network error: $e');
    }

    dynamic body;
    try {
      body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    } catch (_) {
      body = null;
    }

    debugPrint(
      '[AppointmentService] GET $url -> status=${resp.statusCode} bodyType=${body?.runtimeType}',
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // backend may wrap in { success, data } or directly return list
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        if (body['data'] is List) {
          return List<dynamic>.from(body['data']);
        }
        return [];
      } else if (body is List) {
        return List<dynamic>.from(body);
      } else {
        return [];
      }
    }

    final msg = (body is Map && body.containsKey('message'))
        ? body['message'].toString()
        : 'Failed to fetch appointments: HTTP ${resp.statusCode}';
    throw Exception(msg);
  }

  /// POST join token for an appointment (backend expects POST with no body)
  Future<Map<String, dynamic>> requestJoinToken(
    int appointmentId,
    String accessToken,
  ) async {
    final url = '$_baseUrl/appointments/$appointmentId/join-token';
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    http.Response resp;
    try {
      // POST with empty body (backend only needs path + auth)
      resp = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode({}))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Network error: $e');
    }

    dynamic body;
    try {
      body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    } catch (_) {
      body = null;
    }

    debugPrint(
      '[AppointmentService] POST $url -> status=${resp.statusCode} body=$body',
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return Map<String, dynamic>.from(body['data']);
      } else {
        throw Exception('Unexpected response format.');
      }
    }

    final msg = (body is Map && body.containsKey('message'))
        ? body['message'].toString()
        : 'Failed to request join token: HTTP ${resp.statusCode}';
    throw Exception(msg);
  }

  /// Lấy số lượt còn lại cho member (GET /appointments/remaining)
  Future<RemainingBooking> getRemainingBookings() async {
    final token = await TokenStorageService().getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No access token found');
    }

    final url = '$_baseUrl/appointments/remaining';
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http.Response resp;
    try {
      resp = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Network error: $e');
    }

    dynamic body;
    try {
      body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    } catch (_) {
      body = null;
    }

    debugPrint(
      '[AppointmentService] GET $url -> status=${resp.statusCode} body=$body',
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // backend expected: { success, message, data: { allowed, used, remaining, periodStart, periodEnd, note } }
      Map<String, dynamic> dataMap;
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        dataMap = Map<String, dynamic>.from(body['data']);
      } else if (body is Map<String, dynamic>) {
        // fallback: maybe backend returns data directly
        dataMap = Map<String, dynamic>.from(body);
      } else {
        throw Exception('Invalid response from server');
      }

      return RemainingBooking.fromJson(dataMap);
    }

    final msg = (body is Map && body.containsKey('message'))
        ? body['message'].toString()
        : 'Failed to fetch remaining bookings: HTTP ${resp.statusCode}';
    throw Exception(msg);
  }

  /// POST rating for an appointment
  /// body: { "star": int(1..5), "content": String (optional) }
  Future<void> rateAppointment(
    int appointmentId,
    int rating,
    String? comment,
    String accessToken,
  ) async {
    // validate rating
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    final url = '$_baseUrl/appointments/$appointmentId/feedback';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = <String, dynamic>{
      'star': rating,
      if (comment != null && comment.trim().isNotEmpty)
        'content': comment.trim(),
    };

    // ✅ THÊM DEBUG LOG ĐỂ XEM REQUEST BODY - DÙNG print() ĐỂ CHẮC CHẮN HIỂN THỊ
    print(
      '🔵 [AppointmentService] ========== RATE APPOINTMENT REQUEST ==========',
    );
    print('🔵 URL: $url');
    print('🔵 Request Body (Map): $body');
    print('�� Request Body (JSON): ${jsonEncode(body)}');
    print('�� Comment parameter: "$comment"');
    print('🔵 Comment type: ${comment.runtimeType}');
    print('🔵 Comment is null: ${comment == null}');
    print('🔵 Comment is empty: ${comment?.isEmpty ?? true}');
    print('🔵 Comment trimmed: "${comment?.trim() ?? 'null'}"');
    print(
      '🔵 Will include content in body: ${comment != null && comment.trim().isNotEmpty}',
    );
    print('�� Body keys: ${body.keys.toList()}');
    print('🔵 Body contains "content": ${body.containsKey("content")}');
    if (body.containsKey('content')) {
      print('�� Content value: "${body["content"]}"');
    }
    print('🔵 ============================================================');

    http.Response resp;
    try {
      resp = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      throw Exception('Network error: $e');
    }

    dynamic parsed;
    try {
      parsed = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    } catch (_) {
      parsed = null;
    }

    debugPrint(
      '[AppointmentService] POST $url -> status=${resp.statusCode} body=$parsed',
    );

    // ✅ THÊM LOG ĐỂ XEM RESPONSE CHI TIẾT
    print('🔵 [AppointmentService] ========== RESPONSE ==========');
    print('🔵 Status Code: ${resp.statusCode}');
    print('�� Response Body (raw): ${resp.body}');
    print('🔵 Response Body (parsed): $parsed');
    if (parsed is Map<String, dynamic>) {
      print('🔵 Success: ${parsed['success']}');
      print('🔵 Message: ${parsed['message']}');
      print('🔵 Data: ${parsed['data']}');
    }
    print('🔵 ===========================================');

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // Accept success either as plain 2xx or wrapper { success: true, data: ... }
      if (parsed is Map<String, dynamic>) {
        // if backend returns success flag, ensure it's true
        if (parsed.containsKey('success')) {
          if (parsed['success'] == true) return;
          final msg =
              parsed['message']?.toString() ?? 'Failed to submit rating';
          throw Exception(msg);
        }
        // if backend returns { data: ... } or plain object, treat as success
        return;
      }
      // no body but 2xx = success
      return;
    }

    // Non-2xx -> try to extract message
    final msg = (parsed is Map && parsed.containsKey('message'))
        ? parsed['message'].toString()
        : 'Failed to submit rating: HTTP ${resp.statusCode}';
    throw Exception(msg);
  }

  /// DELETE /appointments/{id} - cancel by member
  Future<void> cancelAppointment(int appointmentId, String accessToken) async {
    final url = '$_baseUrl/appointments/$appointmentId';
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    http.Response resp;
    try {
      resp = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Network error: $e');
    }

    dynamic body;
    try {
      body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    } catch (_) {
      body = null;
    }

    debugPrint(
      '[AppointmentService] DELETE $url -> status=${resp.statusCode} body=$body',
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // success
      return;
    }

    final msg = (body is Map && body.containsKey('message'))
        ? body['message'].toString()
        : 'Failed to cancel appointment: HTTP ${resp.statusCode}';
    throw Exception(msg);
  }
}

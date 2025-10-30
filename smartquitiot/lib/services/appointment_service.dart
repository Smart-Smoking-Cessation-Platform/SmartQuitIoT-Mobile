// lib/services/appointment_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AppointmentService {
  final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api';

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
}

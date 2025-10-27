// lib/services/appointment_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/request/appointment_request.dart';

class AppointmentService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api';

  /// Throws Exception when booking fails.
  /// Accepts either:
  ///  - AppointmentRequest instance (preferred)
  ///  - Map<String, dynamic>
  ///  - JSON string
  Future<Map<String, dynamic>> bookAppointment(
      dynamic reqBody, String accessToken) async {
    final url = '$_baseUrl/member/appointments';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    // Serialize request body safely
    String bodyString;
    if (reqBody == null) {
      throw Exception('Request body is null');
    } else if (reqBody is AppointmentRequest) {
      bodyString = jsonEncode(reqBody.toJson());
    } else if (reqBody is Map<String, dynamic>) {
      bodyString = jsonEncode(reqBody);
    } else if (reqBody is String) {
      bodyString = reqBody;
    } else {
      // fallback: try toJson if available or jsonEncode
      try {
        final dynamic maybeMap = (reqBody as dynamic).toJson();
        if (maybeMap is Map<String, dynamic>) {
          bodyString = jsonEncode(maybeMap);
        } else {
          bodyString = jsonEncode(reqBody);
        }
      } catch (e) {
        // last resort
        try {
          bodyString = jsonEncode(reqBody);
        } catch (e2) {
          throw Exception('Unable to serialize request body: $e, $e2');
        }
      }
    }

    http.Response resp;
    try {
      resp = await http
          .post(Uri.parse(url), headers: headers, body: bodyString)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Network error: $e');
    }

    // Try decode response body
    dynamic body;
    try {
      body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    } catch (e) {
      body = null;
    }

    debugPrint('[AppointmentService] POST $url -> status=${resp.statusCode} body=$body');

    // Success HTTP
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        final success = body['success'];
        if (success == true) {
          return Map<String, dynamic>.from(body);
        } else {
          final msg = (body['message'] ?? 'Booking failed (server returned success=false)').toString();
          throw Exception(msg);
        }
      } else {
        // server returned 2xx but not a JSON object
        throw Exception('Unexpected response format from server: ${resp.body}');
      }
    }

    // Non-2xx
    final msg = (body is Map && body.containsKey('message'))
        ? body['message'].toString()
        : 'Booking failed: HTTP ${resp.statusCode}';
    throw Exception(msg);
  }
}

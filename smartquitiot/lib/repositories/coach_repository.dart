import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/errors/exception.dart';
import '../models/coach.dart';
import '../services/token_storage_service.dart';

class CoachRepository {
  final http.Client _client;
  final TokenStorageService _tokenService = TokenStorageService();
  final String _baseUrl =
      dotenv.env['API_COACH_URL'] ?? 'http://10.0.2.2:8080/api/coaches';

  CoachRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Helper: build authorized headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getAccessToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Lấy danh sách coaches
  Future<CoachListResponse> getCoaches() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(Uri.parse(_baseUrl), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CoachListResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw const CoachException(
          'Unauthorized: Invalid or expired token',
          401,
        );
      } else {
        throw CoachException(
          'Failed to load coaches: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException {
      throw const CoachException('Network error: Unable to connect to server');
    } on FormatException {
      throw const CoachException('Invalid response format from server');
    } catch (e) {
      throw CoachException('Unexpected error: $e');
    }
  }

  /// Lấy thông tin chi tiết của 1 coach
  Future<Coach> getCoachById(int id) async {
    try {
      final headers = await _getHeaders();

      final response = await _client.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Coach.fromJson(jsonData['data']);
        } else {
          throw CoachException('Coach not found');
        }
      } else if (response.statusCode == 401) {
        throw const CoachException(
          'Unauthorized: Invalid or expired token',
          401,
        );
      } else {
        throw CoachException(
          'Failed to load coach: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException {
      throw const CoachException('Network error: Unable to connect to server');
    } on FormatException {
      throw const CoachException('Invalid response format from server');
    } catch (e) {
      throw CoachException('Unexpected error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:SmartQuitIoT/core/errors/failures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/token_storage_service.dart';

class DiaryRecordRepository {
  final TokenStorageService _tokenService = TokenStorageService();
  late final String baseUrl;

  DiaryRecordRepository() {
    baseUrl =
        dotenv.env['API_DIARY_RECORD_URL'] ??
        'http://localhost:8080/api/diary-records';
  }

  /// Helper: tạo headers với access token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<DiaryRecord> createDiaryRecord(DiaryRecordRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DiaryRecord.fromJson(data);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw ServerFailure(errorData['message'] ?? 'Bad request');
      } else {
        throw ServerFailure(
          'Failed to create diary record: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  Future<List<DiaryRecord>> getDiaryRecords() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DiaryRecord.fromJson(json)).toList();
      } else {
        throw ServerFailure(
          'Failed to fetch diary records: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  Future<DiaryRecord?> getTodayDiaryRecord() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/today'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data != null ? DiaryRecord.fromJson(data) : null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerFailure(
          'Failed to fetch today diary record: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  Future<DiaryRecord> updateDiaryRecord(
    String id,
    DiaryRecordRequest request,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DiaryRecord.fromJson(data);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw ServerFailure(errorData['message'] ?? 'Bad request');
      } else {
        throw ServerFailure(
          'Failed to update diary record: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }

  Future<void> deleteDiaryRecord(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerFailure(
          'Failed to delete diary record: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Network error: ${e.toString()}');
    }
  }
}

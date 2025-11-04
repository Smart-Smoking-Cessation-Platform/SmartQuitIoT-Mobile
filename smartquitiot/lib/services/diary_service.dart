import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/diary_record.dart';
import '../repositories/auth_repository.dart';
import 'dart:convert';

class DiaryService {
  final Dio _dio = Dio();
  final AuthRepository _authRepository;
  late final String baseUrl;

  DiaryService(this._authRepository) {
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
    baseUrl = '$apiBaseUrl/diary-records';
    
    // Setup Dio interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('🔍 Getting token from AuthRepository...');
          final token = await _authRepository.getAccessToken();
          print('🔑 Diary API Token: $token');
          print('📡 Diary Request to: ${options.uri}');
          
          if (token == null || token.isEmpty) {
            print('⚠️ WARNING: Token is null or empty!');
            print('⚠️ Checking if user is authenticated...');
            final isAuth = await _authRepository.isAuthenticated();
            print('⚠️ Is authenticated: $isAuth');
          }
          
          options.headers['Content-Type'] = 'application/json';
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Diary Response: ${response.statusCode}');
          print('📦 Diary Response Data: ${jsonEncode(response.data)}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ Diary API Error: ${e.response?.statusCode} - ${e.message}');
          print('❌ Diary Error Response: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  /// Create diary record
  Future<Response> createDiaryRecord(DiaryRecordRequest request) async {
    return await _dio.post(
      '$baseUrl/log',
      data: request.toJson(),
    );
  }

  /// Get diary history (list summary)
  Future<Response> getDiaryHistory() async {
    return await _dio.get('$baseUrl/history');
  }

  /// Get diary record by ID (full details)
  Future<Response> getDiaryRecordById(int id) async {
    return await _dio.get('$baseUrl/$id');
  }

  /// Get today's diary record
  Future<Response> getTodayDiaryRecord() async {
    return await _dio.get('$baseUrl/today');
  }

  /// Get diary charts data
  Future<Response> getDiaryCharts() async {
    return await _dio.get('$baseUrl/charts');
  }

  /// Get all diary records
  Future<Response> getAllDiaryRecords() async {
    return await _dio.get(baseUrl);
  }
}

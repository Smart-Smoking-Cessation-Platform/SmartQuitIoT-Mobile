import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/errors/exception.dart';
import '../models/today_mission.dart';
import '../models/response/error_response.dart';

class TodayMissionService {
  static final String _baseUrl = 
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';
  
  final Dio _dio;
  static const Duration _timeout = Duration(seconds: 30);

  TodayMissionService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;
  }

  /// Get today's missions from API
  Future<TodayMissionResponse> getTodayMissions({
    required String accessToken,
  }) async {
    try {
      final url = '$_baseUrl/phase-detail-mission/mission-today';
      print('📡 [TodayMissionService] GET: $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('✅ [TodayMissionService] Status: ${response.statusCode}');
      print('📦 [TodayMissionService] Data: ${response.data}');

      if (response.statusCode == 200) {
        return TodayMissionResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final errorResponse = ErrorResponse.fromJson(response.data as Map<String, dynamic>);
        throw TodayMissionException(
          'Server returned ${response.statusCode}: ${errorResponse.message}',
        );
      }
    } on DioException catch (e) {
      print('🚨 [DioException] ${e.message}');
      print('🧩 [StackTrace]: ${StackTrace.current}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw TodayMissionException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw TodayMissionException('Network error. Please check your connection.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 401) {
          throw TodayMissionException('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw TodayMissionException('Access forbidden.');
        } else if (statusCode == 404) {
          throw TodayMissionException('Missions not found.');
        } else if (statusCode! >= 500) {
          throw TodayMissionException('Server error. Please try again later.');
        } else {
          throw TodayMissionException('Request failed with status: $statusCode');
        }
      } else {
        throw TodayMissionException('Network error: ${e.message}');
      }
    } catch (e) {
      print('🚨 [UnknownException] $e');
      print('🧩 [StackTrace]: ${StackTrace.current}');
      throw TodayMissionException('Failed to load today missions: ${e.toString()}');
    }
  }
}


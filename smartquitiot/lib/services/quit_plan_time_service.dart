import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../repositories/auth_repository.dart';

class QuitPlanTimeService {
  final Dio _dio = Dio();
  final AuthRepository _authRepository;
  late final String baseUrl;

  QuitPlanTimeService(this._authRepository) {
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
    baseUrl = '$apiBaseUrl/quit-plan/time';

    // Setup Dio interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authRepository.getAccessToken();
          print('🔑 QuitPlanTime API Token: ${token?.substring(0, 20)}...');
          print('📡 QuitPlanTime Request to: ${options.uri}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ QuitPlanTime Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ QuitPlanTime Error: ${error.message}');
          handler.next(error);
        },
      ),
    );

    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<DateTime> getStartTime() async {
    try {
      final response = await _dio.get(baseUrl);
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final startTimeStr = data['startTime'] as String;
        return DateTime.parse(startTimeStr);
      } else {
        throw Exception('Failed to get start time: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting start time: $e');
      rethrow;
    }
  }
}

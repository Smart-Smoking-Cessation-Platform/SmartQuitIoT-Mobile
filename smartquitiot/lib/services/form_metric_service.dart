import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../models/response/form_metric_response.dart';

class FormMetricService {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  final Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  static const Duration _timeout = Duration(seconds: 30);

  FormMetricService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;
    _logger.i('📊 [FormMetricService] Initialized with base URL: $_baseUrl');
  }

  /// Get form metric data
  Future<FormMetricResponse> getFormMetric({
    required String accessToken,
  }) async {
    try {
      final url = '$_baseUrl/form-metric';
      
      _logger.d('📡 [FormMetricService] GET: $url');
      _logger.d('🔑 [FormMetricService] Token: ${accessToken.substring(0, 20)}...');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      _logger.i('✅ [FormMetricService] Response Status: ${response.statusCode}');
      _logger.d('📦 [FormMetricService] Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final formMetric = FormMetricResponse.fromJson(response.data);
        _logger.i('✅ [FormMetricService] Successfully parsed form metric data');
        return formMetric;
      } else {
        _logger.e('❌ [FormMetricService] Unexpected response: ${response.statusCode}');
        throw Exception('Failed to load form metric: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('❌ [FormMetricService] DioException: ${e.message}');
      _logger.e('❌ [FormMetricService] Response: ${e.response?.data}');
      _logger.e('❌ [FormMetricService] Status: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Form metric not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      _logger.e('❌ [FormMetricService] Unexpected error: $e');
      _logger.e('🧩 [FormMetricService] Stack trace: $stackTrace');
      throw Exception('Failed to load form metric: $e');
    }
  }
}

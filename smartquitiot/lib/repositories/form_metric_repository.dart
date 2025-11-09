import 'package:logger/logger.dart';
import '../models/response/form_metric_response.dart';
import '../services/form_metric_service.dart';

class FormMetricRepository {
  final FormMetricService _formMetricService;
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

  FormMetricRepository(this._formMetricService) {
    _logger.i('📊 [FormMetricRepository] Initialized');
  }

  /// Get form metric data
  Future<FormMetricResponse> getFormMetric({
    required String accessToken,
  }) async {
    try {
      _logger.d('📊 [FormMetricRepository] Fetching form metric...');
      
      final response = await _formMetricService.getFormMetric(
        accessToken: accessToken,
      );

      _logger.i('✅ [FormMetricRepository] Successfully fetched form metric');
      _logger.d('📊 [FormMetricRepository] FTND Score: ${response.ftndScore}');
      _logger.d('📊 [FormMetricRepository] Smoke Avg/Day: ${response.formMetricDTO.smokeAvgPerDay}');
      
      return response;
    } catch (e, stackTrace) {
      _logger.e('❌ [FormMetricRepository] Failed to fetch form metric: $e');
      _logger.e('🧩 [FormMetricRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

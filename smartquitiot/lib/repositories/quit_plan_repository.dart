import '../models/request/create_quit_plan_request.dart';
import '../models/phase.dart';
import '../services/quit_plan_service.dart';
import 'auth_repository.dart';

class QuitPlanRepository {
  final QuitPlanService service;
  final AuthRepository authRepository;

  QuitPlanRepository({required this.service, required this.authRepository});

  Future<Phase> createPlan(CreateQuitPlanRequest request) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('Access token not found. Please login again.');
      }

      final serviceWithToken = QuitPlanService(token: token);
      return await serviceWithToken.createQuitPlan(request);
    } catch (e) {
      throw Exception('Failed to create quit plan: ${e.toString()}');
    }
  }
}

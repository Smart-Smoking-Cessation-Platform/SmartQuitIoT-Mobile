import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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

      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      final baseUrl = '$apiBaseUrl/quit-plan';
      final serviceWithToken = QuitPlanService(token: token, baseUrl: baseUrl);
      return await serviceWithToken.createQuitPlan(request);
    } catch (e) {
      throw Exception('Failed to create quit plan: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getQuitPlan() async {
    // Direct API call from repository (skip service as requested)
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
    final baseUrl = '$apiBaseUrl/quit-plan';

    // Try include token if available, but don't block if none (support local dev)
    String? token;
    try {
      token = await authRepository.getAccessToken();
    } catch (_) {
      token = null;
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to fetch quit plan: ${response.statusCode} ${response.body}',
    );
  }
}

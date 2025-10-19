import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/phase.dart';
import '../models/request/create_quit_plan_request.dart';
import 'token_storage_service.dart';

class QuitPlanService {
  final String token;
  final String baseUrl;

  final TokenStorageService _tokenStorageService = TokenStorageService();

  QuitPlanService({required this.token})
    : baseUrl =
          dotenv.env['API_QUIT_PLAN_URL'] ??
          'http://localhost:8080/api/quit-plan';

  Future<Phase> createQuitPlan(CreateQuitPlanRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create-in-first-login'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Phase.fromJson(json);
    } else {
      throw Exception('Failed to create quit plan: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchQuitPlan() async {
    final token = await _tokenStorageService.getAccessToken();
    if (token == null) {
      throw Exception("Access token is null");
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch quit plan: ${response.body}");
    }
  }
}

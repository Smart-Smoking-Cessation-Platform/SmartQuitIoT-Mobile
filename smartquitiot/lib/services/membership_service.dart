import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart'; // Import package logger
import 'token_storage_service.dart';

class MembershipApiService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0), 
  );
  
  final TokenStorageService _tokenStorageService = TokenStorageService();
  final String _apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  late final String _baseUrl = '$_apiBaseUrl/membership-packages';

  Future<http.Response> getMembershipPackages() async {
    final uri = Uri.parse(_baseUrl);
    try {
      final response = await http.get(uri);
      return response;
    } catch (e) {
      // Dùng .e cho lỗi (Error)
      _logger.e('Network error fetching packages', error: e);
      rethrow;
    }
  }

  Future<http.Response> getPlansForPackage(int packageId) async {
    final uri = Uri.parse('$_baseUrl/plans/$packageId');
    try {
      final response = await http.get(uri);
      return response;
    } catch (e) {
      _logger.e('Network error fetching plans for package $packageId', error: e);
      rethrow;
    }
  }

  Future<http.Response> createPaymentLink({
    required int packageId,
    required int duration,
  }) async {
    final uri = Uri.parse('$_baseUrl/create-payment-link');
    try {
      final accessToken = await _tokenStorageService.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found — user not logged in');
      }
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'membershipPackageId': packageId,
          'duration': duration,
        }),
      );
      return response;
    } catch (e) {
      _logger.e('❌ Network error creating payment link', error: e);
      rethrow;
    }
  }

  Future<http.Response> processPayment(Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/process');
    try {
      // Dùng .i cho thông tin (Info) hoặc .d cho debug
      _logger.i('🌐 [MembershipService] Calling processPayment API...\n🔗 URL: $uri\n📦 Body: $body');
      
      final accessToken = await _tokenStorageService.getAccessToken();

      if (accessToken == null) {
        _logger.e('❌ [MembershipService] No access token found');
        throw Exception('No access token found — user not logged in');
      }

      // Log token có thể nhạy cảm, nên dùng .d (debug)
      _logger.d('🔑 [MembershipService] Token: ${accessToken.substring(0, 20)}...');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.w('⏰ [MembershipService] Request timeout after 30 seconds'); // Dùng .w cho Warning
          throw Exception('Request timeout - please check your internet connection');
        },
      );
      
      _logger.i('📊 [MembershipService] Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      _logger.e('❌ [MembershipService] Network error processing payment', error: e);
      rethrow;
    }
  }

  Future<http.Response> getCurrentSubscription() async {
    final uri = Uri.parse('$_apiBaseUrl/membership-subscriptions/current');

    try {
      final accessToken = await _tokenStorageService.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found — user not logged in');
      }

      _logger.i('📡 [MembershipService] Fetching current subscription...\n🌐 URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      _logger.i('📊 [MembershipService] Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _logger.d('✅ [MembershipService] Successfully fetched current subscription');
      } else {
        _logger.w('❌ [MembershipService] Failed: ${response.body}');
      }

      return response;
    } catch (e) {
      _logger.e('❌ [MembershipService] Network error fetching current subscription', error: e);
      rethrow;
    }
  }
}
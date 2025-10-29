import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'token_storage_service.dart';

class MembershipApiService {
  final TokenStorageService _tokenStorageService = TokenStorageService();
  final String _baseUrl = dotenv.env['API_MEMBERSHIP_URL'] ?? 'http://10.0.2.2:8080/api/membership-packages';
  Future<http.Response> getMembershipPackages() async {
    final uri = Uri.parse(_baseUrl);
    try {
      final response = await http.get(uri);
      return response;
    } catch (e) {
      print('Network error fetching packages: $e');
      rethrow;
    }
  }

  Future<http.Response> getPlansForPackage(int packageId) async {
    final uri = Uri.parse('$_baseUrl/plans/$packageId');
    try {
      final response = await http.get(uri);
      return response;
    } catch (e) {
      print('Network error fetching plans for package $packageId: $e');
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
      print('❌ Network error creating payment link: $e');
      rethrow;
    }
  }

  Future<http.Response> processPayment(Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/process');
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
        body: json.encode(body),
      );
      return response;
    } catch (e) {
      print('❌ Network error processing payment: $e');
      rethrow;
    }
  }

  Future<http.Response> getCurrentSubscription() async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';
    final uri = Uri.parse('$baseUrl/api/membership-subscriptions/current');
    
    try {
      final accessToken = await _tokenStorageService.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found — user not logged in');
      }

      print('📡 [MembershipService] Fetching current subscription...');
      print('🌐 [MembershipService] URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📊 [MembershipService] Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ [MembershipService] Successfully fetched current subscription');
      } else {
        print('❌ [MembershipService] Failed: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ [MembershipService] Network error fetching current subscription: $e');
      rethrow;
    }
  }
}









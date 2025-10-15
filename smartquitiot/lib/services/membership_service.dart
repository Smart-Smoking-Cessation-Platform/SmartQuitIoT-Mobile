import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MembershipApiService {
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
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'membershipPackageId': packageId,
          'duration': duration,
        }),
      );
      return response;
    } catch (e) {
      print('Network error creating payment link: $e');
      rethrow;
    }
  }
}









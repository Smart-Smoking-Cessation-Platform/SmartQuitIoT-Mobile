import '../models/response/payment_link_response.dart';
import 'package:flutter/foundation.dart';
import '../models/membership_package.dart';
import '../models/plan_option.dart';
import '../models/payment_link_data.dart';
import '../models/response/membership_response.dart';
import '../services/membership_service.dart';

class MembershipRepository {
  final MembershipApiService _apiService;

  MembershipRepository({MembershipApiService? apiService})
      : _apiService = apiService ?? MembershipApiService();

  Future<List<MembershipPackage>> fetchMembershipPackages() async {
    try {
      final response = await _apiService.getMembershipPackages();

      if (response.statusCode == 200) {
        return compute(_parsePackages, response.body);
      } else {
        throw Exception('Failed to load membership packages. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in repository: $e');
      throw Exception('Failed to fetch membership packages: $e');
    }
  }

  Future<List<PlanOption>> fetchPlansForPackage(int packageId) async {
    try {
      final response = await _apiService.getPlansForPackage(packageId);
      if (response.statusCode == 200) {
        return planOptionFromJson(response.body);
      } else {
        throw Exception('Failed to load plans for package. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in repository fetching plans: $e');
      throw Exception('Failed to fetch plans: $e');
    }
  }

  Future<PaymentLinkData> createPaymentLink({
    required int packageId,
    required int duration,
  }) async {
    try {
      final response = await _apiService.createPaymentLink(packageId: packageId, duration: duration);
      if (response.statusCode == 201) {
        final paymentResponse = paymentLinkResponseFromJson(response.body);
        if (paymentResponse.success) {
          return paymentResponse.data;
        } else {
          throw Exception('API returned an error: ${paymentResponse.message}');
        }
      } else {
        throw Exception('Failed to create payment link. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in repository creating payment link: $e');
      throw Exception('Failed to create payment link: $e');
    }
  }
}

List<MembershipPackage> _parsePackages(String responseBody) {
  final apiResponse = membershipApiResponseFromJson(responseBody);
  if (apiResponse.success) {
    return apiResponse.data;
  } else {
    throw Exception('API returned an error: ${apiResponse.message}');
  }
}
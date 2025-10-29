import 'dart:convert';

import '../models/membership_subscription.dart';
import '../models/response/payment_link_response.dart';
import '../models/response/current_subscription_response.dart';
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

  Future<MembershipSubscription?> processPaymentResult(Map<String, dynamic> body) async {
    try {
      print('📞 [MembershipRepository] Processing payment result...');
      print('📦 [MembershipRepository] Request body: $body');
      
      final response = await _apiService.processPayment(body);
      
      print('📊 [MembershipRepository] Response Status: ${response.statusCode}');
      print('📦 [MembershipRepository] Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Backend returns GlobalResponse with data field
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final subscription = MembershipSubscription.fromJson(jsonResponse['data']);
          print('✅ [MembershipRepository] Payment processed successfully');
          print('📊 [MembershipRepository] Subscription ID: ${subscription.id}');
          return subscription;
        } else {
          throw Exception('API returned unsuccessful response: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to process payment. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [MembershipRepository] Error processing payment: $e');
      print('🧩 [MembershipRepository] Stack trace: $stackTrace');
      rethrow;
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

  Future<MembershipSubscription?> getCurrentSubscription() async {
    try {
      print('📞 [MembershipRepository] Calling getCurrentSubscription API...');
      final response = await _apiService.getCurrentSubscription();
      
      if (response.statusCode == 200) {
        final subscriptionResponse = CurrentSubscriptionResponse.fromJson(
          jsonDecode(response.body),
        );
        
        print('✅ [MembershipRepository] Current subscription: ${subscriptionResponse.data != null ? "Active" : "None"}');
        return subscriptionResponse.data;
      } else {
        print('❌ [MembershipRepository] Failed to get current subscription. Status: ${response.statusCode}');
        throw Exception('Failed to get current subscription. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [MembershipRepository] Error fetching current subscription: $e');
      rethrow;
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


import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/membership_package.dart';
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
}

List<MembershipPackage> _parsePackages(String responseBody) {
  final apiResponse = membershipApiResponseFromJson(responseBody);
  if (apiResponse.success) {
    return apiResponse.data;
  } else {
    throw Exception('API returned an error: ${apiResponse.message}');
  }
}

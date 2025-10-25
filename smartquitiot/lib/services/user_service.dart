import 'package:dio/dio.dart';
import 'package:SmartQuitIoT/models/user_model.dart';
import 'package:SmartQuitIoT/services/token_storage_service.dart';

class UserService {
  final Dio _dio;
  final TokenStorageService _tokenStorageService;

  UserService({
    required Dio dio,
    required TokenStorageService tokenStorageService,
  }) : _dio = dio,
       _tokenStorageService = tokenStorageService;

  /// Get user profile information
  Future<UserModel> getUserProfile() async {
    try {
      final token = await _tokenStorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      print('🌐 [UserService] Fetching user profile...');

      final response = await _dio.get(
        'https://server.smartquitiot.website/api/members/p',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      print("🔥 RAW RESPONSE: ${response.data}");
      print("🧩 PARSED USER: ${UserModel.fromJson(response.data)}");
      print('✅ [UserService] User profile fetched successfully');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [UserService] Error fetching user profile: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      }
      throw Exception('Failed to fetch user profile: ${e.message}');
    } catch (e) {
      print('❌ [UserService] Unexpected error: $e');
      throw Exception('Unexpected error occurred');
    } catch (e, stack) {
      print("❌ JSON PARSE ERROR: $e");
      print(stack);
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(UpdateUserProfileModel updateData) async {
    try {
      final token = await _tokenStorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      print('🌐 [UserService] Updating user profile...');
      print('📝 [UserService] Update data: ${updateData.toJson()}');

      final response = await _dio.put(
        'https://server.smartquitiot.website/api/members',
        data: updateData.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ [UserService] User profile updated successfully');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [UserService] Error updating user profile: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid data provided');
      }
      throw Exception('Failed to update user profile: ${e.message}');
    } catch (e) {
      print('❌ [UserService] Unexpected error: $e');
      throw Exception('Unexpected error occurred');
    }
  }
}

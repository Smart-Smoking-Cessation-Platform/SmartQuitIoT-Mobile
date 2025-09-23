import '../models/user_profile.dart';
import '../services/api_service.dart';

/// Repository layer - acts as a bridge between ViewModels and API services
/// This layer handles data transformation, caching, and business logic
class UserRepository {
  final ApiService _apiService;

  UserRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get user profile with error handling and data transformation
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final userProfile = await _apiService.getUserProfile(userId);

      // Repository can add business logic here
      // For example: data validation, transformation, caching, etc.

      return userProfile;
    } catch (e) {
      // Repository handles errors and can provide fallback data
      throw UserRepositoryException('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile with validation
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      // Repository can add validation logic
      if (profile.name.isEmpty) {
        throw UserRepositoryException('User name cannot be empty');
      }

      if (profile.email.isEmpty || !profile.email.contains('@')) {
        throw UserRepositoryException('Invalid email format');
      }

      final updatedProfile = await _apiService.updateUserProfile(profile);
      return updatedProfile;
    } catch (e) {
      if (e is UserRepositoryException) {
        rethrow;
      }
      throw UserRepositoryException('Failed to update user profile: $e');
    }
  }

  /// Get user statistics with data transformation
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final stats = await _apiService.getUserStatistics(userId);

      // Repository can transform data before returning
      final transformedStats = {
        ...stats,
        'formattedMoneySaved': '\$${stats['moneySaved']?.toStringAsFixed(2)}',
        'healthLevel': _getHealthLevel(stats['healthScore'] as int),
        'lastUpdatedFormatted': _formatDate(stats['lastUpdated'] as String),
      };

      return transformedStats;
    } catch (e) {
      throw UserRepositoryException('Failed to fetch user statistics: $e');
    }
  }

  /// Get multiple users' profiles (example of repository aggregation)
  Future<List<UserProfile>> getMultipleUserProfiles(
    List<String> userIds,
  ) async {
    try {
      final List<UserProfile> profiles = [];

      for (final userId in userIds) {
        final profile = await getUserProfile(userId);
        profiles.add(profile);
      }

      return profiles;
    } catch (e) {
      throw UserRepositoryException(
        'Failed to fetch multiple user profiles: $e',
      );
    }
  }

  // Private helper methods for data transformation
  String _getHealthLevel(int healthScore) {
    if (healthScore >= 80) return 'Excellent';
    if (healthScore >= 60) return 'Good';
    if (healthScore >= 40) return 'Fair';
    return 'Poor';
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}

/// Custom exception for repository layer
class UserRepositoryException implements Exception {
  final String message;
  UserRepositoryException(this.message);

  @override
  String toString() => 'UserRepositoryException: $message';
}

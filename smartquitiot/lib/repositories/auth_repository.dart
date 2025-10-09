// repositories/auth_repository.dart

import '../core/errors/exception.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';

class AuthRepository {
  final AuthService _authService;
  final TokenStorageService _tokenStorageService;

  AuthRepository({
    AuthService? authService,
    TokenStorageService? tokenStorageService,
  })  : _authService = authService ?? AuthService(),
        _tokenStorageService = tokenStorageService ?? TokenStorageService();

  Future<RegisterResponse> register({
    required String username,
    required String password,
    required String confirmPassword,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
  }) async {
    try {
      final request = RegisterRequest(
        username: username.trim(),
        password: password,
        confirmPassword: confirmPassword,
        email: email.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        gender: gender,
        dob: dob,
      );
      return await _authService.register(request);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  Future<LoginResponse> login(String usernameOrEmail, String password) async {
    try {
      if (usernameOrEmail.isEmpty) {
        throw AuthException('Username or Email cannot be empty');
      }
      if (password.isEmpty) {
        throw AuthException('Password cannot be empty');
      }

      final loginRequest = LoginRequest(
        usernameOrEmail: usernameOrEmail.trim(),
        password: password,
      );
      final loginResponse = await _authService.login(loginRequest);
      await _tokenStorageService.saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );

      return loginResponse;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final accessToken = await _tokenStorageService.getAccessToken();
      if (accessToken != null) {
        await _authService.logout(accessToken);
      }
      await _tokenStorageService.clearTokens();
    } catch (e) {
      await _tokenStorageService.clearTokens();
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  Future<bool> isAuthenticated() async {
    return await _tokenStorageService.isLoggedIn();
  }

  Future<String?> getAccessToken() async {
    return await _tokenStorageService.getAccessToken();
  }

  Future<String?> getRefreshToken() async {
    return await _tokenStorageService.getRefreshToken();
  }

  Future<LoginResponse> refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorageService.getRefreshToken();

      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }

      final loginResponse = await _authService.refreshToken(refreshToken);

      await _tokenStorageService.saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );

      return loginResponse;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Token refresh failed: ${e.toString()}');
    }
  }

  Future<void> clearAuthData() async {
    await _tokenStorageService.clearTokens();
  }

  bool isValidToken(String token) {
    if (token.isEmpty) return false;
    final parts = token.split('.');
    return parts.length == 3;
  }

  Future<String?> getAuthorizationHeader() async {
    final accessToken = await getAccessToken();
    if (accessToken != null && isValidToken(accessToken)) {
      return 'Bearer $accessToken';
    }
    return null;
  }
}
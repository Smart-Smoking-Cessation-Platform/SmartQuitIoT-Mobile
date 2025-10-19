// repositories/auth_repository.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/errors/exception.dart';
import '../models/request/login_request.dart';
import '../models/response/login_response.dart';
import '../models/request/register_request.dart';
import '../models/response/register_response.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class AuthRepository {
  final AuthService _authService;
  final TokenStorageService _tokenStorageService;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthRepository({
    AuthService? authService,
    TokenStorageService? tokenStorageService,
  }) : _authService = authService ?? AuthService(),
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

  Future<String> verifyOtp(String email, String otp) async {
    return await _authService.verifyOtp(email, otp);
  }

  Future<void> resetPassword(String resetToken, String newPassword) async {
    await _authService.resetPassword(resetToken, newPassword);
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

  Future<LoginResponse> loginWithGoogle() async {
    try {
      print('[AuthRepository] Step 1: Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate(
            scopeHint: [
              'openid',
              'https://www.googleapis.com/auth/userinfo.email',
              'https://www.googleapis.com/auth/userinfo.profile',
            ],
          );
      if (googleUser == null) {
        print('[AuthRepository] User cancelled sign-in');
        throw AuthException('Google sign-in cancelled');
      }
      print('[AuthRepository] Got Google user: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw AuthException('Failed to get Google ID Token');
      }
      print('[AuthRepository] Sending ID token to backend...');
      final responseData = await _authService.loginWithGoogle(idToken);
      final loginResponse = LoginResponse.fromJson(responseData);

      await _tokenStorageService.saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );
      print('[AuthRepository] Login successful!');
      return loginResponse;
    } catch (e) {
      print('[AuthRepository] ERROR during Google sign-in: $e');
      await GoogleSignIn.instance.signOut();
      throw AuthException('Google login failed: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    await _authService.forgotPassword(email);
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

  Future<String?> getValidAccessToken() async {
    String? accessToken = await _tokenStorageService.getAccessToken();
    if (accessToken == null || _isTokenExpired(accessToken)) {
      print('[AuthRepository] Access token expired — refreshing...');
      try {
        final newTokens = await refreshAccessToken();
        accessToken = newTokens.accessToken;
        print('[AuthRepository] Token refreshed successfully!');
      } catch (e) {
        print('[AuthRepository] Failed to refresh token: $e');
        rethrow;
      }
    }

    return accessToken;
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('[AuthRepository] Invalid JWT format: $token');
        return true;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);

      // Chỗ này có thể lỗi nếu chuỗi không phải base64 hợp lệ
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      final exp = payloadMap['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      print('[AuthRepository] Token decode error: $e');
      return true; // Nếu decode lỗi → xem như token hết hạn
    }
  }
}

// repositories/auth_repository.dart

import 'package:google_sign_in/google_sign_in.dart';
import '../core/errors/exception.dart';
import '../models/request/login_request.dart';
import '../models/response/login_response.dart';
import '../models/request/register_request.dart';
import '../models/response/register_response.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';
import 'dart:convert';

class AuthRepository {
  final AuthService _authService;
  final TokenStorageService _tokenStorageService;

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

      print('🔐 [AuthRepository] Starting login process...');

      // Clear any existing tokens first to ensure fresh login
      print('🧹 [AuthRepository] Clearing any existing tokens before login...');
      await _tokenStorageService.clearTokens();

      final loginRequest = LoginRequest(
        usernameOrEmail: usernameOrEmail.trim(),
        password: password,
      );
      final loginResponse = await _authService.login(loginRequest);

      print('💾 [AuthRepository] Saving NEW tokens from server...');
      print(
        '   New Access Token: ${loginResponse.accessToken.substring(0, 20)}...',
      );

      // Save new tokens (this will overwrite any existing tokens)
      await _tokenStorageService.saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );
      print('✅ [AuthRepository] New tokens saved successfully!');

      // Verify tokens were saved and are the new ones
      final savedToken = await _tokenStorageService.getAccessToken();
      if (savedToken != null && savedToken == loginResponse.accessToken) {
        print(
          '✅ [AuthRepository] Token verification passed: ${savedToken.substring(0, 20)}...',
        );
      } else {
        print('❌ [AuthRepository] WARNING: Token verification failed!');
        throw AuthException('Failed to save access token properly');
      }

      return loginResponse;
    } catch (e) {
      print('❌ [AuthRepository] Login failed: $e');
      // Clear tokens on login failure to ensure clean state
      await _tokenStorageService.clearTokens();
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
    print('🚪 [AuthRepository] Starting logout process...');
    try {
      // Get access token before clearing
      final accessToken = await _tokenStorageService.getAccessToken();

      // Try to notify backend (non-blocking - we clear tokens regardless)
      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          print('📡 [AuthRepository] Notifying backend of logout...');
          await _authService.logout(accessToken);
          print('✅ [AuthRepository] Backend logout successful');
        } catch (e) {
          // Log but don't fail - we still need to clear local tokens
          print('⚠️ [AuthRepository] Backend logout failed (non-critical): $e');
        }
      } else {
        print(
          '⚠️ [AuthRepository] No access token found, skipping backend logout',
        );
      }

      // ALWAYS clear tokens locally, regardless of backend response
      print('🗑️ [AuthRepository] Clearing local tokens...');
      await _tokenStorageService.clearTokens();

      // Verify tokens are actually cleared
      final verifyAccessToken = await _tokenStorageService.getAccessToken();
      final verifyRefreshToken = await _tokenStorageService.getRefreshToken();

      if (verifyAccessToken == null && verifyRefreshToken == null) {
        print('✅ [AuthRepository] Logout successful - all tokens cleared');
      } else {
        print('❌ [AuthRepository] WARNING: Tokens may not be fully cleared!');
        // Force clear again
        await _tokenStorageService.clearTokens();
      }
    } catch (e) {
      // Even if everything fails, ensure tokens are cleared
      print('❌ [AuthRepository] Logout error: $e - Force clearing tokens...');
      await _tokenStorageService.clearTokens();
      // Don't throw - logout should always succeed in clearing local tokens
      print('✅ [AuthRepository] Tokens cleared despite error');
    }
  }

  Future<LoginResponse> loginWithGoogle() async {
    try {
      print('🔐 [AuthRepository] Starting Google Sign-In...');

      // Clear any existing tokens first to ensure fresh login
      print(
        '🧹 [AuthRepository] Clearing any existing tokens before Google login...',
      );
      await _tokenStorageService.clearTokens();

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate(
            scopeHint: [
              'openid',
              'https://www.googleapis.com/auth/userinfo.email',
              'https://www.googleapis.com/auth/userinfo.profile',
            ],
          );
      print('[AuthRepository] Got Google user: ${googleUser.email}');
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw AuthException('Failed to get Google ID Token');
      }
      print('[AuthRepository] Sending ID token to backend...');
      final responseData = await _authService.loginWithGoogle(idToken);
      final loginResponse = LoginResponse.fromJson(responseData);

      print('💾 [AuthRepository] Saving NEW tokens from Google login...');
      await _tokenStorageService.saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );

      // Verify tokens were saved
      final savedToken = await _tokenStorageService.getAccessToken();
      if (savedToken != null && savedToken == loginResponse.accessToken) {
        print('✅ [AuthRepository] Google login successful - tokens verified!');
      } else {
        print('❌ [AuthRepository] WARNING: Token verification failed!');
        throw AuthException('Failed to save access token properly');
      }

      return loginResponse;
    } catch (e) {
      print('❌ [AuthRepository] ERROR during Google sign-in: $e');
      await GoogleSignIn.instance.signOut();
      // Clear tokens on failure
      await _tokenStorageService.clearTokens();
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
    print('🔍 [AuthRepository] Getting access token...');
    final token = await _tokenStorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      print('⚠️ [AuthRepository] Token is NULL or EMPTY!');
      final isAuth = await isAuthenticated();
      print('⚠️ [AuthRepository] isAuthenticated: $isAuth');
    } else {
      print('✅ [AuthRepository] Token retrieved: ${token.substring(0, 20)}...');
    }
    return token;
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

  /// Get user ID from JWT token for WebSocket initialization
  Future<int?> getUserId() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) {
        print('[AuthRepository] No access token available');
        return null;
      }

      final parts = token.split('.');
      if (parts.length != 3) {
        print('[AuthRepository] Invalid JWT format');
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      // JWT token có thể chứa 'sub', 'userId', 'id', hoặc 'memberId'
      final userId =
          payloadMap['sub'] ??
          payloadMap['userId'] ??
          payloadMap['id'] ??
          payloadMap['memberId'];

      if (userId != null) {
        return int.tryParse(userId.toString());
      }

      print('[AuthRepository] No user ID found in token');
      return null;
    } catch (e) {
      print('[AuthRepository] Error getting user ID: $e');
      return null;
    }
  }

  /// Get account ID from JWT token for WebSocket initialization
  Future<int?> getAccountId() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) {
        print('[AuthRepository] No access token available');
        return null;
      }

      final parts = token.split('.');
      if (parts.length != 3) {
        print('[AuthRepository] Invalid JWT format');
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      // Lấy accountId từ JWT token
      final accountId = payloadMap['accountId'];

      if (accountId != null) {
        return int.tryParse(accountId.toString());
      }

      print('[AuthRepository] No accountId found in token');
      return null;
    } catch (e) {
      print('[AuthRepository] Error getting accountId: $e');
      return null;
    }
  }
}

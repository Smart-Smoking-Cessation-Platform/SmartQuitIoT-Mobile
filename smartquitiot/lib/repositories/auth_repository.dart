// repositories/auth_repository.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      print('[AuthRepository] Step 1: Starting Google authenticate...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile']
      );

      if (googleUser == null) {
        print('[AuthRepository] Step 2: User cancelled login.');
        throw Exception('Google sign-in was cancelled');
      }

      print('[AuthRepository] Step 2: Got Google User: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print('[AuthRepository] Step 3: FAILED to get idToken.');
        throw Exception('Failed to get Google ID Token');
      }

      print('[AuthRepository] Step 3: Got idToken. Sending to AuthService...');
      // Dòng print dưới đây sẽ cho chúng ta thấy token trông như thế nào
      // print('[AuthRepository] Token: ${idToken.substring(0, 30)}...'); // In ra 30 ký tự đầu

      final result = await _authService.loginWithGoogle(idToken);
      print('[AuthRepository] Step 4: Got SUCCESS response from backend.');
      return result;

    } catch (e) {
      // ĐÂY LÀ CHỖ QUAN TRỌNG NHẤT
      print('[AuthRepository] !!!! CATCHING ERROR !!!!');
      print('[AuthRepository] Error type: ${e.runtimeType}');
      print('[AuthRepository] Error message: $e');

      await _googleSignIn.signOut();
      rethrow;
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
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/errors/exception.dart';
import '../models/auth/common/error_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';


class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/auth';
  static const String _accountsBaseUrl = 'http://10.0.2.2:8080/api/accounts';
  static const Duration _timeout = Duration(seconds: 30);

  /// Register a new user
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_accountsBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw AuthException(errorResponse.message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException {
      throw AuthException('Invalid response format from server.');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }


  /// Login with username and password
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/member'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        // Handle error response
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw AuthException(errorResponse.message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException {
      throw AuthException('Invalid response format from server.');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/refresh'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw AuthException(errorResponse.message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException {
      throw AuthException('Invalid response format from server.');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Token refresh failed: ${e.toString()}');
    }
  }


  Future<void> logout(String accessToken) async {
    try {
      await http
          .post(
            Uri.parse('$_baseUrl/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(_timeout);
    } catch (e) {
      // Logout errors are usually not critical
      // We can ignore them and just clear local storage
    }
  }
}


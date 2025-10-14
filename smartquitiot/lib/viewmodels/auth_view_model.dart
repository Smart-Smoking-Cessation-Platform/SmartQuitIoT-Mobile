import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/auth/auth_state.dart';
import '../repositories/auth_repository.dart';
import '../models/auth/login_response.dart';


class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState());


  String? _decodeUsername(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['username'];
    } catch (e) {
      return null;
    }
  }


  Future<bool> register({
    required String username,
    required String password,
    required String confirmPassword,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.register(
        username: username,
        password: password,
        confirmPassword: confirmPassword,
        email: email,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dob: dob,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _authRepository.loginWithGoogle();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isFirstLogin: response.firstLogin,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final accessToken = await _authRepository.getAccessToken();
        final username = _decodeUsername(accessToken);
        state = state.copyWith(
          isAuthenticated: true,
          accessToken: accessToken,
          refreshToken: await _authRepository.getRefreshToken(),
          username: username,
        );
        return true;
      }
      state = state.clearAuth();
      return false;
    } catch (e) {
      await _authRepository.clearAuthData();
      state = state.clearAuth();
      return false;
    }
  }

  Future<bool> resetPassword(String resetToken, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.resetPassword(resetToken, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Đăng nhập với username/email và password
  Future<bool> login(String usernameOrEmail, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loginResponse = await _authRepository.login(usernameOrEmail, password);
      final username = _decodeUsername(loginResponse.accessToken);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        isFirstLogin: loginResponse.firstLogin,
        username: username,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resetToken = await _authRepository.verifyOtp(email, otp);
      state = state.copyWith(isLoading: false);
      return resetToken;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Đăng xuất người dùng
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.logout();
      state = state.clearAuth();
    } catch (e) {
      state = state.clearAuth();
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  // Getters để UI dễ dàng truy cập
  bool? get isFirstLogin => state.isFirstLogin;
  String? get username => state.username;
}

// Providers (giữ nguyên)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});
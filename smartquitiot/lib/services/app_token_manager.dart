// services/app_token_manager.dart
import 'package:flutter/material.dart';
import 'token_storage_service.dart';

class AppTokenManager with WidgetsBindingObserver {
  final TokenStorageService _tokenService = TokenStorageService();

  AppTokenManager._privateConstructor();

  static final AppTokenManager instance = AppTokenManager._privateConstructor();

  /// Gọi khi app start
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _clearTokensOnStart();
  }

  /// Clear token ngay khi app start
  Future<void> _clearTokensOnStart() async {
    await _tokenService.clearTokens();
    debugPrint('[AppTokenManager] Tokens cleared on app start.');
  }

  /// Lifecycle observer
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _tokenService.clearTokens();
      debugPrint(
        '[AppTokenManager] Tokens cleared due to app lifecycle: $state',
      );
    }
  }

  /// Dispose observer nếu cần
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

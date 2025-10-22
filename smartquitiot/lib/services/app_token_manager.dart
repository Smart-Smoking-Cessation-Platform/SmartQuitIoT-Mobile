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
    // ❌ REMOVED: Do NOT clear tokens on app start!
    // Users should stay logged in between app sessions
    // await _clearTokensOnStart();
    debugPrint('[AppTokenManager] Initialized - tokens preserved');
  }

  /// ❌ DISABLED: Do NOT clear tokens on app start
  /// Tokens should only be cleared on explicit logout
  // Future<void> _clearTokensOnStart() async {
  //   await _tokenService.clearTokens();
  //   debugPrint('[AppTokenManager] Tokens cleared on app start.');
  // }

  /// Lifecycle observer
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ❌ DISABLED: Do NOT clear tokens on lifecycle changes!
    // This causes users to be logged out when app goes to background
    // Tokens should only be cleared on explicit logout
    
    // Log lifecycle changes for debugging
    debugPrint('[AppTokenManager] App lifecycle changed to: $state');
    
    // if (state == AppLifecycleState.inactive ||
    //     state == AppLifecycleState.detached) {
    //   _tokenService.clearTokens();
    //   debugPrint(
    //     '[AppTokenManager] Tokens cleared due to app lifecycle: $state',
    //   );
    // }
  }

  /// Dispose observer nếu cần
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

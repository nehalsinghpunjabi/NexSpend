import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  User? get currentUser =>
      SupabaseConfig.isConfigured ? _client.auth.currentUser : null;

  @override
  Stream<AuthState> authStateChanges() => SupabaseConfig.isConfigured
      ? _client.auth.onAuthStateChange
      : Stream.value(const AuthState(AuthChangeEvent.signedOut, null));

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      // Browsers cannot open the mobile app's custom URI scheme. Returning to
      // the current web origin lets Supabase restore the session from the URL;
      // native builds retain the registered Android/iOS deep link.
      redirectTo: kIsWeb
          ? Uri.base.origin
          : 'com.nexspend.nexspend://login-callback/',
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

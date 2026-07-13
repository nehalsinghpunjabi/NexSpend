import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRepository {
  Stream<AuthState> authStateChanges();
  User? get currentUser;
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

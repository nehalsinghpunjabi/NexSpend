import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/supabase_auth_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../../onboarding/data/repositories/supabase_profile_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(),
);
final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
final currentPersonaProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return null;
  return ref.watch(profileRepositoryProvider).getOrCreatePersona(user.id);
});

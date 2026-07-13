import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(),
);

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<String?> getOrCreatePersona(String userId) async {
    // Covers existing Auth users created before the database migration and is
    // idempotent for all later app launches. The database trigger handles new
    // Auth users as an additional server-side guarantee.
    await _client.from('profiles').upsert({'id': userId}, onConflict: 'id');
    final row = await _client
        .from('profiles')
        .select('persona')
        .eq('id', userId)
        .maybeSingle();
    return row?['persona'] as String?;
  }

  @override
  Future<void> savePersona({required String userId, required String persona}) =>
      _client.from('profiles').upsert({
        'id': userId,
        'persona': persona,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
}

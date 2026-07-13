abstract interface class ProfileRepository {
  /// Creates the profile when this is the user's first authenticated session,
  /// then returns the persisted onboarding persona (if one was selected).
  Future<String?> getOrCreatePersona(String userId);
  Future<void> savePersona({required String userId, required String persona});
}

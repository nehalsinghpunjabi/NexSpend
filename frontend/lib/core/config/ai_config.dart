enum AiProviderKind { groq, openAi }

/// Compile-time configuration keeps provider keys out of source control.
abstract final class AiConfig {
  static const _provider = String.fromEnvironment(
    'AI_PROVIDER',
    defaultValue: 'groq',
  );
  static const groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const groqApiBaseUrl = String.fromEnvironment(
    'GROQ_API_BASE_URL',
    defaultValue: 'https://api.groq.com/openai/v1',
  );
  static const groqModel = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  static AiProviderKind get provider => _provider.toLowerCase() == 'openai'
      ? AiProviderKind.openAi
      : AiProviderKind.groq;

  static bool get isGroqConfigured => groqApiKey.trim().isNotEmpty;
}

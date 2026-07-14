import '../../domain/models/ai_models.dart';
import '../../domain/providers/ai_provider.dart';

/// Reserved for a future OpenAI Responses API implementation.
class OpenAiProvider implements AiProvider {
  @override
  Future<Map<String, dynamic>> complete(AiProviderRequest request) =>
      throw const AiProviderException(
        'The OpenAI provider is not enabled yet. Set AI_PROVIDER=groq.',
      );
}

import '../../domain/models/ai_models.dart';
import '../../domain/providers/ai_provider.dart';
import '../../domain/repositories/ai_repository.dart';

class ProviderAiRepository implements AiRepository {
  const ProviderAiRepository(this._provider);
  final AiProvider _provider;

  @override
  Future<AiAnswer> ask(AiProviderRequest request) async =>
      AiAnswer.fromJson(await _provider.complete(request));
}

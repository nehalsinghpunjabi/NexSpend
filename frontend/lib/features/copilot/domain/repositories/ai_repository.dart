import '../models/ai_models.dart';

abstract interface class AiRepository {
  Future<AiAnswer> ask(AiProviderRequest request);
}

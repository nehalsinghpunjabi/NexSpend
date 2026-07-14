import '../models/ai_models.dart';

abstract interface class AiProvider {
  Future<Map<String, dynamic>> complete(AiProviderRequest request);
}

class AiProviderException implements Exception {
  const AiProviderException(this.message);
  final String message;
  @override
  String toString() => message;
}

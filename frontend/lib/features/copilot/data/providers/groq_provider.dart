import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/ai_config.dart';
import '../../domain/models/ai_models.dart';
import '../../domain/providers/ai_provider.dart';

class GroqProvider implements AiProvider {
  GroqProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<Map<String, dynamic>> complete(AiProviderRequest request) async {
    if (!AiConfig.isGroqConfigured) {
      throw const AiProviderException(
        'Groq is not configured. Add GROQ_API_KEY to your runtime environment.',
      );
    }

    final uri = Uri.parse('${AiConfig.groqApiBaseUrl}/chat/completions');
    Object? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _client
            .post(
              uri,
              headers: {
                'Authorization': 'Bearer ${AiConfig.groqApiKey}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': AiConfig.groqModel,
                'temperature': 0.2,
                'messages': [
                  {'role': 'system', 'content': request.systemPrompt},
                  {
                    'role': 'user',
                    'content':
                        '${request.question}\n\nStructured analytics:\n${jsonEncode(request.analytics)}',
                  },
                ],
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return _parse(response.body);
        }
        lastError = AiProviderException(
          'Groq request failed (${response.statusCode}).',
        );
        if (response.statusCode < 500 && response.statusCode != 429) {
          break;
        }
      } on TimeoutException {
        lastError = const AiProviderException(
          'The AI request timed out. Please try again.',
        );
      } catch (error) {
        lastError = error;
      }
      await Future<void>.delayed(Duration(milliseconds: 350 * (attempt + 1)));
    }

    throw lastError is AiProviderException
        ? lastError
        : AiProviderException('Unable to reach Groq: $lastError');
  }

  Map<String, dynamic> _parse(String body) {
    final payload = jsonDecode(body) as Map<String, dynamic>;
    final choices = payload['choices'] as List<dynamic>? ?? const [];
    final firstChoice = choices.isEmpty
        ? null
        : choices.first as Map<String, dynamic>;
    final content =
        (firstChoice?['message'] as Map<String, dynamic>?)?['content']
            ?.toString() ??
        '';
    try {
      final clean = content
          .replaceFirst(RegExp(r'^```json\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '');
      return jsonDecode(clean) as Map<String, dynamic>;
    } catch (_) {
      return {
        'type': 'spending',
        'answer': content,
        'confidence': 'medium',
        'highlights': <String>[],
      };
    }
  }
}

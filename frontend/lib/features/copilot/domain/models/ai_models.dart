import 'dart:convert';

enum AiAnswerKind {
  spending,
  category,
  merchant,
  budget,
  health,
  recommendation,
}

enum AiMessageRole { user, assistant }

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.isLoading = false,
    this.isError = false,
  });

  final String id;
  final AiMessageRole role;
  final String text;
  final DateTime createdAt;
  final bool isLoading;
  final bool isError;
}

sealed class AiAnswer {
  const AiAnswer({
    required this.kind,
    required this.answer,
    required this.confidence,
    required this.highlights,
  });

  final AiAnswerKind kind;
  final String answer;
  final String confidence;
  final List<String> highlights;

  factory AiAnswer.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString().toLowerCase() ?? 'spending';
    final kind = switch (rawType) {
      'category' => AiAnswerKind.category,
      'merchant' => AiAnswerKind.merchant,
      'budget' => AiAnswerKind.budget,
      'health' => AiAnswerKind.health,
      'recommendation' => AiAnswerKind.recommendation,
      _ => AiAnswerKind.spending,
    };
    final answer = _answerText(json['answer']);
    final highlights = (json['highlights'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final confidence = json['confidence']?.toString() ?? 'medium';
    return switch (kind) {
      AiAnswerKind.category => CategoryAnswer(
        answer: answer,
        confidence: confidence,
        highlights: highlights,
      ),
      AiAnswerKind.merchant => MerchantAnswer(
        answer: answer,
        confidence: confidence,
        highlights: highlights,
      ),
      AiAnswerKind.budget => BudgetAnswer(
        answer: answer,
        confidence: confidence,
        highlights: highlights,
      ),
      AiAnswerKind.health => HealthScoreAnswer(
        answer: answer,
        confidence: confidence,
        highlights: highlights,
      ),
      AiAnswerKind.recommendation => RecommendationAnswer(
        answer: answer,
        confidence: confidence,
        highlights: highlights,
      ),
      AiAnswerKind.spending => SpendingAnswer(
        answer: answer,
        confidence: confidence,
        highlights: highlights,
      ),
    };
  }

  /// Ensures that a provider response accidentally nested as a JSON string
  /// still renders only its user-facing answer, never its metadata payload.
  static String? _answerText(Object? value) {
    if (value is Map<Object?, Object?>) {
      return _answerText(value['answer']);
    }
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    final jsonText = text
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '');
    if (!jsonText.startsWith('{') || !jsonText.endsWith('}')) {
      final embeddedPayloadStart = jsonText.indexOf(RegExp(r'\{\s*"type"'));
      if (embeddedPayloadStart <= 0) return text;
      return _answerText(jsonText.substring(embeddedPayloadStart));
    }
    try {
      final decoded = jsonDecode(jsonText);
      return decoded is Map<Object?, Object?>
          ? _answerText(decoded['answer'])
          : text;
    } on FormatException {
      return text;
    }
  }
}

class SpendingAnswer extends AiAnswer {
  SpendingAnswer({
    String? answer,
    required super.confidence,
    required super.highlights,
  }) : super(
         kind: AiAnswerKind.spending,
         answer: answer?.isNotEmpty == true
             ? answer!
             : 'I do not have enough information to answer that.',
       );
}

class CategoryAnswer extends AiAnswer {
  CategoryAnswer({
    String? answer,
    required super.confidence,
    required super.highlights,
  }) : super(
         kind: AiAnswerKind.category,
         answer: answer?.isNotEmpty == true
             ? answer!
             : 'I do not have enough information to answer that.',
       );
}

class MerchantAnswer extends AiAnswer {
  MerchantAnswer({
    String? answer,
    required super.confidence,
    required super.highlights,
  }) : super(
         kind: AiAnswerKind.merchant,
         answer: answer?.isNotEmpty == true
             ? answer!
             : 'I do not have enough information to answer that.',
       );
}

class BudgetAnswer extends AiAnswer {
  BudgetAnswer({
    String? answer,
    required super.confidence,
    required super.highlights,
  }) : super(
         kind: AiAnswerKind.budget,
         answer: answer?.isNotEmpty == true
             ? answer!
             : 'I do not have enough information to answer that.',
       );
}

class HealthScoreAnswer extends AiAnswer {
  HealthScoreAnswer({
    String? answer,
    required super.confidence,
    required super.highlights,
  }) : super(
         kind: AiAnswerKind.health,
         answer: answer?.isNotEmpty == true
             ? answer!
             : 'I do not have enough information to answer that.',
       );
}

class RecommendationAnswer extends AiAnswer {
  RecommendationAnswer({
    String? answer,
    required super.confidence,
    required super.highlights,
  }) : super(
         kind: AiAnswerKind.recommendation,
         answer: answer?.isNotEmpty == true
             ? answer!
             : 'I do not have enough information to answer that.',
       );
}

class AiProviderRequest {
  const AiProviderRequest({
    required this.systemPrompt,
    required this.question,
    required this.analytics,
  });
  final String systemPrompt;
  final String question;
  final Map<String, dynamic> analytics;
}

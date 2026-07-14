import 'package:flutter_test/flutter_test.dart';
import 'package:nexspend/features/copilot/domain/models/ai_models.dart';

void main() {
  test('renders only the nested answer from a raw JSON answer payload', () {
    final answer = AiAnswer.fromJson({
      'type': 'spending',
      'answer':
          '''{"type":"merchant","answer":"You spent ₹1,000 at Bata this month.","confidence":"high","highlights":["Bata"]}''',
      'confidence': 'medium',
      'highlights': ['debug payload'],
    });

    expect(answer.answer, 'You spent ₹1,000 at Bata this month.');
  });
}

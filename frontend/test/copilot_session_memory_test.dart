import 'package:flutter_test/flutter_test.dart';
import 'package:nexspend/features/copilot/domain/models/copilot_session_memory.dart';

void main() {
  test('retains income, budget, and purchase goal for the active session', () {
    final memory = const CopilotSessionMemory()
        .updateFromMessage('My monthly income is ₹30,000.')
        .updateFromMessage('My monthly budget is ₹18,000.')
        .updateFromMessage('I want to buy AirPods next month.');

    expect(memory.monthlyIncome, 30000);
    expect(memory.monthlyBudget, 18000);
    expect(memory.goals, contains('I want to buy AirPods next month.'));
  });
}

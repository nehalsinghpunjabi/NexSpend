import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexspend/app.dart';

void main() {
  testWidgets('shows the NexSpend welcome screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NexSpendApp()));
    await tester.pump();
    expect(find.text('NexSpend'), findsOneWidget);
  });
}

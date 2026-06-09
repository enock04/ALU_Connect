import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_connect/app/app.dart';

void main() {
  testWidgets('ALU Connect app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ALUConnectApp()));
    expect(find.byType(ALUConnectApp), findsOneWidget);
  });
}

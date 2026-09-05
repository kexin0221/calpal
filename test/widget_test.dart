import 'package:flutter_test/flutter_test.dart';
import 'package:CalPal/main.dart';

void main() {
  testWidgets('CalPal launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CalPal());

    // 首页搜索框存在，说明启动成功
    expect(find.byType(CalPal), findsOneWidget);
  });
}
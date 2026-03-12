import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:isms_mobile/app/app.dart';

void main() {
  testWidgets('app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IsmsMobileApp()));
    await tester.pump();

    expect(find.text('ISMS Mobile'), findsOneWidget);
  });
}

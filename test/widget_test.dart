import 'package:flutter_test/flutter_test.dart';
import 'package:rupa_rempah_app/main.dart';

void main() {
  testWidgets('menampilkan splash Rupa Rempah', (tester) async {
    await tester.pumpWidget(const RupaRempahApp());
    expect(find.text('Rupa Rempah'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
  });
}

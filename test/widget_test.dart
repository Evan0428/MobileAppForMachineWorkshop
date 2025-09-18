import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gearup_workshop_mechanics/main.dart';

void main() {
  testWidgets('Login shows first when not logged in; Dashboard after login',
          (WidgetTester tester) async {
        TestWidgetsFlutterBinding.ensureInitialized();
        SharedPreferences.setMockInitialValues({'logged_in': false});

        await tester.pumpWidget(const GearUpApp());
        await tester.pumpAndSettle();


        expect(find.text('GearUp WorkShop'), findsOneWidget);
        expect(find.text('Log In'), findsOneWidget);


        await tester.enterText(find.byType(TextFormField).at(0), 'tech');
        await tester.enterText(find.byType(TextFormField).at(1), '123456');
        await tester.tap(find.text('Log In'));
        await tester.pumpAndSettle();


        expect(find.textContaining('My Jobs'), findsOneWidget);
      });
}

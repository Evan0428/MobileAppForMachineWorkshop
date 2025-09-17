<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:greenstem_workshop_mechanics/main.dart';

void main() {
  testWidgets('Dashboard renders and navigates to Job Detail', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({}); // mock prefs

    await tester.pumpWidget(const GreenstemMechanicApp());
    await tester.pumpAndSettle();

    expect(find.text('My Jobs'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Engine Oil & Filter Change'), findsOneWidget);
    expect(find.text('Brake Pad Replacement (Front)'), findsOneWidget);

    await tester.tap(find.text('Engine Oil & Filter Change'));
    await tester.pumpAndSettle();

    expect(find.text('Job Description'), findsOneWidget);
    expect(find.text('Customer & Vehicle'), findsOneWidget);
    expect(find.text('Time Tracking'), findsOneWidget);

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
=======
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:greenstem_workshop_mechanics/main.dart';

void main() {
  testWidgets('Dashboard renders and navigates to Job Detail', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({}); // mock prefs

    await tester.pumpWidget(const GreenstemMechanicApp());
    await tester.pumpAndSettle();

    expect(find.text('My Jobs'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Engine Oil & Filter Change'), findsOneWidget);
    expect(find.text('Brake Pad Replacement (Front)'), findsOneWidget);

    await tester.tap(find.text('Engine Oil & Filter Change'));
    await tester.pumpAndSettle();

    expect(find.text('Job Description'), findsOneWidget);
    expect(find.text('Customer & Vehicle'), findsOneWidget);
    expect(find.text('Time Tracking'), findsOneWidget);

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
>>>>>>> df8ba06 (Initial)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timbo_app/config/routes.dart';
import 'package:timbo_app/providers/user_provider.dart';
import 'package:timbo_app/services/hive_service.dart';
import 'dart:io';

Widget _buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: MaterialApp(
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    ),
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('widget_test_');
    SharedPreferences.setMockInitialValues({});
    await HiveService.instance.init(testPath: tempDir.path);
  });

  tearDown(() async {
    await HiveService.instance.dispose();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('Fresh app shows splash with Timbo and tagline',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());

    expect(find.text('Timbo'), findsOneWidget);
    expect(find.text('Capture Everything. Forget Nothing.'), findsOneWidget);
  }, skip: true);

  testWidgets('Onboarding complete without user goes to login',
      (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    await tester.pumpWidget(_buildTestApp());
    await tester.pump(const Duration(seconds: 6));
    await tester.pump();

    expect(find.text('Sign In'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 15)));
}

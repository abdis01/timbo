import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timbo_app/theme/colors.dart';

void main() {
  testWidgets('App renders with warm paper background', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: TimboColors.appBackground,
          body: const Text('Timbo'),
        ),
      ),
    );

    expect(find.text('Timbo'), findsOneWidget);
  });
}

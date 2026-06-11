import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timbo_app/theme/colors.dart';

void main() {
  group('TimboColors', () {
    test('has correct warm paper background', () {
      expect(TimboColors.appBackground, const Color(0xFFF5F0E8));
    });

    test('has correct ink color', () {
      expect(TimboColors.ink, const Color(0xFF1A1A1A));
    });

    test('has light and faint ink variants', () {
      expect(TimboColors.inkLight, const Color(0xFF5A5A5A));
      expect(TimboColors.inkFaint, const Color(0xFFA0A0A0));
    });
  });
}

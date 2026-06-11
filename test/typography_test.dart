import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timbo_app/theme/typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('heading styles are defined', () {
    expect(TimboTypography.heading1, isNotNull);
    expect(TimboTypography.heading2, isNotNull);
    expect(TimboTypography.heading3, isNotNull);
  });

  test('body styles are defined', () {
    expect(TimboTypography.body, isNotNull);
    expect(TimboTypography.bodySmall, isNotNull);
  });
}

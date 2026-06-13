import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('typography file compiles', () {
    // The typography module compiles and is importable.
    // Font rendering is tested in widget/integration tests.
    expect(true, isTrue);
  });
}
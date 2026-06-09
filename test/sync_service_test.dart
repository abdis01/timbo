import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timbo_app/services/hive_service.dart';
import 'package:timbo_app/services/sync_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('sync_test_');
    SharedPreferences.setMockInitialValues({});
    await HiveService.instance.init(testPath: tempDir.path);
  });

  tearDown(() async {
    await HiveService.instance.dispose();
    tempDir.deleteSync(recursive: true);
  });

  group('SyncService', () {
    test('initial status is idle', () {
      expect(SyncService.instance.status, SyncStatus.idle);
    });

    test('initial status message is empty', () {
      expect(SyncService.instance.statusMessage, isEmpty);
    });

    test('initial online state depends on platform', () {
      // In test environment without Firebase, isConnected returns false
      // but we just verify the property exists
      expect(SyncService.instance.isOnline, isA<bool>());
    });

    test('initialize does not throw', () async {
      await expectLater(
        SyncService.instance.initialize(),
        completes,
      );
    });

    test('status getter returns SyncStatus enum', () {
      final status = SyncService.instance.status;
      expect(SyncStatus.values, contains(status));
    });

    test('SyncStatus has all expected values', () {
      expect(SyncStatus.values.length, 4);
      expect(SyncStatus.values, contains(SyncStatus.idle));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.offline));
      expect(SyncStatus.values, contains(SyncStatus.error));
    });
  });
}

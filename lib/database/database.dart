import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'captures_table.dart';
import 'tables/folders_table.dart';
import 'tables/timbos_table.dart';
import 'tables/blocks_table.dart';
import 'tables/chat_messages_table.dart';
import 'daos/folder_dao.dart';
import 'daos/timbo_dao.dart';
import 'daos/block_dao.dart';
import 'daos/chat_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Captures, Folders, Timbos, Blocks, ChatMessages],
  daos: [FolderDao, TimboDao, BlockDao, ChatDao],
)
class TimboDatabase extends _$TimboDatabase {
  TimboDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(folders);
          await m.createTable(timbos);
          await m.createTable(blocks);
          await m.createTable(chatMessages);
        }
        if (from < 3) {
          await m.addColumn(blocks, blocks.drawingData);
          await m.addColumn(blocks, blocks.fontFamily);
        }
        if (from < 4) {
          await m.addColumn(blocks, blocks.positionX);
          await m.addColumn(blocks, blocks.positionY);
          await m.addColumn(blocks, blocks.blockWidth);
          await m.addColumn(blocks, blocks.blockHeight);
        }
      },
    );
  }

  Future<int> insertCapture(Insertable<Capture> capture) =>
      into(captures).insert(capture);

  Future<void> updateCapture(Insertable<Capture> capture) =>
      update(captures).replace(capture);

  Future<Capture?> getCapture(int id) =>
      (select(captures)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Capture>> getAllCaptures() =>
      (select(captures)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();

  Future<List<Capture>> getCapturesByType(String type) =>
      (select(captures)
        ..where((t) => t.type.equals(type))
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .get();

  Future<List<Capture>> getUnsyncedCaptures() =>
      (select(captures)..where((t) => t.isSynced.equals(false))).get();

  Future<List<Capture>> searchCaptures(String query) {
    final q = '%$query%';
    return (select(captures)
      ..where((t) => t.content.like(q) | t.rawInput.like(q))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  Future<int> getTodayCaptureCount() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(captures)
      ..where((t) => t.createdAt.isBetweenValues(start, end)))
        .get()
        .then((r) => r.length);
  }

  Future<List<Capture>> getRecentCaptures({int limit = 5}) =>
      (select(captures)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
        ..limit(limit))
          .get();

  Future<List<Capture>> getTodayReminders() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(captures)
      ..where((t) =>
          t.type.equals('reminder') &
          t.isCompleted.equals(false) &
          t.scheduledAt.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt, mode: OrderingMode.asc)]))
        .get();
  }

  Future<void> markCompleted(int id) =>
      (update(captures)..where((t) => t.id.equals(id)))
          .write(const CapturesCompanion(isCompleted: Value(true)));

  Future<void> markSynced(int id) =>
      (update(captures)..where((t) => t.id.equals(id)))
          .write(const CapturesCompanion(isSynced: Value(true)));

  Future<void> markAiProcessed(int id) =>
      (update(captures)..where((t) => t.id.equals(id)))
          .write(const CapturesCompanion(isAiProcessed: Value(true)));

  Future<void> deleteCapture(int id) =>
      (delete(captures)..where((t) => t.id.equals(id))).go();

  Stream<List<Capture>> watchAllCaptures() => select(captures).watch();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(p.join(dir.path, 'timbo_db')).create(recursive: true);
    final file = File(p.join(dir.path, 'timbo_db', 'timbo.db'));
    return NativeDatabase(file);
  });
}

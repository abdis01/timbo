import 'package:drift/drift.dart';
import '../tables/timbos_table.dart';
import '../database.dart';

part 'timbo_dao.g.dart';

@DriftAccessor(tables: [Timbos])
class TimboDao extends DatabaseAccessor<TimboDatabase> with _$TimboDaoMixin {
  TimboDao(super.db);

  Stream<List<Timbo>> watchTimbosByFolder(int folderId) {
    return (select(timbos)
      ..where((t) => t.folderId.equals(folderId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
    ).watch();
  }

  Stream<Timbo?> watchTimbo(int id) {
    return (select(timbos)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<int> insertTimbo(TimbosCompanion timbo) => into(timbos).insert(timbo);

  Future<void> updateTimbo(TimbosCompanion timbo) async {
    final id = timbo.id.value;
    await (update(timbos)..where((t) => t.id.equals(id))).write(timbo);
  }

  Future<void> deleteTimbo(int id) {
    return (delete(timbos)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Timbo>> getRecentTimbos(int limit) {
    return (select(timbos)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(limit)
    ).get();
  }

  Future<List<Timbo>> searchTimbos(String query) {
    return (select(timbos)
      ..where((t) => t.title.like('%$query%'))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
    ).get();
  }
}
